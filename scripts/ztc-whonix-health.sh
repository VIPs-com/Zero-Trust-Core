#!/bin/sh
# Zero Trust Core — health check para Whonix-Workstation (manual, por sessao)
# Guia: whonix/ — https://github.com/VIPs-com/Zero-Trust-Core
# Rodar no inicio de cada sessao na Whonix-Workstation.
#
# NAO substitui o `systemcheck` oficial do Whonix — complementa, focando
# na camada Zero Trust Core (subkeys, gpg-agent, ferramentas).
#
# Env (todas opcionais):
#   ZTC_WHONIX_TOR_CHECK=yes   -> faz checagem viva via check.torproject.org (lenta)

set -u

FAIL=0
WARN=0

echo "=== Zero Trust Core — Whonix Health ==="

# 0) Confirmar que estamos numa Whonix-Workstation (best-effort, multiplos sinais)
WHONIX=""
if grep -qiE 'whonix|kicksecure' /etc/os-release 2>/dev/null; then WHONIX="yes"; fi
if [ -z "$WHONIX" ] && [ -d /usr/share/anon-dist ]; then WHONIX="yes"; fi
if [ -z "$WHONIX" ] && command -v systemcheck >/dev/null 2>&1; then WHONIX="yes"; fi
if [ -n "$WHONIX" ]; then
  echo "[OK] Ambiente Whonix/Kicksecure detectado"
else
  echo "[WARN] Nao confirmei o ambiente — rode este script numa Whonix-Workstation"
  WARN=1
fi

# 1) Tor / conectividade — a autoridade e o systemcheck oficial do Whonix
if command -v systemcheck >/dev/null 2>&1; then
  echo "[INFO] Rode 'systemcheck' para o teste oficial de Tor/conexao do Whonix"
else
  echo "[WARN] systemcheck ausente (esperado no Whonix) — confirme o ambiente"
  WARN=1
fi

# 1b) Checagem viva de Tor (opcional — depende de rede; pode ser lenta)
if [ "${ZTC_WHONIX_TOR_CHECK:-no}" = "yes" ] && command -v curl >/dev/null 2>&1; then
  if curl -s --max-time 30 https://check.torproject.org/api/ip 2>/dev/null | grep -q '"IsTor":true'; then
    echo "[OK] check.torproject.org confirma saida via Tor"
  else
    echo "[WARN] Nao confirmei saida via Tor (rede lenta? reconectando?) — rode systemcheck"
    WARN=1
  fi
else
  echo "[SKIP] Checagem viva de Tor desativada (ZTC_WHONIX_TOR_CHECK=yes para ativar)"
fi

# 2) GPG subkeys — a MASTER deve estar AUSENTE (sec#). Master online = falha grave.
if ! command -v gpg >/dev/null 2>&1; then
  echo "[FAIL] gpg nao encontrado — sudo apt install gnupg"
  FAIL=1
elif gpg -K --with-colons 2>/dev/null | grep -q '^sec:'; then
  if gpg -K 2>/dev/null | grep -q 'sec#'; then
    echo "[OK] gpg -K — subkeys presentes (sec# = master ausente, correto)"
  else
    echo "[FAIL] gpg -K — MASTER key presente! No Whonix so devem existir subkeys (sec#)"
    echo "       A master nunca sai do Tails air-gap — reimporte SO as subkeys (Playbook W02)"
    FAIL=1
  fi
else
  echo "[WARN] Nenhuma chave secreta no keyring — importe subkeys do USB (Playbook W02)"
  WARN=1
fi

# 3) gpg-agent com suporte SSH (subchave [A]) — opcional
if [ -s "$HOME/.gnupg/sshcontrol" ]; then
  echo "[OK] sshcontrol configurado (SSH via subchave [A])"
else
  echo "[SKIP] sshcontrol vazio/ausente — configure se for usar SSH (W02 passo 6)"
fi

# 4) age (para abrir backups/subkeys cifrados vindos do Tails)
if command -v age >/dev/null 2>&1; then
  echo "[OK] age instalado"
else
  echo "[WARN] age ausente — sudo apt install age (para abrir blobs do Tails)"
  WARN=1
fi

# 5) Lembrete: atualizar as DUAS VMs (Gateway e Workstation)
echo "[INFO] Mantenha Gateway E Workstation atualizados: sudo apt update && sudo apt full-upgrade"

# --- Resultado ---
if [ "$FAIL" -ne 0 ]; then
  echo "=== Whonix Health: FAIL — corrija os erros acima ==="
  exit 1
elif [ "$WARN" -ne 0 ]; then
  echo "=== Whonix Health: OK com avisos — revise [WARN] acima ==="
else
  echo "=== Whonix Health: OK ==="
fi
