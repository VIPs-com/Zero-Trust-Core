#!/bin/sh
# Zero Trust Core — health check para Tails (manual, sem cron)
# Curso: COMANDO T.5 — https://github.com/VIPs-com/Zero-Trust-Core
# Rodar no inicio de cada sessao Tails.
#
# Auditoria Red/Blue/Purple: A7 A10 corrigidos

set -u

PERSISTENT="${ZTC_TAILS_PERSISTENT:-$HOME/Persistent}"
COFRE_DIR="${ZTC_TAILS_COFRE:-$PERSISTENT/cofre-ztc}"
KDBX="${ZTC_TAILS_KDBX:-$COFRE_DIR/senhas.kdbx}"
BACKUP_USB="${ZTC_TAILS_BACKUP_USB:-}"
FAIL=0
WARN=0

echo "=== Zero Trust Core — Tails Health ==="

# 0) Versao do Tails (A7)
TAILS_VERSION=""
if [ -f /etc/os-release ]; then
  TAILS_VERSION=$(grep '^TAILS_VERSION_ID=' /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"')
fi
if [ -z "$TAILS_VERSION" ] && [ -f /etc/amnesia/version ]; then
  TAILS_VERSION=$(cat /etc/amnesia/version 2>/dev/null | head -1)
fi
if [ -n "$TAILS_VERSION" ]; then
  echo "[INFO] Tails versao: $TAILS_VERSION — verifique em tails.net se e a mais recente"
else
  echo "[WARN] Nao foi possivel detectar a versao do Tails"
  WARN=1
fi

# 1) Persistent Storage
if mountpoint -q "$PERSISTENT" 2>/dev/null; then
  echo "[OK] Persistent Storage montado"
else
  echo "[FAIL] Persistent Storage NAO montado — ative antes de continuar"
  FAIL=1
fi

# 2) GPG subkeys
if ! command -v gpg >/dev/null 2>&1; then
  echo "[FAIL] gpg nao encontrado — instalacao Tails corrompida?"
  FAIL=1
elif gpg -K --with-colons 2>/dev/null | grep -q '^sec:'; then
  if gpg -K 2>/dev/null | grep -q 'sec#'; then
    echo "[OK] gpg -K — subkeys presentes (sec# = master ausente OK)"
  else
    echo "[WARN] gpg -K — master key local detectada (deveria ser sec#)"
    WARN=1
  fi
else
  echo "[WARN] Nenhuma chave secreta no keyring (importe subkeys do USB)"
  WARN=1
fi

# 3) KeePassXC (A10: FAIL nao WARN — ferramenta essencial)
if command -v keepassxc >/dev/null 2>&1; then
  echo "[OK] KeePassXC instalado"
else
  echo "[FAIL] KeePassXC ausente — sudo apt install keepassxc"
  FAIL=1
fi

# 4) .kdbx (A10: FAIL nao WARN — banco de senhas essencial)
if [ -f "$KDBX" ]; then
  echo "[OK] $KDBX legivel"
else
  echo "[FAIL] $KDBX nao encontrado"
  FAIL=1
fi

# 5) age
if command -v age >/dev/null 2>&1; then
  echo "[OK] age instalado"
else
  echo "[WARN] age ausente — sudo apt install age"
  WARN=1
fi

# 6) Smartcard (opcional)
if command -v gpg >/dev/null 2>&1 && command -v pcscd >/dev/null 2>&1; then
  if gpg --card-status >/dev/null 2>&1; then
    echo "[OK] Smartcard detectado"
  else
    echo "[SKIP] Smartcard — nenhum cartao inserido"
  fi
else
  echo "[SKIP] Smartcard — pcscd ausente (instale como Additional Software)"
fi

# 7) NFC (opcional)
if command -v nfc-list >/dev/null 2>&1; then
  if nfc-list 2>/dev/null | grep -q "target"; then
    echo "[OK] NFC — tag detectada"
  else
    echo "[SKIP] NFC — nfc-list sem tag"
  fi
else
  echo "[SKIP] NFC — nfc-list ausente"
fi

# 8) Ultimo backup + integridade do manifesto
if [ -n "$BACKUP_USB" ] && [ -f "$BACKUP_USB/ztc-backup/MANIFEST.sha256" ]; then
  LAST_LINE=$(tail -1 "$BACKUP_USB/ztc-backup/MANIFEST.sha256")
  LAST_FILE=$(echo "$LAST_LINE" | awk '{print $2}')
  # Extrair data do nome (backup-YYYYMMDD-HHMMSS.age)
  LAST_DATE=$(echo "$LAST_FILE" | sed 's/backup-//;s/-.*//')
  if [ -n "$LAST_DATE" ]; then
    echo "[INFO] Ultimo backup: $LAST_DATE"
  fi
  # Verificar integridade do ultimo backup
  LAST_HASH=$(echo "$LAST_LINE" | awk '{print $1}')
  LAST_PATH="$BACKUP_USB/ztc-backup/$LAST_FILE"
  if [ -f "$LAST_PATH" ]; then
    ACTUAL_HASH=$(sha256sum "$LAST_PATH" | awk '{print $1}')
    if [ "$LAST_HASH" = "$ACTUAL_HASH" ]; then
      echo "[OK] Integridade do ultimo backup verificada (sha256 confere)"
    else
      echo "[FAIL] Hash do ultimo backup NAO confere — backup corrompido ou adulterado!"
      FAIL=1
    fi
  else
    echo "[WARN] Arquivo do ultimo backup nao encontrado: $LAST_PATH"
    WARN=1
  fi
elif [ -n "$BACKUP_USB" ]; then
  echo "[WARN] USB de backup sem manifesto: $BACKUP_USB/ztc-backup/MANIFEST.sha256"
  WARN=1
else
  echo "[INFO] ZTC_TAILS_BACKUP_USB nao definido — checagem de backup pulada"
fi

# --- Resultado ---
if [ "$FAIL" -ne 0 ]; then
  echo "=== Tails Health: FAIL — corrija os erros acima ==="
  exit 1
elif [ "$WARN" -ne 0 ]; then
  echo "=== Tails Health: OK com avisos — revise [WARN] acima ==="
else
  echo "=== Tails Health: OK ==="
fi
