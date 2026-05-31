#!/bin/sh
# Zero Trust Core — snapshot versionado local do vault.hc
# Roda automaticamente no ztc-close-cofre.sh OU manualmente OU via cron
# Curso: complemento ao COMANDO 5.3 — https://github.com/VIPs-com/Zero-Trust-Core

set -eu

CONF="${ZTC_CONF:-$HOME/ztc-backup/ztc.conf}"
if [ -f "$CONF" ]; then
  # shellcheck disable=SC1090
  . "$CONF"
fi

: "${ZTC_VAULT_HC:?Defina ZTC_VAULT_HC em $CONF}"
ZTC_MOUNT_POINT="${ZTC_MOUNT_POINT:-/media/veracrypt-ztc}"
ZTC_SNAPSHOT_DIR="${ZTC_SNAPSHOT_DIR:-$HOME/ztc-backup/snapshots}"
ZTC_SNAPSHOT_KEEP="${ZTC_SNAPSHOT_KEEP:-7}"

# 1) Cofre NAO pode estar montado — copia consistente exige fechado
if mountpoint -q "$ZTC_MOUNT_POINT" 2>/dev/null; then
  echo "[FAIL] Cofre montado — feche antes (ztc-close-cofre.sh)"
  echo "       Snapshot com vault aberto = arquivo inconsistente"
  exit 1
fi

# 2) Vault existe?
if [ ! -f "$ZTC_VAULT_HC" ]; then
  echo "[FAIL] Vault nao encontrado: $ZTC_VAULT_HC"
  exit 1
fi

# 3) Diretorio de snapshots
mkdir -p "$ZTC_SNAPSHOT_DIR"

# 4) Copia com timestamp + tamanho informativo
SIZE=$(du -h "$ZTC_VAULT_HC" | awk '{print $1}')
SNAPSHOT="$ZTC_SNAPSHOT_DIR/vault-$(date +%Y%m%d-%H%M%S).hc"
echo "Snapshot: $ZTC_VAULT_HC ($SIZE) -> $(basename "$SNAPSHOT")"
cp "$ZTC_VAULT_HC" "$SNAPSHOT"

# 5) Verificacao de integridade (sha256 origem vs copia)
SRC_HASH=$(sha256sum "$ZTC_VAULT_HC" | awk '{print $1}')
DST_HASH=$(sha256sum "$SNAPSHOT" | awk '{print $1}')
if [ "$SRC_HASH" != "$DST_HASH" ]; then
  echo "[FAIL] Hash diferente — copia corrompida (apagando)"
  rm -f "$SNAPSHOT"
  exit 1
fi
echo "[OK] sha256 confere"

# 6) Manifesto cumulativo (util para restore test do Playbook 10)
echo "$DST_HASH  $(basename "$SNAPSHOT")  $(date -Iseconds)" \
  >> "$ZTC_SNAPSHOT_DIR/MANIFEST.sha256"

# 7) Rotacao — mantem so os ultimos N (default 7)
TOTAL=$(find "$ZTC_SNAPSHOT_DIR" -maxdepth 1 -name 'vault-*.hc' | wc -l)
if [ "$TOTAL" -gt "$ZTC_SNAPSHOT_KEEP" ]; then
  REMOVE=$((TOTAL - ZTC_SNAPSHOT_KEEP))
  echo "Rotacao: removendo $REMOVE snapshot(s) antigo(s)..."
  # shellcheck disable=SC2012
  ls -1t "$ZTC_SNAPSHOT_DIR"/vault-*.hc | tail -n "$REMOVE" | while read -r old; do
    rm -v "$old"
  done
fi

KEPT=$(find "$ZTC_SNAPSHOT_DIR" -maxdepth 1 -name 'vault-*.hc' | wc -l)
TOTAL_SIZE=$(du -sh "$ZTC_SNAPSHOT_DIR" 2>/dev/null | awk '{print $1}')
echo "[OK] $KEPT snapshots mantidos ($TOTAL_SIZE total em $ZTC_SNAPSHOT_DIR)"
