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
  # Camadas opcionais do VeraCrypt — definidas no ztc.conf
  # (PIM, keyfile extra, volume oculto). Defaults: todas desligadas.
  ZTC_VC_PIM="${ZTC_VC_PIM:-0}"
  ZTC_VC_KEYFILES="${ZTC_VC_KEYFILES:-}"
  ZTC_VC_PROTECT_HIDDEN="${ZTC_VC_PROTECT_HIDDEN:-no}"

  # Mostra quais camadas extras estao ativas (transparencia ao aluno)
  vc_extras=""
  [ "$ZTC_VC_PIM" != "0" ]              && vc_extras="${vc_extras} PIM=$ZTC_VC_PIM"
  [ -n "$ZTC_VC_KEYFILES" ]             && vc_extras="${vc_extras} keyfile-vc"
  [ "$ZTC_VC_PROTECT_HIDDEN" = "yes" ]  && vc_extras="${vc_extras} hidden-volume"
  if [ -n "$vc_extras" ]; then
    echo "[INFO] VeraCrypt camadas extras ativas:$vc_extras"
    echo "Montando $ZTC_VAULT_HC em $ZTC_MOUNT_POINT (senha + camadas acima)..."
  else
    echo "Montando $ZTC_VAULT_HC em $ZTC_MOUNT_POINT (modo Turbo — so a senha)..."
  fi

  sudo mkdir -p "$ZTC_MOUNT_POINT"
  veracrypt -t \
    --pim="$ZTC_VC_PIM" \
    --keyfiles="$ZTC_VC_KEYFILES" \
    --protect-hidden="$ZTC_VC_PROTECT_HIDDEN" \
    "$ZTC_VAULT_HC" "$ZTC_MOUNT_POINT"
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
    # exec intencional: script vira o KeePassXC (sem cleanup pendente)
    # Se adicionar cleanup pos-KeePassXC, trocar exec por chamada direta
    exec keepassxc "$ZTC_KDBX"
    ;;
esac
