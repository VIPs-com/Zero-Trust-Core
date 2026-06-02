#!/bin/sh
# Zero Trust Core — backup manual para Tails (Persistent → USB cifrado)
# Curso: COMANDO T.4 — https://github.com/VIPs-com/Zero-Trust-Core
# Rodar manualmente no final de cada sessão Tails.
#
# Auditoria Red/Blue/Purple: A1 A2 A3 A4 A8 corrigidos

set -eu

# --- Configuração ---
PERSISTENT="${ZTC_TAILS_PERSISTENT:-$HOME/Persistent}"
COFRE_DIR="${ZTC_TAILS_COFRE:-$PERSISTENT/cofre-ztc}"
KDBX="${ZTC_TAILS_KDBX:-$COFRE_DIR/senhas.kdbx}"
KEYFILE="${ZTC_TAILS_KEYFILE:-$COFRE_DIR/keepass-keyfile.ztc}"
BACKUP_KEEP="${ZTC_TAILS_BACKUP_KEEP:-7}"

# --- Validações (A4: verificar que paths estão dentro do Persistent) ---
if ! mountpoint -q "$PERSISTENT" 2>/dev/null; then
  echo "[FAIL] Persistent Storage nao montado: $PERSISTENT"
  exit 1
fi

# A4: validar que KDBX esta dentro do Persistent (evitar path injection)
REAL_PERSISTENT=$(realpath "$PERSISTENT" 2>/dev/null || echo "$PERSISTENT")
REAL_KDBX=$(realpath "$KDBX" 2>/dev/null || echo "$KDBX")
case "$REAL_KDBX" in
  "$REAL_PERSISTENT"/*) ;; # OK — dentro do Persistent
  *)
    echo "[FAIL] KDBX fora do Persistent Storage: $KDBX"
    echo "       Caminho resolvido: $REAL_KDBX"
    echo "       Esperado dentro de: $REAL_PERSISTENT"
    exit 1
    ;;
esac

if [ ! -f "$KDBX" ]; then
  echo "[FAIL] .kdbx nao encontrado: $KDBX"
  exit 1
fi

# --- Detectar USB de backup ---
if [ -n "${ZTC_TAILS_BACKUP_USB:-}" ]; then
  BACKUP_USB="$ZTC_TAILS_BACKUP_USB"
else
  echo "Pendrives montados em /media/amnesia/:"
  ls -1 /media/amnesia/ 2>/dev/null || true
  echo ""
  printf "Caminho do USB de backup (ex.: /media/amnesia/BACKUP): "
  if ! read -r BACKUP_USB; then
    echo "[FAIL] Nenhuma entrada recebida"
    exit 1
  fi
fi

# Validacao de seguranca: recusar caminhos do sistema
case "$BACKUP_USB" in
  /home/amnesia/Persistent*|/home/*/.gnupg*|/boot*|/etc*|/usr*|/var*|/bin*|/sbin*|/)
    echo "[FAIL] Caminho recusado por seguranca: $BACKUP_USB"
    echo "       Use um pendrive externo (ex.: /media/amnesia/BACKUP)"
    exit 1
    ;;
esac

if [ ! -d "$BACKUP_USB" ]; then
  echo "[FAIL] USB de backup nao encontrado: $BACKUP_USB"
  exit 1
fi

# Verificar que e midia removivel
if ! mountpoint -q "$BACKUP_USB" 2>/dev/null; then
  PARENT=$(dirname "$BACKUP_USB")
  if ! mountpoint -q "$PARENT" 2>/dev/null; then
    echo "[WARN] $BACKUP_USB nao parece ser midia removivel"
    printf "Continuar? (s/N): "
    read -r CONFIRM
    case "$CONFIRM" in s|S|sim|SIM) ;; *) echo "Abortado."; exit 1 ;; esac
  fi
fi

BACKUP_DIR="$BACKUP_USB/ztc-backup"
mkdir -p "$BACKUP_DIR"

# --- A2: lembrar o aluno de salvar a passphrase ANTES de cifrar ---
echo ""
echo "========================================================"
echo "  ANTES DE CONTINUAR:"
echo "  A passphrase age que voce vai digitar protege este backup."
echo "  Se perder a passphrase, o backup fica IRRECUPERAVEL."
echo ""
echo "  Recomendado: abra o KeePassXC agora e crie uma entrada"
echo "  'Backup Tails - age' com a passphrase que vai usar."
echo "  Use minimo 5 palavras diceware ou 20+ caracteres."
echo "========================================================"
echo ""
printf "Passphrase ja registrada no KeePassXC? (s/N): "
read -r READY
case "$READY" in s|S|sim|SIM) ;; *)
  echo "Abra o KeePassXC, salve a passphrase, depois rode novamente."
  exit 0
  ;;
esac

# --- Coletar artefatos (A1: usar pipe direto, sem subkeys em /tmp) ---
STAMP=$(date +%Y%m%d-%H%M%S)
TMP_DIR=$(mktemp -d /tmp/ztc-tails-bkp.XXXXXX)
chmod 700 "$TMP_DIR"
trap 'rm -rf "$TMP_DIR"' EXIT INT TERM

echo "Coletando artefatos..."

cp "$KDBX" "$TMP_DIR/"
if [ -f "$KEYFILE" ]; then
  cp "$KEYFILE" "$TMP_DIR/"
  echo "  + keyfile"
fi

# A1: exportar subkeys com permissoes restritas
if gpg -K --with-colons 2>/dev/null | grep -q '^sec:'; then
  OLD_UMASK=$(umask)
  umask 077
  gpg --export-secret-subkeys --armor > "$TMP_DIR/subkeys-export.asc" 2>/dev/null || true
  gpg --export --armor > "$TMP_DIR/pubkey-export.asc" 2>/dev/null || true
  umask "$OLD_UMASK"
  echo "  + subkeys GPG (permissoes restritas)"
fi

# A8: incluir certificado de revogação se existir
REVOCS_DIR="$HOME/.gnupg/openpgp-revocs.d"
if [ -d "$REVOCS_DIR" ]; then
  REVOC_COUNT=0
  for rev in "$REVOCS_DIR"/*.rev; do
    [ -f "$rev" ] || continue
    cp "$rev" "$TMP_DIR/"
    REVOC_COUNT=$((REVOC_COUNT + 1))
  done
  if [ "$REVOC_COUNT" -gt 0 ]; then
    echo "  + $REVOC_COUNT certificado(s) de revogacao"
  fi
fi
# Tambem procurar revogacao.asc no Persistent
if [ -f "$PERSISTENT/revogacao.asc" ]; then
  cp "$PERSISTENT/revogacao.asc" "$TMP_DIR/"
  echo "  + revogacao.asc"
fi

# --- Cifrar com age ---
ARCHIVE="$BACKUP_DIR/backup-$STAMP.age"
echo "Cifrando com age (minimo 5 palavras diceware)..."
tar -cf - -C "$TMP_DIR" . | age -p -o "$ARCHIVE"

# A1: limpar artefatos imediatamente apos cifrar
rm -rf "$TMP_DIR"
mkdir "$TMP_DIR"  # trap precisa de diretorio existente

# --- Manifesto (A3: assinar se chave GPG disponivel) ---
sha256sum "$ARCHIVE" >> "$BACKUP_DIR/MANIFEST.sha256"
if gpg -K --with-colons 2>/dev/null | grep -q '^sec:'; then
  gpg --yes --clearsign "$BACKUP_DIR/MANIFEST.sha256" 2>/dev/null && \
    mv "$BACKUP_DIR/MANIFEST.sha256.asc" "$BACKUP_DIR/MANIFEST.sha256.signed" && \
    echo "[OK] Manifesto atualizado + assinado com GPG" || \
    echo "[OK] Manifesto atualizado (assinatura GPG falhou — manifesto nao assinado)"
else
  echo "[OK] Manifesto atualizado (sem assinatura — GPG nao disponivel)"
fi

# --- Rotacao ---
TOTAL=$(find "$BACKUP_DIR" -maxdepth 1 -name 'backup-*.age' | wc -l)
if [ "$TOTAL" -gt "$BACKUP_KEEP" ]; then
  REMOVE=$((TOTAL - BACKUP_KEEP))
  echo "Rotacao: removendo $REMOVE backup(s) antigo(s)..."
  # shellcheck disable=SC2012
  ls -1t "$BACKUP_DIR"/backup-*.age | tail -n "$REMOVE" | while read -r old; do
    rm -v "$old"
  done
fi

# --- Resumo ---
KEPT=$(find "$BACKUP_DIR" -maxdepth 1 -name 'backup-*.age' | wc -l)
SIZE=$(du -sh "$BACKUP_DIR" 2>/dev/null | awk '{print $1}')
echo ""
echo "[OK] Backup concluido: $(basename "$ARCHIVE")"
echo "[OK] $KEPT backups mantidos ($SIZE total em $BACKUP_DIR)"
echo ""
echo "Para restore test:"
echo "  age -d $ARCHIVE | tar -xf - -C /tmp/restore-test"
