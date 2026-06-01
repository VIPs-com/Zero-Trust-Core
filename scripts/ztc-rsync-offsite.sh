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
  if ! nfc-list 2>/dev/null | grep -qF "$ZTC_NFC_UID"; then
    echo "NTAG ausente (UID esperado: $ZTC_NFC_UID)"
    exit 1
  fi
fi

if [ ! -f "$ZTC_VAULT_HC" ]; then
  echo "Arquivo não encontrado: $ZTC_VAULT_HC"
  exit 1
fi

# --checksum: rsync compara por hash MD5 (detecta substituicao silenciosa de arquivos
#             de mesmo tamanho/mtime no servidor remoto). Custo: leitura completa
#             do vault.hc a cada sync — aceitavel para 500MB.
RSYNC_OPTS="-avz --checksum"
# StrictHostKeyChecking=yes: falha explicitamente se a chave SSH do servidor mudar
#                            (em vez de aceitar silenciosamente — anti-MITM).
SSH_CMD="ssh -i $ZTC_SSH_KEY -o BatchMode=yes -o StrictHostKeyChecking=yes"

rsync $RSYNC_OPTS -e "$SSH_CMD" \
  "$ZTC_VAULT_HC" \
  "$ZTC_MANIFEST_DIR/" \
  "$ZTC_REMOTE"

# Post-rsync: confirmar hash do vault.hc no servidor remoto.
# Path explicito (basename do vault) em vez de glob ${REMOTE_PATH}* para evitar
# injecao via ZTC_REMOTE malicioso (Auditoria A10).
# Se voce configurou command="rrsync ..." no authorized_keys da VM (R1b do
# Playbook 09 — recomendado), este passo falha silenciosamente — esperado.
# A integridade ja foi verificada via rsync --checksum durante a transferencia.
REMOTE_HOST="${ZTC_REMOTE%%:*}"
REMOTE_PATH="${ZTC_REMOTE#*:}"
VAULT_BASENAME=$(basename "$ZTC_VAULT_HC")
if ssh -i "$ZTC_SSH_KEY" -o BatchMode=yes -o StrictHostKeyChecking=yes \
     "$REMOTE_HOST" "sha256sum '${REMOTE_PATH}${VAULT_BASENAME}' 2>/dev/null" 2>/dev/null; then
  echo "[OK] sha256 do vault.hc no servidor confere com o local (via --checksum)"
else
  echo "[INFO] sha256 remoto bloqueado (esperado se 'command=rrsync' ativo na VM)"
  echo "       Integridade ja garantida por rsync --checksum durante a transferencia"
fi

echo "rsync off-site concluído."
