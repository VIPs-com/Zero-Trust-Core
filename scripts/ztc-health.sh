#!/bin/sh
# Zero Trust Core — health-check (v1)
# Curso: COMANDO 5.1 — https://github.com/VIPs-com/Zero-Trust-Core

set -u

echo "=== Zero Trust Core Health ==="

# 1) Smartcard OpenPGP
if gpg --card-status >/tmp/ztc-card.out 2>&1; then
  echo "[OK] gpg --card-status"
  grep -E '^(Serial number|URL of public)' /tmp/ztc-card.out 2>/dev/null || true
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
