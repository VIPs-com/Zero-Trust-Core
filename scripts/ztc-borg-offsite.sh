#!/bin/sh
# Zero Trust Core — off-site IMUTÁVEL (append-only) com BorgBackup
# Curso: a perna "1 imutável" do 3-2-1-1-0 — https://github.com/VIPs-com/Zero-Trust-Core
#
# Por que borg e nao so rsync:
#   rsync-offsite ESPELHA — se o vault.hc local for cifrado por ransomware
#   e sincronizado, a copia da VM e sobrescrita (perda do historico).
#   Borg em modo APPEND-ONLY guarda VERSOES e NEM ESTE HOST pode apagar as
#   antigas: mesmo comprometido, o cliente so consegue ADICIONAR. Esse e o
#   padrao-ouro da imutabilidade off-site.
#
# ----------------------------------------------------------------------------
# SETUP NA VM (uma vez) — torna o repo append-only para ESTE cliente:
#   No ~/.ssh/authorized_keys da conta ztc-bkp, prefixe a chave com:
#     command="borg serve --append-only --restrict-to-path /home/ztc-bkp/borg-ztc",restrict ssh-ed25519 AAAA... ztc
#   Assim a chave SO serve borg, SO no caminho do repo, e SO em append-only.
#   (Mesmo principio do command="rrsync ..." do rsync-offsite — Auditoria A1.)
#
# INIT DO REPO (uma vez, no cliente):
#   export BORG_RSH="ssh -i ~/.ssh/ztc-bkp-ed25519 -o StrictHostKeyChecking=yes"
#   borg init --encryption=repokey-blake2 "ssh://ztc-bkp@10.66.66.1/~/borg-ztc"
#   >>> GUARDE A PASSPHRASE FORA do vault que o borg protege (papel / midia air-gap / 2o
#       gerenciador). So no KeePassXC DENTRO do vault = dependencia circular: perdeu o vault,
#       perdeu a passphrase, nao restaura. Sem a passphrase, o backup e IRRECUPERAVEL.
#
# RETENCAO (rotacao real): em append-only, o CLIENTE nao apaga. Quem recupera
#   espaco e um job no SERVIDOR (admin), periodicamente, FORA do modo append-only:
#     borg prune --keep-daily=7 --keep-weekly=8 --keep-monthly=12 /home/ztc-bkp/borg-ztc
#     borg compact /home/ztc-bkp/borg-ztc
#   Rode isso na VM (cron mensal), nao aqui — e o que mantem a imutabilidade.
#
# NOTA de espaco: vault.hc ja e um blob VeraCrypt (cifrado/incompressivel), entao
#   a deduplicacao do borg quase nao ajuda — cada versao ~ tamanho cheio. O ganho
#   aqui e VERSIONAMENTO + APPEND-ONLY + integridade (borg check), nao economia.
#   O borg adiciona sua propria cifra (repokey) por cima — defesa em profundidade;
#   a VM continua vendo SO blobs ja cifrados (regra de ouro do off-site preservada).
# ----------------------------------------------------------------------------

set -eu

CONF="${ZTC_CONF:-$HOME/ztc-backup/ztc.conf}"
if [ -f "$CONF" ]; then
  # shellcheck disable=SC1090
  . "$CONF"
fi

: "${ZTC_BORG_REPO:?Defina ZTC_BORG_REPO em $CONF (ex.: ssh://ztc-bkp@10.66.66.1/~/borg-ztc)}"
: "${ZTC_SSH_KEY:?Defina ZTC_SSH_KEY em $CONF}"
: "${ZTC_VAULT_HC:?Defina ZTC_VAULT_HC em $CONF}"

ZTC_MANIFEST_DIR="${ZTC_MANIFEST_DIR:-$HOME/ztc-backup/manifest}"

command -v borg >/dev/null 2>&1 || { echo "[FAIL] borg ausente — sudo apt install borgbackup"; exit 1; }

# NFC guard opcional (mesmo padrao do rsync-offsite)
if [ -n "${ZTC_NFC_UID:-}" ]; then
  if ! command -v nfc-list >/dev/null 2>&1; then
    echo "[FAIL] nfc-list ausente; remova ZTC_NFC_UID ou instale libnfc"
    exit 1
  fi
  if ! nfc-list 2>/dev/null | grep -qF "$ZTC_NFC_UID"; then
    echo "[FAIL] NTAG ausente (UID esperado: $ZTC_NFC_UID)"
    exit 1
  fi
  echo "[OK] NTAG presente"
fi

[ -f "$ZTC_VAULT_HC" ] || { echo "[FAIL] Vault nao encontrado: $ZTC_VAULT_HC"; exit 1; }

# StrictHostKeyChecking=yes: falha ruidosa se a chave do servidor mudar (anti-MITM).
export BORG_REPO="$ZTC_BORG_REPO"
export BORG_RSH="ssh -i $ZTC_SSH_KEY -o BatchMode=yes -o StrictHostKeyChecking=yes"

# Passphrase: por padrao o borg PERGUNTA (interativo). Para cron, defina
# BORG_PASSCOMMAND no ambiente (ex.: ler do KeePassXC/secret-tool). NUNCA
# escreva a passphrase no ztc.conf.

# Repo acessivel e inicializado?
if ! borg list >/dev/null 2>&1; then
  echo "[FAIL] Repo borg inacessivel ou nao inicializado: $ZTC_BORG_REPO"
  echo "       Init (uma vez): borg init --encryption=repokey-blake2 \"$ZTC_BORG_REPO\""
  echo "       E GUARDE a passphrase FORA do vault (papel/air-gap) — so no vault = circular."
  exit 1
fi

ARCHIVE="vault-{now:%Y%m%d-%H%M%S}"
echo "Criando archive append-only: $ARCHIVE"

# auto,zstd: comprime o que der, pula o que ja e incompressivel (o vault.hc).
# if/else: trata exit 1 (aviso, ex.: arquivo mudou) sem abortar via set -e.
if borg create --stats --compression auto,zstd \
     "::$ARCHIVE" "$ZTC_VAULT_HC" "$ZTC_MANIFEST_DIR"; then
  echo "[OK] Archive criado — append-only: nem este host apaga versoes antigas."
else
  rc=$?
  if [ "$rc" -eq 1 ]; then
    echo "[WARN] borg create terminou com aviso (rc=1) — archive provavelmente OK, revise acima"
  else
    echo "[FAIL] borg create falhou (rc=$rc)"
    exit "$rc"
  fi
fi

echo "--- Archives no repo (historico imutavel) ---"
borg list

# Verificacao de integridade opcional (read-only; pode ser lenta em repos grandes)
if [ "${ZTC_BORG_CHECK:-no}" = "yes" ]; then
  echo "--- borg check (integridade) ---"
  borg check && echo "[OK] Integridade do repo verificada" || echo "[WARN] borg check reportou problemas — investigue"
fi

echo "borg off-site concluído."
