#!/bin/sh
# Zero Trust Core — rsync off-site (só blobs opacos)
# Curso: COMANDO 4.2.3 — https://github.com/VIPs-com/Zero-Trust-Core

set -eu

CONF="${ZTC_CONF:-$HOME/ztc-backup/ztc.conf}"
if [ -f "$CONF" ]; then
  # shellcheck disable=SC1090
  . "$CONF"
fi

: "${ZTC_REMOTE:?Defina ZTC_REMOTE em $CONF}"
: "${ZTC_SSH_KEY:?Defina ZTC_SSH_KEY em $CONF}"
: "${ZTC_VAULT_HC:?Defina ZTC_VAULT_HC em $CONF}"

ZTC_MANIFEST_DIR="${ZTC_MANIFEST_DIR:-$HOME/ztc-backup/manifest}"

if [ -n "${ZTC_NFC_UID:-}" ]; then
  if ! command -v nfc-list >/dev/null 2>&1; then
    echo "nfc-list não encontrado; remova ZTC_NFC_UID ou instale libnfc"
    exit 1
  fi
  if ! nfc-list 2>/dev/null | grep -q "$ZTC_NFC_UID"; then
    echo "NTAG ausente (UID esperado: $ZTC_NFC_UID)"
    exit 1
  fi
fi

if [ ! -f "$ZTC_VAULT_HC" ]; then
  echo "Arquivo não encontrado: $ZTC_VAULT_HC"
  exit 1
fi

RSYNC_OPTS="-avz"
SSH_CMD="ssh -i $ZTC_SSH_KEY -o BatchMode=yes"

rsync $RSYNC_OPTS -e "$SSH_CMD" \
  "$ZTC_VAULT_HC" \
  "$ZTC_MANIFEST_DIR/" \
  "$ZTC_REMOTE"

REMOTE_HOST="${ZTC_REMOTE%%:*}"
REMOTE_PATH="${ZTC_REMOTE#*:}"
ssh -i "$ZTC_SSH_KEY" -o BatchMode=yes "$REMOTE_HOST" \
  "sha256sum ${REMOTE_PATH}* 2>/dev/null | tail -5" || true

echo "rsync off-site concluído."
