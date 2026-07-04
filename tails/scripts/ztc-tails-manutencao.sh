#!/bin/sh
# Zero Trust Core — manutencao e diagnostico do pendrive Tails
# Curso: complemento ao COMANDO T.5 — https://github.com/VIPs-com/Zero-Trust-Core
# Rodar mensalmente ou quando suspeitar de problema no pendrive.
#
# Requer: senha de administracao ativa no Tails (sudo)
# Verifica: espaco, integridade filesystem, saude do flash, limpeza

set -u

PERSISTENT="${ZTC_TAILS_PERSISTENT:-$HOME/Persistent}"
WARN=0
FAIL=0

echo "=============================================="
echo "  Zero Trust Core — Manutencao Tails"
echo "  $(date '+%Y-%m-%d %H:%M')"
echo "=============================================="
echo ""

# --- 1) Espaco no Persistent Storage ---
echo "--- 1. Espaco em disco ---"
if mountpoint -q "$PERSISTENT" 2>/dev/null; then
  DISK_INFO=$(df -h "$PERSISTENT" | tail -1)
  USED_PCT=$(echo "$DISK_INFO" | awk '{print $5}' | tr -d '%')
  AVAIL=$(echo "$DISK_INFO" | awk '{print $4}')
  TOTAL=$(echo "$DISK_INFO" | awk '{print $2}')

  if [ "$USED_PCT" -ge 90 ]; then
    echo "[FAIL] Persistent Storage $USED_PCT%% cheio ($AVAIL livres de $TOTAL)"
    echo "       Risco: KeePassXC pode falhar ao salvar, backups impossíveis"
    FAIL=1
  elif [ "$USED_PCT" -ge 75 ]; then
    echo "[WARN] Persistent Storage $USED_PCT%% cheio ($AVAIL livres de $TOTAL)"
    echo "       Considere limpar arquivos desnecessarios"
    WARN=1
  else
    echo "[OK] Persistent Storage $USED_PCT%% usado ($AVAIL livres de $TOTAL)"
  fi

  # Top 5 maiores diretorios
  echo ""
  echo "Maiores diretorios em ~/Persistent/:"
  du -sh "$PERSISTENT"/*/ 2>/dev/null | sort -rh | head -5
else
  echo "[FAIL] Persistent Storage nao montado"
  FAIL=1
fi

echo ""

# --- 2) Integridade do filesystem ---
echo "--- 2. Integridade do filesystem ---"
TAILS_PART=""
if [ -b /dev/disk/by-partlabel/TailsData ]; then
  TAILS_PART="/dev/disk/by-partlabel/TailsData"
elif lsblk -no NAME,LABEL 2>/dev/null | grep -q TailsData; then
  TAILS_PART="/dev/$(lsblk -no NAME,LABEL 2>/dev/null | grep TailsData | awk '{print $1}')"
fi

if [ -n "$TAILS_PART" ]; then
  # LUKS: verificar que o volume abre sem erros
  LUKS_MAPPER=$(findmnt -n -o SOURCE "$PERSISTENT" 2>/dev/null | head -1)
  if [ -n "$LUKS_MAPPER" ]; then
    echo "[OK] LUKS mapeado em: $LUKS_MAPPER"
    # Verificar filesystem (modo somente-leitura — nao corrige)
    if command -v sudo >/dev/null 2>&1; then
      echo "     Verificando filesystem (somente-leitura)..."
      if sudo fsck -n "$LUKS_MAPPER" 2>&1 | grep -qi "clean"; then
        echo "[OK] Filesystem limpo (sem erros)"
      elif sudo fsck -n "$LUKS_MAPPER" 2>&1 | grep -qi "error\|corrupt\|bad"; then
        echo "[FAIL] Filesystem com ERROS detectados!"
        echo "       Faca backup IMEDIATO (Playbook T03) antes de tentar reparar"
        echo "       Reparar: bootar outro Tails → sudo fsck /dev/... (SEM montar)"
        FAIL=1
      else
        echo "[INFO] fsck executado — verifique a saida manualmente"
        sudo fsck -n "$LUKS_MAPPER" 2>&1 | tail -3
      fi
    else
      echo "[SKIP] sudo nao disponivel — ative senha admin para verificar filesystem"
    fi
  else
    echo "[WARN] Nao foi possivel identificar o mapeamento LUKS"
    WARN=1
  fi
else
  echo "[SKIP] Particao TailsData nao encontrada"
fi

echo ""

# --- 3) Saude do pendrive (flash USB) ---
echo "--- 3. Saude do pendrive ---"

# Identificar o dispositivo USB do Tails
TAILS_DEV=""
if [ -b /dev/disk/by-partlabel/TailsData ]; then
  # Pegar o disco pai (ex: sda de sda2)
  PART_DEV=$(readlink -f /dev/disk/by-partlabel/TailsData)
  TAILS_DEV=$(echo "$PART_DEV" | sed 's/[0-9]*$//')
fi

if [ -n "$TAILS_DEV" ] && [ -b "$TAILS_DEV" ]; then
  echo "Dispositivo Tails: $TAILS_DEV"

  # SMART (se disponivel — maioria dos pendrives NAO suporta)
  if command -v smartctl >/dev/null 2>&1 && command -v sudo >/dev/null 2>&1; then
    SMART_OUT=$(sudo smartctl -i "$TAILS_DEV" 2>&1 || true)
    if echo "$SMART_OUT" | grep -qi "SMART support is: Available"; then
      echo "[INFO] SMART disponivel — executando diagnostico..."
      sudo smartctl -H "$TAILS_DEV" 2>&1 | grep -i "result\|health\|status" || true

      # Verificar reallocated sectors (setores remapeados = flash morrendo)
      REALLOC=$(sudo smartctl -A "$TAILS_DEV" 2>&1 | grep -i "Reallocated" | awk '{print $NF}')
      if [ -n "$REALLOC" ] && [ "$REALLOC" -gt 0 ] 2>/dev/null; then
        echo "[WARN] $REALLOC setores remapeados — flash com desgaste"
        echo "       Considere trocar o pendrive em breve"
        WARN=1
      fi
    else
      echo "[INFO] SMART nao suportado por este pendrive (normal para USB flash)"
    fi
  else
    echo "[INFO] smartctl nao disponivel (instale smartmontools como Additional Software)"
  fi

  # Teste rapido de leitura (detecta bad blocks sem destruir dados)
  if command -v sudo >/dev/null 2>&1; then
    echo ""
    echo "Teste rapido de leitura (10 blocos aleatorios)..."
    READ_ERRORS=0
    BLOCKS=$(sudo blockdev --getsz "$TAILS_DEV" 2>/dev/null || echo "0")
    if [ "$BLOCKS" -gt 100 ]; then
      i=0
      while [ $i -lt 10 ]; do
        OFFSET=$(($(od -An -N4 -tu4 /dev/urandom | tr -d ' ') % (BLOCKS - 1)))
        if ! sudo dd if="$TAILS_DEV" of=/dev/null bs=512 count=1 skip="$OFFSET" 2>/dev/null; then
          READ_ERRORS=$((READ_ERRORS + 1))
        fi
        i=$((i + 1))
      done
      if [ "$READ_ERRORS" -gt 0 ]; then
        echo "[FAIL] $READ_ERRORS erros de leitura em 10 testes!"
        echo "       Pendrive pode estar morrendo — BACKUP IMEDIATO + trocar pendrive"
        FAIL=1
      else
        echo "[OK] 10/10 leituras aleatorias sem erro"
      fi
    else
      echo "[SKIP] Nao foi possivel obter tamanho do disco"
    fi
  fi
else
  echo "[SKIP] Dispositivo Tails nao identificado"
fi

echo ""

# --- 4) Limpeza ---
echo "--- 4. Limpeza ---"

# Cache do apt
APT_CACHE_SIZE=$(du -sh /var/cache/apt/archives/ 2>/dev/null | awk '{print $1}')
if [ -n "$APT_CACHE_SIZE" ] && [ "$APT_CACHE_SIZE" != "0" ]; then
  echo "[INFO] Cache apt: $APT_CACHE_SIZE"
  echo "       Limpar com: sudo apt clean"
else
  echo "[OK] Cache apt limpo"
fi

# Arquivos temporarios do usuario
TMP_SIZE=$(du -sh /tmp/ 2>/dev/null | awk '{print $1}')
echo "[INFO] /tmp/ usando: $TMP_SIZE (sera limpo no shutdown)"

# Thumbnails e cache do usuario
USER_CACHE=$(du -sh "$HOME/.cache/" 2>/dev/null | awk '{print $1}')
if [ -n "$USER_CACHE" ]; then
  echo "[INFO] Cache do usuario (~/.cache/): $USER_CACHE"
fi

# Verificar se ha arquivos grandes fora do Persistent
LARGE_FILES=$(find "$HOME" -maxdepth 2 -not -path "$PERSISTENT/*" -size +10M -type f 2>/dev/null)
if [ -n "$LARGE_FILES" ]; then
  echo "[WARN] Arquivos grandes fora do Persistent (serao perdidos no shutdown):"
  echo "$LARGE_FILES" | head -5
  WARN=1
fi

echo ""

# --- 5) Vida util estimada do pendrive ---
echo "--- 5. Vida util do pendrive ---"
echo ""
echo "Pendrives USB flash tem vida util limitada (tipicamente 3.000-10.000 ciclos de escrita)."
echo "Sinais de que o pendrive esta morrendo:"
echo "  • Boot do Tails fica mais lento ao longo dos meses"
echo "  • Erros de leitura/escrita esporadicos"
echo "  • Arquivos corrompidos sem explicacao"
echo "  • KeePassXC falha ao salvar com 'I/O error'"
echo "  • fsck encontra erros repetidamente"
echo ""
echo "Recomendacoes:"
echo "  • Trocar o pendrive Tails a cada 2-3 anos (mesmo sem sintomas)"
echo "  • Manter clone atualizado (T0.7) para migrar rapidamente"
echo "  • Usar pendrives de qualidade (USB 3.0, marcas confiáveis)"
echo "  • Pendrives SLC/MLC duram mais que TLC/QLC (mais caros)"

echo ""

# --- Resultado ---
echo "=============================================="
if [ "$FAIL" -ne 0 ]; then
  echo "  RESULTADO: PROBLEMAS DETECTADOS"
  echo "  Corrija os itens [FAIL] acima."
  echo "  Se pendrive estiver morrendo: BACKUP IMEDIATO (Playbook T03)"
  echo "=============================================="
  exit 1
elif [ "$WARN" -ne 0 ]; then
  echo "  RESULTADO: OK com avisos"
  echo "  Revise os itens [WARN] acima."
  echo "=============================================="
else
  echo "  RESULTADO: TUDO OK"
  echo "  Proximo check: daqui a 1 mes"
  echo "=============================================="
fi
