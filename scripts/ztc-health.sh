#!/bin/sh
# Zero Trust Core — health-check (v1)
# Curso: COMANDO 5.1 — https://github.com/VIPs-com/Zero-Trust-Core

set -u

ztc_check_conf() {
  CONF="${ZTC_CONF:-$HOME/ztc-backup/ztc.conf}"
  ERR=0

  echo "=== Zero Trust Core — check-conf ==="

  if [ ! -f "$CONF" ]; then
    echo "[FAIL] $CONF ausente — copie scripts/ztc.conf.example"
    return 1
  fi
  echo "[OK] conf: $CONF"
  # shellcheck disable=SC1090
  . "$CONF"

  if [ -z "${ZTC_VAULT_HC:-}" ]; then
    echo "[FAIL] ZTC_VAULT_HC nao definido"
    ERR=1
  elif [ -f "$ZTC_VAULT_HC" ]; then
    echo "[OK] ZTC_VAULT_HC existe: $ZTC_VAULT_HC"
  else
    echo "[WARN] ZTC_VAULT_HC ainda nao existe (crie no COMANDO 3.1.1): $ZTC_VAULT_HC"
  fi

  if [ -z "${ZTC_REMOTE:-}" ]; then
    echo "[WARN] ZTC_REMOTE vazio (rsync off-site desativado)"
  else
    echo "[OK] ZTC_REMOTE=$ZTC_REMOTE"
  fi

  if [ -n "${ZTC_NFC_UID:-}" ]; then
    case "$ZTC_NFC_UID" in
      *:*:*:*) echo "[OK] ZTC_NFC_UID formato plausivel: $ZTC_NFC_UID" ;;
      *) echo "[FAIL] ZTC_NFC_UID deve parecer UID NFC (ex.: 04:ab:cd:...): $ZTC_NFC_UID"; ERR=1 ;;
    esac
    if ! command -v nfc-list >/dev/null 2>&1; then
      echo "[WARN] ZTC_NFC_UID definido mas nfc-list ausente"
    fi
  else
    echo "[INFO] ZTC_NFC_UID vazio — checagem NFC desligada (OK para Turbo/manual)"
  fi

  for var in ZTC_MOUNT_POINT ZTC_KDBX ZTC_KEYFILE; do
    eval "val=\${$var:-}"
    if [ -n "$val" ]; then
      echo "[OK] $var=$val"
    fi
  done

  if [ -n "${ZTC_MANIFEST_DIR:-}" ] && [ ! -d "$ZTC_MANIFEST_DIR" ]; then
    echo "[WARN] ZTC_MANIFEST_DIR nao existe — mkdir -p $ZTC_MANIFEST_DIR"
  fi

  if [ "$ERR" -eq 0 ]; then
    echo "=== check-conf: OK (revise [WARN]) ==="
    return 0
  fi
  echo "=== check-conf: FAIL ==="
  return 1
}

if [ "${1:-}" = "--check-conf" ]; then
  ztc_check_conf
  exit $?
fi

echo "=== Zero Trust Core Health ==="
ztc_check_conf || true

# 1) Smartcard OpenPGP
CARD_TMP=$(mktemp /tmp/ztc-card.XXXXXX)
trap 'rm -f "$CARD_TMP"' EXIT INT TERM
if gpg --card-status >"$CARD_TMP" 2>&1; then
  echo "[OK] gpg --card-status"
  grep -E '^(Serial number|URL of public)' "$CARD_TMP" 2>/dev/null || true
else
  echo "[FAIL] smartcard — pcscd ativo? cartão inserido?"
fi

# 2) Agente SSH
if command -v gpgconf >/dev/null 2>&1; then
  export SSH_AUTH_SOCK
  SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket 2>/dev/null) || SSH_AUTH_SOCK=
  if [ -n "$SSH_AUTH_SOCK" ] && ssh-add -L >/dev/null 2>&1; then
    echo "[OK] ssh-add -L"
  else
    echo "[WARN] nenhuma chave SSH no agente"
  fi
else
  echo "[WARN] gpgconf ausente"
fi

# 3) NFC (opcional)
if command -v nfc-list >/dev/null 2>&1; then
  nfc-list 2>/dev/null | head -5 || echo "[WARN] nfc-list sem tag"
fi

# 4) Último manifesto
MANIFEST=$(ls -t "$HOME/ztc-backup/manifest/"*.sha256 2>/dev/null | head -1)
if [ -n "$MANIFEST" ]; then
  if stat -c %y "$MANIFEST" >/dev/null 2>&1; then
    echo "Último manifesto: $MANIFEST ($(stat -c %y "$MANIFEST"))"
  else
    echo "Último manifesto: $MANIFEST ($(stat -f %Sm "$MANIFEST" 2>/dev/null || echo '?'))"
  fi
else
  echo "[WARN] sem manifesto em ~/ztc-backup/manifest/"
fi

echo "=== fim ==="
