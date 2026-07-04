#!/bin/sh
# Zero Trust Core — restore test completo para Tails
# Curso: complemento ao Playbook T03 — https://github.com/VIPs-com/Zero-Trust-Core
# Verifica que um backup .age é REALMENTE restaurável:
#   1. Descriptografa com age
#   2. Extrai o tar
#   3. Verifica que .kdbx existe e é válido
#   4. Verifica que subkeys GPG importam corretamente
#   5. Verifica que keyfile existe e hash confere
#   6. Verifica que certificado de revogação existe
#   7. Limpa TUDO no final (nenhum artefato fica em /tmp)
#
# Rodar apos cada backup OU mensalmente.
# NAO altera o keyring GPG nem o KeePassXC do usuario.
# Tudo acontece em diretorio temporario isolado.

set -eu

# --- Configuração ---
PERSISTENT="${ZTC_TAILS_PERSISTENT:-$HOME/Persistent}"
COFRE_DIR="${ZTC_TAILS_COFRE:-$PERSISTENT/cofre-ztc}"
ORIGINAL_KDBX="${ZTC_TAILS_KDBX:-$COFRE_DIR/senhas.kdbx}"
ORIGINAL_KEYFILE="${ZTC_TAILS_KEYFILE:-$COFRE_DIR/keepass-keyfile.ztc}"

PASS=0
FAIL=0
WARN=0
TOTAL=0

check_pass() {
  PASS=$((PASS + 1))
  TOTAL=$((TOTAL + 1))
  echo "[PASS] $1"
}

check_fail() {
  FAIL=$((FAIL + 1))
  TOTAL=$((TOTAL + 1))
  echo "[FAIL] $1"
}

check_warn() {
  WARN=$((WARN + 1))
  TOTAL=$((TOTAL + 1))
  echo "[WARN] $1"
}

echo "=============================================="
echo "  Zero Trust Core — Restore Test Completo"
echo "  $(date '+%Y-%m-%d %H:%M')"
echo "=============================================="
echo ""

# --- Selecionar arquivo de backup ---
if [ -n "${1:-}" ]; then
  ARCHIVE="$1"
else
  # Tentar encontrar o backup mais recente
  BACKUP_USB="${ZTC_TAILS_BACKUP_USB:-}"
  if [ -z "$BACKUP_USB" ]; then
    echo "Pendrives montados em /media/amnesia/:"
    ls -1 /media/amnesia/ 2>/dev/null || true
    echo ""
    printf "Caminho do USB de backup (ex.: /media/amnesia/BACKUP): "
    read -r BACKUP_USB
  fi

  BACKUP_DIR="$BACKUP_USB/ztc-backup"
  if [ ! -d "$BACKUP_DIR" ]; then
    echo "[FAIL] Diretorio de backup nao encontrado: $BACKUP_DIR"
    exit 1
  fi

  # Pegar o backup mais recente
  # shellcheck disable=SC2012
  ARCHIVE=$(ls -1t "$BACKUP_DIR"/backup-*.age 2>/dev/null | head -1)
  if [ -z "$ARCHIVE" ]; then
    echo "[FAIL] Nenhum arquivo backup-*.age encontrado em $BACKUP_DIR"
    exit 1
  fi
  echo "Backup selecionado (mais recente): $(basename "$ARCHIVE")"
fi

if [ ! -f "$ARCHIVE" ]; then
  echo "[FAIL] Arquivo nao encontrado: $ARCHIVE"
  exit 1
fi

echo "Arquivo: $ARCHIVE"
echo "Tamanho: $(du -h "$ARCHIVE" | awk '{print $1}')"
echo ""

# --- Preparar ambiente de teste isolado ---
TEST_DIR=$(mktemp -d /tmp/ztc-restore-test.XXXXXX)
chmod 700 "$TEST_DIR"
GNUPGHOME_ORIG="${GNUPGHOME:-$HOME/.gnupg}"
export GNUPGHOME="$TEST_DIR/gnupg-test"
mkdir -p "$GNUPGHOME"
chmod 700 "$GNUPGHOME"

# Limpar TUDO no final — independente de sucesso ou erro
# B1: sobrescrita segura com fallback se shred/stat falhar
cleanup() {
  echo ""
  echo "--- Limpeza ---"
  if [ -d "$TEST_DIR" ]; then
    # Tentar shred primeiro (mais seguro), fallback para dd
    if command -v shred >/dev/null 2>&1; then
      find "$TEST_DIR" -type f -exec shred -u -z -n 1 {} \; 2>/dev/null
    else
      find "$TEST_DIR" -type f -exec sh -c '
        FSIZE=$(wc -c < "$1" 2>/dev/null || echo 0)
        if [ "$FSIZE" -gt 0 ]; then
          dd if=/dev/urandom of="$1" bs="$FSIZE" count=1 conv=notrunc 2>/dev/null || true
        fi
        rm -f "$1"
      ' _ {} \;
    fi
    rm -rf "$TEST_DIR"
    echo "[OK] Diretorio de teste removido e sobrescrito"
  fi
  # Restaurar GNUPGHOME
  export GNUPGHOME="$GNUPGHOME_ORIG"
}
trap cleanup EXIT INT TERM

echo "=== Teste 1/7: Descriptografar backup ==="
echo ""
echo "Digite a passphrase age deste backup:"
# B4: --no-absolute-names previne path traversal (tar com ../ ou /)
if age -d "$ARCHIVE" | tar -xf - -C "$TEST_DIR" --no-same-owner --no-absolute-names 2>/dev/null; then
  # Verificar que nenhum arquivo escapou do TEST_DIR
  ESCAPED=$(find "$TEST_DIR" -name '*..*' 2>/dev/null | wc -l)
  if [ "$ESCAPED" -gt 0 ]; then
    check_fail "Arquivos com path traversal detectados no backup — possivel adulteracao!"
    cleanup
    exit 1
  fi
  check_pass "Backup descriptografado e extraido com sucesso"
else
  check_fail "Falha ao descriptografar — passphrase errada ou arquivo corrompido"
  echo ""
  echo "=============================================="
  echo "  RESTORE TEST: FALHOU no primeiro passo"
  echo "  O backup NAO e restauravel com essa passphrase."
  echo "  Verifique a passphrase no KeePassXC e tente novamente."
  echo "=============================================="
  exit 1
fi

echo ""
echo "Conteudo extraido:"
ls -la "$TEST_DIR/"
echo ""

# --- Teste 2: .kdbx existe e tem tamanho plausível ---
echo "=== Teste 2/7: Banco de senhas (.kdbx) ==="
RESTORED_KDBX=$(find "$TEST_DIR" -name '*.kdbx' -type f | head -1)
if [ -n "$RESTORED_KDBX" ]; then
  KDBX_SIZE=$(stat -c%s "$RESTORED_KDBX" 2>/dev/null || stat -f%z "$RESTORED_KDBX" 2>/dev/null || echo "0")
  if [ "$KDBX_SIZE" -gt 1000 ]; then
    check_pass ".kdbx encontrado: $(basename "$RESTORED_KDBX") ($KDBX_SIZE bytes)"

    # Verificar se o hash confere com o original (se disponível)
    if [ -f "$ORIGINAL_KDBX" ]; then
      ORIG_HASH=$(sha256sum "$ORIGINAL_KDBX" | awk '{print $1}')
      REST_HASH=$(sha256sum "$RESTORED_KDBX" | awk '{print $1}')
      if [ "$ORIG_HASH" = "$REST_HASH" ]; then
        check_pass ".kdbx hash confere com original (sha256 identico)"
      else
        check_warn ".kdbx hash DIFERENTE do original — backup pode ser de outra data"
        echo "       Original: $ORIG_HASH"
        echo "       Backup:   $REST_HASH"
      fi
    else
      check_warn "Original .kdbx nao encontrado para comparacao ($ORIGINAL_KDBX)"
    fi

    # Tentar validar com keepassxc-cli (se disponível)
    if command -v keepassxc-cli >/dev/null 2>&1; then
      echo ""
      echo "Testando abertura do .kdbx com keepassxc-cli..."
      echo "(Digite a senha mestra do KeePassXC — NAO a passphrase age)"
      echo ""
      # Tentar listar entradas (prova que o banco abre)
      KEYFILE_FLAG=""
      RESTORED_KEYFILE=$(find "$TEST_DIR" -name '*.ztc' -type f | head -1)
      if [ -n "$RESTORED_KEYFILE" ]; then
        KEYFILE_FLAG="--key-file $RESTORED_KEYFILE"
      fi
      # shellcheck disable=SC2086
      if keepassxc-cli ls $KEYFILE_FLAG "$RESTORED_KDBX" 2>/dev/null; then
        check_pass "KeePassXC abriu o .kdbx com sucesso — banco valido!"
      else
        check_fail "KeePassXC NAO conseguiu abrir o .kdbx — senha ou keyfile errado"
        echo "       Se usa keyfile: verifique que keepass-keyfile.ztc esta no backup"
      fi
    else
      check_warn "keepassxc-cli nao disponivel — nao foi possivel testar abertura do .kdbx"
      echo "       Instale com: sudo apt install keepassxc"
    fi
  else
    check_fail ".kdbx encontrado mas tamanho suspeito ($KDBX_SIZE bytes — esperado >1KB)"
  fi
else
  check_fail "Nenhum arquivo .kdbx encontrado no backup!"
fi

echo ""

# --- Teste 3: Keyfile ---
echo "=== Teste 3/7: Keyfile ==="
RESTORED_KEYFILE=$(find "$TEST_DIR" -name '*.ztc' -type f | head -1)
if [ -n "$RESTORED_KEYFILE" ]; then
  KEYFILE_SIZE=$(stat -c%s "$RESTORED_KEYFILE" 2>/dev/null || stat -f%z "$RESTORED_KEYFILE" 2>/dev/null || echo "0")
  check_pass "Keyfile encontrado: $(basename "$RESTORED_KEYFILE") ($KEYFILE_SIZE bytes)"

  # Comparar com original (se disponível — pode estar só no USB dedicado)
  if [ -f "$ORIGINAL_KEYFILE" ]; then
    ORIG_KF_HASH=$(sha256sum "$ORIGINAL_KEYFILE" | awk '{print $1}')
    REST_KF_HASH=$(sha256sum "$RESTORED_KEYFILE" | awk '{print $1}')
    if [ "$ORIG_KF_HASH" = "$REST_KF_HASH" ]; then
      check_pass "Keyfile hash confere com original"
    else
      check_fail "Keyfile hash DIFERENTE do original — keyfile corrompido ou trocado!"
    fi
  else
    check_warn "Keyfile original nao encontrado para comparacao"
    echo "       (Normal se keyfile esta apenas no USB dedicado — A5)"
  fi
else
  check_warn "Nenhum keyfile .ztc encontrado no backup"
  echo "       Normal se o keyfile esta apenas no USB dedicado"
fi

echo ""

# --- Teste 4: Subkeys GPG ---
echo "=== Teste 4/7: Subkeys GPG ==="
RESTORED_SUBKEYS=$(find "$TEST_DIR" -name 'subkeys-export.asc' -type f | head -1)
if [ -n "$RESTORED_SUBKEYS" ]; then
  check_pass "Arquivo de subkeys encontrado: $(basename "$RESTORED_SUBKEYS")"

  # Importar em keyring TEMPORÁRIO (não toca o real)
  if gpg --import "$RESTORED_SUBKEYS" 2>/dev/null; then
    # Verificar que importou
    KEY_COUNT=$(gpg --list-secret-keys --with-colons 2>/dev/null | grep -c '^sec:' || echo "0")
    SUBKEY_COUNT=$(gpg --list-secret-keys --with-colons 2>/dev/null | grep -c '^ssb:' || echo "0")
    if [ "$KEY_COUNT" -gt 0 ]; then
      check_pass "Subkeys importadas no keyring de teste: $KEY_COUNT chave(s), $SUBKEY_COUNT subchave(s)"

      # Verificar fingerprint
      FPRINT=$(gpg --list-keys --with-colons 2>/dev/null | grep '^fpr' | head -1 | cut -d: -f10)
      if [ -n "$FPRINT" ]; then
        echo "       Fingerprint: $FPRINT"
      fi

      # Testar assinatura
      if echo "restore test $(date)" | gpg --clearsign >/dev/null 2>&1; then
        check_pass "Assinatura GPG funcional com subkeys restauradas"
      else
        check_warn "Assinatura GPG falhou — subkeys podem ser somente publicas ou PIN necessario"
      fi
    else
      check_fail "Importacao aparentemente OK mas nenhuma chave secreta no keyring"
    fi
  else
    check_fail "Falha ao importar subkeys no keyring de teste"
  fi
else
  check_warn "Arquivo subkeys-export.asc nao encontrado no backup"
fi

echo ""

# --- Teste 5: Chave pública ---
echo "=== Teste 5/7: Chave publica ==="
RESTORED_PUBKEY=$(find "$TEST_DIR" -name 'pubkey-export.asc' -type f | head -1)
if [ -n "$RESTORED_PUBKEY" ]; then
  if gpg --import "$RESTORED_PUBKEY" 2>/dev/null; then
    PUB_COUNT=$(gpg --list-keys --with-colons 2>/dev/null | grep -c '^pub:' || echo "0")
    check_pass "Chave publica importada ($PUB_COUNT chave(s))"
  else
    check_fail "Falha ao importar chave publica"
  fi
else
  check_warn "Arquivo pubkey-export.asc nao encontrado no backup"
fi

echo ""

# --- Teste 6: Certificado de revogação ---
echo "=== Teste 6/7: Certificado de revogacao ==="
REVOC_COUNT=$(find "$TEST_DIR" -name '*.rev' -o -name 'revogacao.asc' 2>/dev/null | wc -l)
if [ "$REVOC_COUNT" -gt 0 ]; then
  check_pass "$REVOC_COUNT certificado(s) de revogacao encontrado(s)"
  find "$TEST_DIR" -name '*.rev' -o -name 'revogacao.asc' 2>/dev/null | while read -r rev; do
    echo "       $(basename "$rev") ($(stat -c%s "$rev" 2>/dev/null || echo '?') bytes)"
  done
else
  check_warn "Nenhum certificado de revogacao no backup"
  echo "       Recomendado: guardar revogacao.asc no ~/Persistent/ para ser incluido"
fi

echo ""

# --- Teste 7: Manifesto do backup ---
echo "=== Teste 7/7: Manifesto e integridade ==="
BACKUP_DIR=$(dirname "$ARCHIVE")
MANIFEST="$BACKUP_DIR/MANIFEST.sha256"
if [ -f "$MANIFEST" ]; then
  ARCHIVE_NAME=$(basename "$ARCHIVE")
  MANIFEST_HASH=$(grep "$ARCHIVE_NAME" "$MANIFEST" | awk '{print $1}' | tail -1)
  ACTUAL_HASH=$(sha256sum "$ARCHIVE" | awk '{print $1}')
  if [ -n "$MANIFEST_HASH" ]; then
    if [ "$MANIFEST_HASH" = "$ACTUAL_HASH" ]; then
      check_pass "Hash do arquivo confere com MANIFEST.sha256"
    else
      check_fail "Hash NAO confere — backup pode ter sido adulterado!"
      echo "       Manifesto: $MANIFEST_HASH"
      echo "       Calculado: $ACTUAL_HASH"
    fi
  else
    check_warn "Arquivo nao encontrado no manifesto (nome diferente?)"
  fi

  # Verificar assinatura GPG do manifesto
  SIGNED="$BACKUP_DIR/MANIFEST.sha256.signed"
  if [ -f "$SIGNED" ]; then
    # Importar chaves do usuario para verificar (usar keyring original)
    GNUPGHOME_TMP="$GNUPGHOME"
    export GNUPGHOME="$GNUPGHOME_ORIG"
    if gpg --verify "$SIGNED" 2>/dev/null; then
      check_pass "Assinatura GPG do manifesto verificada"
    else
      check_warn "Assinatura GPG do manifesto nao verificada (chave ausente ou invalida)"
    fi
    export GNUPGHOME="$GNUPGHOME_TMP"
  else
    check_warn "Manifesto nao assinado com GPG (MANIFEST.sha256.signed ausente)"
  fi
else
  check_warn "MANIFEST.sha256 nao encontrado em $(dirname "$ARCHIVE")"
fi

echo ""

# --- Resultado final ---
echo "=============================================="
echo "  RESULTADO DO RESTORE TEST"
echo "=============================================="
echo ""
echo "  Total de verificacoes: $TOTAL"
echo "  ✅ PASS: $PASS"
echo "  ❌ FAIL: $FAIL"
echo "  ⚠️  WARN: $WARN"
echo ""

if [ "$FAIL" -gt 0 ]; then
  echo "  🔴 BACKUP COM PROBLEMAS"
  echo "  $FAIL verificacao(oes) falharam."
  echo "  Este backup pode NAO ser restauravel em emergencia."
  echo "  Recomendado: criar novo backup (ztc-tails-backup.sh)"
  echo ""
  echo "=============================================="
  exit 1
elif [ "$WARN" -gt 0 ]; then
  echo "  🟡 BACKUP OK COM AVISOS"
  echo "  Backup restauravel, mas $WARN item(ns) merecem atencao."
  echo "  Revise os [WARN] acima."
  echo ""
  echo "=============================================="
  exit 0
else
  echo "  🟢 BACKUP 100% VERIFICADO"
  echo "  Todos os componentes foram restaurados e testados."
  echo "  Este backup e confiavel para uso em emergencia."
  echo ""
  echo "=============================================="
  exit 0
fi
