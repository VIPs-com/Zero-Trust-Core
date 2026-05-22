#!/bin/sh
# Zero Trust Core — mount VeraCrypt + abrir KeePass (presença NFC opcional)
# Curso: COMANDO 5.3 — https://github.com/VIPs-com/Zero-Trust-Core

set -eu

CONF="${ZTC_CONF:-$HOME/ztc-backup/ztc.conf}"
if [ -f "$CONF" ]; then
  # shellcheck disable=SC1090
  . "$CONF"
fi

: "${ZTC_VAULT_HC:?Defina ZTC_VAULT_HC em $CONF}"
ZTC_MOUNT_POINT="${ZTC_MOUNT_POINT:-/media/veracrypt-ztc}"
ZTC_KDBX="${ZTC_KDBX:-$ZTC_MOUNT_POINT/lab-passwords.kdbx}"
ZTC_KEYFILE="${ZTC_KEYFILE:-$HOME/keepass-keyfile.ztc}"

if [ -n "${ZTC_NFC_UID:-}" ]; then
  if ! command -v nfc-list >/dev/null 2>&1; then
    echo "[FAIL] nfc-list ausente; instale libnfc ou remova ZTC_NFC_UID do conf"
    exit 1
  fi
  if ! nfc-list 2>/dev/null | grep -qF "$ZTC_NFC_UID"; then
    echo "[FAIL] NTAG ausente (UID esperado: $ZTC_NFC_UID)"
    exit 1
  fi
  echo "[OK] NTAG presente"
fi

if mountpoint -q "$ZTC_MOUNT_POINT" 2>/dev/null; then
  echo "[INFO] $ZTC_MOUNT_POINT ja montado"
else
  echo "Montando $ZTC_VAULT_HC em $ZTC_MOUNT_POINT (senha do volume no prompt)..."
  sudo mkdir -p "$ZTC_MOUNT_POINT"
  veracrypt -t "$ZTC_VAULT_HC" "$ZTC_MOUNT_POINT"
fi

if [ ! -f "$ZTC_KDBX" ]; then
  echo "[WARN] .kdbx nao encontrado: $ZTC_KDBX"
  exit 1
fi

if [ ! -f "$ZTC_KEYFILE" ]; then
  echo "[WARN] keyfile nao encontrado: $ZTC_KEYFILE (copie do ritual NTAG ou restore do backup .age)"
  exit 1
fi

echo "[OK] Abrindo KeePassXC..."
exec keepassxc --keyfile "$ZTC_KEYFILE" "$ZTC_KDBX"
