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

# Modo de abertura: 'gui' (default) ou 'cli'.
# Nota: keepassxc (GUI) IGNORA --keyfile em 2.7.x — abrimos só o .kdbx e
# deixamos a GUI pedir o keyfile no diálogo. KeePassXC LEMBRA o keyfile
# depois da primeira abertura (gravado no perfil do banco).
# Para automação total sem GUI, defina ZTC_KEEPASSXC_MODE=cli no ztc.conf.
ZTC_KEEPASSXC_MODE="${ZTC_KEEPASSXC_MODE:-gui}"

case "$ZTC_KEEPASSXC_MODE" in
  cli)
    if ! command -v keepassxc-cli >/dev/null 2>&1; then
      echo "[FAIL] keepassxc-cli ausente; use modo gui ou instale o pacote"
      exit 1
    fi
    echo "[OK] Abrindo KeePassXC (CLI interativo, exit para sair)..."
    exec keepassxc-cli open --key-file "$ZTC_KEYFILE" "$ZTC_KDBX"
    ;;
  gui|*)
    echo "[OK] Abrindo KeePassXC (GUI)..."
    echo "     Primeira abertura: marque 'Key File' no dialogo e selecione:"
    echo "       $ZTC_KEYFILE"
    echo "     KeePassXC vai lembrar nas proximas vezes."
    exec keepassxc "$ZTC_KDBX"
    ;;
esac
