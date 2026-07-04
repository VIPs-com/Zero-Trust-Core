#!/bin/sh
# Zero Trust Core — restore test do cofre Debian (VeraCrypt + KeePassXC)
# Curso: COMANDO 4.3 (ritual mensal) — https://github.com/VIPs-com/Zero-Trust-Core
#
# Prova que um SNAPSHOT do vault.hc e REALMENTE restauravel (a "0 erros" do 3-2-1-1-0):
#   1. Integridade sha256 do snapshot vs MANIFEST
#   2. Monta o snapshot READ-ONLY com VeraCrypt — NUNCA o vault vivo
#   3. .kdbx presente e com tamanho plausivel
#   4. KeePassXC ABRE o .kdbx com senha + keyfile (prova real, nao "sempre OK")
#   5. Desmonta e limpa TUDO no final (trap), em sucesso ou erro
#
# Rodar mensalmente OU apos um snapshot importante.
# NAO toca o vault vivo, o mountpoint diario, nem o KeePassXC aberto.
# Mount read-only => o snapshot testado nunca e alterado.

set -u

CONF="${ZTC_CONF:-$HOME/ztc-backup/ztc.conf}"
if [ -f "$CONF" ]; then
  # shellcheck disable=SC1090
  . "$CONF"
fi

ZTC_SNAPSHOT_DIR="${ZTC_SNAPSHOT_DIR:-$HOME/ztc-backup/snapshots}"
ZTC_KEYFILE="${ZTC_KEYFILE:-$HOME/keepass-keyfile.ztc}"
KDBX_NAME="${ZTC_KDBX_NAME:-lab-passwords.kdbx}"        # nome do .kdbx dentro do vault
TEST_MOUNT="${ZTC_RESTORE_MOUNT:-/media/ztc-restore-test}"

PASS=0; FAIL=0; WARN=0; TOTAL=0
check_pass() { PASS=$((PASS+1)); TOTAL=$((TOTAL+1)); echo "[PASS] $1"; }
check_fail() { FAIL=$((FAIL+1)); TOTAL=$((TOTAL+1)); echo "[FAIL] $1"; }
check_warn() { WARN=$((WARN+1)); TOTAL=$((TOTAL+1)); echo "[WARN] $1"; }

MOUNTED=0
cleanup() {
  echo ""
  echo "--- Limpeza ---"
  if [ "$MOUNTED" -eq 1 ] && mountpoint -q "$TEST_MOUNT" 2>/dev/null; then
    if veracrypt -t -d "$TEST_MOUNT" 2>/dev/null; then
      echo "[OK] Snapshot desmontado"
    else
      echo "[WARN] Falha ao desmontar — rode: veracrypt -t -d $TEST_MOUNT"
    fi
  fi
  [ -d "$TEST_MOUNT" ] && sudo rmdir "$TEST_MOUNT" 2>/dev/null
  return 0
}
trap cleanup EXIT INT TERM

echo "=============================================="
echo "  Zero Trust Core — Restore Test (Debian)"
echo "  $(date '+%Y-%m-%d %H:%M')"
echo "=============================================="
echo ""

# --- Pre-requisitos ---
MISSING=""
for bin in veracrypt keepassxc-cli sha256sum; do
  command -v "$bin" >/dev/null 2>&1 || MISSING="$MISSING $bin"
done
if [ -n "$MISSING" ]; then
  echo "[FAIL] Ferramentas ausentes:$MISSING"
  echo "       sudo apt install keepassxc   (VeraCrypt: .deb em veracrypt.fr)"
  exit 1
fi

# --- Selecionar snapshot (arg \$1 ou o mais recente) ---
if [ -n "${1:-}" ]; then
  SNAP="$1"
else
  # shellcheck disable=SC2012
  # Nomes gerados por ztc-snapshot-vault.sh (vault-YYYYMMDD-HHMMSS.hc) — sem espacos
  SNAP=$(ls -1t "$ZTC_SNAPSHOT_DIR"/vault-*.hc 2>/dev/null | head -1)
  if [ -z "$SNAP" ]; then
    echo "[FAIL] Nenhum snapshot vault-*.hc em $ZTC_SNAPSHOT_DIR"
    echo "       Gere um com ztc-snapshot-vault.sh (ou feche o cofre com ztc-close-cofre.sh)"
    exit 1
  fi
  echo "Snapshot selecionado (mais recente): $(basename "$SNAP")"
fi
[ -f "$SNAP" ] || { echo "[FAIL] Arquivo nao encontrado: $SNAP"; exit 1; }
echo "Arquivo: $SNAP ($(du -h "$SNAP" | awk '{print $1}'))"
echo ""

# --- Teste 1/4: integridade sha256 vs MANIFEST ---
echo "=== Teste 1/4: Integridade (sha256 vs MANIFEST) ==="
MANIFEST="$ZTC_SNAPSHOT_DIR/MANIFEST.sha256"
SNAP_BASE=$(basename "$SNAP")
ACTUAL=$(sha256sum "$SNAP" | awk '{print $1}')
if [ -f "$MANIFEST" ]; then
  EXPECTED=$(grep -F "$SNAP_BASE" "$MANIFEST" 2>/dev/null | awk '{print $1}' | tail -1)
  if [ -n "$EXPECTED" ]; then
    if [ "$EXPECTED" = "$ACTUAL" ]; then
      check_pass "sha256 confere com o MANIFEST (sem bitrot/adulteracao)"
    else
      check_fail "sha256 NAO confere — snapshot corrompido ou adulterado!"
      echo "       Manifesto: $EXPECTED"
      echo "       Calculado: $ACTUAL"
    fi
  else
    check_warn "Snapshot nao consta no MANIFEST (nome fora do padrao?)"
  fi
else
  check_warn "MANIFEST.sha256 ausente — verificacao de integridade pulada"
fi
echo ""

# --- Teste 2/4: montar o snapshot READ-ONLY (nunca o vault vivo) ---
echo "=== Teste 2/4: Montar snapshot (read-only) ==="
if mountpoint -q "$TEST_MOUNT" 2>/dev/null; then
  check_fail "$TEST_MOUNT ja montado — desmonte antes: veracrypt -t -d $TEST_MOUNT"
  exit 1
fi
sudo mkdir -p "$TEST_MOUNT"
echo "Digite a senha do VeraCrypt deste snapshot:"
# --mount-options=ro: montagem somente-leitura — o snapshot testado nunca e alterado.
# As camadas extras (PIM/keyfile-vc/hidden) usam os mesmos valores do ztc.conf.
if veracrypt -t --mount-options=ro \
     --pim="${ZTC_VC_PIM:-0}" \
     --keyfiles="${ZTC_VC_KEYFILES:-}" \
     --protect-hidden="${ZTC_VC_PROTECT_HIDDEN:-no}" \
     "$SNAP" "$TEST_MOUNT" 2>/dev/null; then
  MOUNTED=1
  check_pass "Snapshot montado read-only em $TEST_MOUNT"
else
  check_fail "VeraCrypt NAO montou — senha errada, camada faltando ou arquivo corrompido"
  echo ""
  echo "  🔴 RESTORE TEST FALHOU ao montar — este snapshot NAO e restauravel."
  exit 1
fi
echo ""

# --- Teste 3/4: .kdbx presente ---
echo "=== Teste 3/4: Banco de senhas (.kdbx) ==="
KDBX="$TEST_MOUNT/$KDBX_NAME"
if [ ! -f "$KDBX" ]; then
  KDBX=$(find "$TEST_MOUNT" -maxdepth 2 -name '*.kdbx' -type f 2>/dev/null | head -1)
fi
if [ -n "$KDBX" ] && [ -f "$KDBX" ]; then
  KSIZE=$(stat -c%s "$KDBX" 2>/dev/null || echo 0)
  if [ "$KSIZE" -gt 1000 ]; then
    check_pass ".kdbx presente: $(basename "$KDBX") ($KSIZE bytes)"
  else
    check_fail ".kdbx com tamanho suspeito ($KSIZE bytes — esperado >1KB)"
  fi
else
  check_fail "Nenhum .kdbx encontrado dentro do snapshot"
  KDBX=""
fi
echo ""

# --- Teste 4/4: UNLOCK real (senha + keyfile) = prova de restore ---
echo "=== Teste 4/4: Abrir o .kdbx (senha + keyfile) ==="
if [ -n "$KDBX" ]; then
  KF="$ZTC_KEYFILE"
  if [ ! -f "$KF" ]; then
    echo "[INFO] Keyfile nao esta em $KF (normal se fica so no NTAG/USB — o keyfile e o 2FA,"
    echo "       nao mora dentro do vault). Forneca o caminho para testar o unlock completo."
    printf "Caminho do keyfile (Enter para tentar sem): "
    read -r KF_INPUT
    [ -n "$KF_INPUT" ] && KF="$KF_INPUT"
  fi
  KF_FLAG=""
  if [ -f "$KF" ]; then
    KF_FLAG="--key-file $KF"
    echo "[INFO] Usando keyfile: $KF"
  else
    check_warn "Sem keyfile — se o cofre exige keyfile, o unlock vai (corretamente) falhar"
  fi
  echo "Digite a senha mestra do KeePassXC (NAO a do VeraCrypt):"
  # keepassxc-cli le a senha do /dev/tty; redirecionamos a saida pois so importa o exit code.
  # shellcheck disable=SC2086
  if keepassxc-cli ls $KF_FLAG "$KDBX" >/dev/null 2>&1; then
    check_pass "KeePassXC ABRIU o .kdbx — backup genuinamente restauravel!"
  else
    check_fail "KeePassXC NAO abriu — senha errada, keyfile errado/ausente ou banco corrompido"
  fi
else
  check_warn "Sem .kdbx para testar a abertura"
fi
echo ""

# --- Resultado ---
echo "=============================================="
echo "  RESULTADO — Total:$TOTAL  PASS:$PASS  FAIL:$FAIL  WARN:$WARN"
echo "=============================================="
if [ "$FAIL" -gt 0 ]; then
  echo "  🔴 SNAPSHOT COM PROBLEMAS — pode NAO restaurar em emergencia."
  echo "     Gere um novo snapshot (ztc-snapshot-vault.sh) e re-teste."
  exit 1
elif [ "$WARN" -gt 0 ]; then
  echo "  🟡 OK com avisos — revise os [WARN] acima."
  exit 0
else
  echo "  🟢 RESTORE 100% VERIFICADO — snapshot confiavel para emergencia."
  echo "     Anote a data deste teste (ritual mensal — COMANDO 4.3)."
  exit 0
fi
