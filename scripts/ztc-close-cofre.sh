#!/bin/sh
# Zero Trust Core — fechar cofre: KeePassXC + dismount VeraCrypt
# Curso: pareado com COMANDO 5.3 — https://github.com/VIPs-com/Zero-Trust-Core

set -eu

CONF="${ZTC_CONF:-$HOME/ztc-backup/ztc.conf}"
if [ -f "$CONF" ]; then
  # shellcheck disable=SC1090
  . "$CONF"
fi

ZTC_MOUNT_POINT="${ZTC_MOUNT_POINT:-/media/veracrypt-ztc}"

# 1) Verifica se KeePassXC ainda está aberto — não fechar com cofre em uso
if pgrep -x keepassxc >/dev/null 2>&1; then
  echo "[WARN] KeePassXC ainda esta aberto."
  echo "       Feche o programa antes de desmontar o cofre"
  echo "       (Database -> Save, depois File -> Quit ou Ctrl+Q)"
  echo ""
  echo "       Forcar mesmo assim? Risco de perder alteracoes nao salvas."
  printf "       Digite SIM para forcar: "
  read -r resp
  if [ "$resp" != "SIM" ]; then
    echo "[ABORTADO] Cofre permanece aberto"
    exit 1
  fi
  echo "[WARN] Matando processo keepassxc..."
  pkill -x keepassxc || true
  sleep 1
fi

# 2) Verifica se o volume está realmente montado
if ! mountpoint -q "$ZTC_MOUNT_POINT" 2>/dev/null; then
  echo "[INFO] $ZTC_MOUNT_POINT ja esta desmontado"
  exit 0
fi

# 3) Flush de escritas pendentes antes de desmontar
echo "Sincronizando escritas no disco..."
sync

# 4) Desmonta o VeraCrypt
echo "Desmontando $ZTC_MOUNT_POINT..."
veracrypt -t -d "$ZTC_MOUNT_POINT"

# 5) Confirma que fechou
if mountpoint -q "$ZTC_MOUNT_POINT" 2>/dev/null; then
  echo "[FAIL] Volume ainda montado — verifique processos com acesso ao mount point:"
  echo "       lsof +D $ZTC_MOUNT_POINT  (ou fuser -m $ZTC_MOUNT_POINT)"
  exit 1
fi

echo "[OK] Cofre fechado — todas as camadas seladas"

# 6) Snapshot automatico apos fechar (default ligado, controle no ztc.conf)
ZTC_AUTO_SNAPSHOT="${ZTC_AUTO_SNAPSHOT:-yes}"
if [ "$ZTC_AUTO_SNAPSHOT" = "yes" ]; then
  SNAP_SCRIPT="$(dirname "$0")/ztc-snapshot-vault.sh"
  if [ -x "$SNAP_SCRIPT" ]; then
    echo ""
    echo "--- Snapshot automatico do vault ---"
    "$SNAP_SCRIPT" || echo "[WARN] Snapshot falhou — vault esta fechado, mas sem versao nova"
  else
    echo "[INFO] Snapshot script ausente em $SNAP_SCRIPT (ignorando)"
  fi
fi
