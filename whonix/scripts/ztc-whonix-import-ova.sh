#!/usr/bin/env bash
#
# ztc-whonix-import-ova.sh — Zero Trust Core
#
# Automação do Playbook W01 — Instalar Whonix (Gateway + Workstation).
# Guia: whonix/playbooks/W01-instalar-whonix.md
# Importa a chave de assinatura, VERIFICA o fingerprint contra o valor
# informado (nunca fixo no script — pegue sempre da fonte oficial:
# https://www.whonix.org/wiki/Verify_the_images),
# verifica a assinatura do .ova e importa no VirtualBox.
#
# Por design, este script NÃO automatiza:
#   - o Anon Connection Wizard (interativo, dentro do Gateway)
#   - o systemcheck / teste de vazamento (dentro da Workstation)
#   - o apt update/full-upgrade dentro das VMs
# Esses passos exigem verificação humana dentro do guest e são a essência
# do modelo anti-vazamento do Whonix — o script apenas orienta o operador.
#
# Uso:
#   sudo ./ztc-whonix-import-ova.sh \
#        -i /caminho/Whonix-LXQt-18.1.4.2.Intel_AMD64.ova \
#        -s /caminho/Whonix-LXQt-18.1.4.2.Intel_AMD64.ova.asc \
#        -k /caminho/derivative.asc \
#        -f "AAAA BBBB CCCC DDDD EEEE  FFFF 0000 1111 2222 3333" \
#        [-b]   # também inicia Gateway e depois Workstation
#        [-t lxqt|cli]  # variante esperada; se omitido, detecta pelo nome do arquivo
#        [-y]   # não pede confirmação
#
# Log: /var/log/whonix-install.log
#
# Changelog jul/2026 (espelho Privacy-OS-Hub v1.0.9.1):
#   - log() em stderr; tee de gpg/VBoxManage em stderr
#   - verify_signature: VALIDSIG + fingerprint (não "Good signature")
#   - EXPKEYSIG tratado; fetch_url com retry se -k omitido (opcional)

set -euo pipefail

# ----------------------------- Configuração ------------------------------

OVA_FILE=""
SIG_FILE=""
KEY_FILE=""
VARIANT=""
EXPECTED_FPR=""
BOOT_VMS=0
ASSUME_YES=0
LOG_FILE="/var/log/whonix-install.log"
GNUPGHOME_DIR=""
DERIVATIVE_URL="https://www.whonix.org/keys/derivative.asc"
DOWNLOADED_KEY=0

# ------------------------------- Funções ----------------------------------

# stderr: não poluir stdout em capturas $(...)
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE" >&2
}

fetch_url() {
    local url="$1" dest="$2" tries="${3:-3}"
    local n
    for ((n=1; n<=tries; n++)); do
        if curl -fsSL --max-time 120 -o "$dest" "$url" && [[ -s "$dest" ]]; then
            return 0
        fi
        log "AVISO: download falhou (tentativa ${n}/${tries}): $url"
        sleep 5
    done
    return 1
}

fail() {
    log "ERRO: $*"
    cleanup
    exit 1
}

cleanup() {
    if [[ -n "$GNUPGHOME_DIR" && -d "$GNUPGHOME_DIR" ]]; then
        rm -rf "$GNUPGHOME_DIR"
    fi
    if [[ "$DOWNLOADED_KEY" -eq 1 && -n "$KEY_FILE" && -f "$KEY_FILE" ]]; then
        rm -f "$KEY_FILE"
    fi
}
trap cleanup EXIT

usage() {
    grep '^#' "$0" | sed -e 's/^#//' -e '1d'
    exit 1
}

confirm() {
    if [[ "$ASSUME_YES" -eq 1 ]]; then
        return 0
    fi
    read -r -p "$1 [s/N] " resp
    [[ "$resp" =~ ^[sSyY]$ ]]
}

require_vboxmanage() {
    command -v VBoxManage >/dev/null 2>&1 \
        || fail "VBoxManage não encontrado. Rode ztc-whonix-install-virtualbox.sh ou playbook W00 primeiro."
}

validate_inputs() {
    [[ -n "$OVA_FILE"      ]] || fail "Informe o arquivo .ova com -i."
    [[ -n "$SIG_FILE"      ]] || fail "Informe o arquivo de assinatura (.asc/.sig) com -s."
    [[ -n "$EXPECTED_FPR"  ]] || fail "Informe o fingerprint esperado com -f (pegue de https://www.whonix.org/wiki/Verify_the_images)."

    [[ -f "$OVA_FILE" ]] || fail "Arquivo .ova não encontrado: $OVA_FILE"
    [[ -f "$SIG_FILE" ]] || fail "Arquivo de assinatura não encontrado: $SIG_FILE"

    # -k obrigatório na política ZTC; se omitido, baixa derivative.asc com retry (conveniência)
    if [[ -z "$KEY_FILE" ]]; then
        KEY_FILE="$(mktemp)"
        DOWNLOADED_KEY=1
        log "AVISO: -k omitido — baixando derivative.asc de whonix.org (confira fingerprint com -f)."
        fetch_url "$DERIVATIVE_URL" "$KEY_FILE" || fail "Falha ao baixar derivative.asc após 3 tentativas"
    fi
    [[ -f "$KEY_FILE" ]] || fail "Arquivo de chave não encontrado: $KEY_FILE"
}

# Detecta ou valida a variante (lxqt = GUI, cli = sem GUI) a partir do
# nome do arquivo. Puramente informativo/orientativo — não altera o fluxo
# de verificação de assinatura, só ajuda o operador a confirmar que baixou
# o arquivo certo para o uso pretendido.
detect_or_validate_variant() {
    local basename_ova detected=""
    basename_ova="$(basename "$OVA_FILE")"

    if echo "$basename_ova" | grep -qi "lxqt"; then
        detected="lxqt"
    elif echo "$basename_ova" | grep -qi "cli"; then
        detected="cli"
    elif echo "$basename_ova" | grep -qi "xfce"; then
        log "AVISO: o nome do arquivo sugere a variante Xfce, DESCONTINUADA pelo projeto Whonix. A variante atual com GUI é LXQt (ex.: Whonix-LXQt-<versão>.Intel_AMD64.ova). Confirme na página oficial: https://www.whonix.org/wiki/VirtualBox"
    fi

    if [[ -n "$VARIANT" ]]; then
        VARIANT="$(echo "$VARIANT" | tr '[:upper:]' '[:lower:]')"
        if [[ "$VARIANT" != "lxqt" && "$VARIANT" != "cli" ]]; then
            fail "Valor inválido para -t: '$VARIANT' (use 'lxqt' ou 'cli')."
        fi
        if [[ -n "$detected" && "$detected" != "$VARIANT" ]]; then
            log "AVISO: -t indicou '$VARIANT' mas o nome do arquivo sugere '$detected'. Confirme se é o arquivo correto antes de prosseguir."
        else
            log "Variante '$VARIANT' confirmada (informada via -t)."
        fi
    elif [[ -n "$detected" ]]; then
        VARIANT="$detected"
        log "Variante detectada automaticamente pelo nome do arquivo: $VARIANT"
    else
        log "AVISO: não foi possível detectar a variante (lxqt/cli) pelo nome do arquivo. Prosseguindo mesmo assim — a verificação de assinatura não depende disso."
    fi
}

# Passo 2 do playbook: importar a chave (em keyring isolado e temporário,
# para não poluir/confundir com o keyring pessoal do operador)
import_key() {
    log "[Passo 2/5] Importando chave de assinatura em keyring temporário e isolado..."
    GNUPGHOME_DIR="$(mktemp -d)"
    chmod 700 "$GNUPGHOME_DIR"
    export GNUPGHOME="$GNUPGHOME_DIR"

    gpg --quiet --import "$KEY_FILE" 2>&1 | tee -a "$LOG_FILE" >&2
}

# Verificação do fingerprint contra o valor informado pelo operador
# (NUNCA fixo no script — deve vir da página oficial no momento do uso)
verify_fingerprint() {
    log "[Passo 2/5] Verificando fingerprint da chave contra o valor informado..."
    local normalized_expected normalized_actual fpr_list

    normalized_expected="$(echo "$EXPECTED_FPR" | tr -d ' ' | tr '[:lower:]' '[:upper:]')"

    fpr_list="$(gpg --with-colons --fingerprint 2>/dev/null | awk -F: '/^fpr:/ {print $10}')"

    local matched=0
    while read -r fpr; do
        normalized_actual="$(echo "$fpr" | tr -d ' ' | tr '[:lower:]' '[:upper:]')"
        if [[ "$normalized_actual" == "$normalized_expected" ]]; then
            matched=1
            break
        fi
    done <<< "$fpr_list"

    if [[ "$matched" -ne 1 ]]; then
        fail "Fingerprint NÃO confere com o informado. Abortando — chave não confiável. Confirme o valor em https://www.whonix.org/wiki/Verify_the_images"
    fi

    log "Fingerprint confirmado com sucesso."
}

# Passo 3 do playbook: verificar a assinatura do .ova (OBRIGATÓRIO)
# Fail-closed: VALIDSIG + fingerprint (imune a locale PT-BR "Assinatura válida")
verify_signature() {
    log "[Passo 3/5] Verificando assinatura do arquivo .ova (OBRIGATÓRIO)..."
    local fpr_norm gpg_log
    fpr_norm="$(echo "$EXPECTED_FPR" | tr -d ' ' | tr '[:lower:]' '[:upper:]')"
    gpg_log="$(mktemp)"
    gpg --status-fd 1 --verify-options show-notations --verify "$SIG_FILE" "$OVA_FILE" \
        >"$gpg_log" 2>&1 || true

    if grep -q "^\[GNUPG:\] VALIDSIG .*${fpr_norm}" "$gpg_log"; then
        log "Assinatura verificada (VALIDSIG + fingerprint esperado)."
        cat "$gpg_log" | tee -a "$LOG_FILE" >&2
        rm -f "$gpg_log"
        return 0
    fi
    if grep -qi "EXPKEYSIG" "$gpg_log"; then
        cat "$gpg_log" | tee -a "$LOG_FILE" >&2
        rm -f "$gpg_log"
        fail "EXPKEYSIG — chave expirada. Reimporte derivative.asc de whonix.org e confira fingerprint em Verify_the_images."
    fi
    cat "$gpg_log" | tee -a "$LOG_FILE" >&2
    rm -f "$gpg_log"
    fail "Assinatura INVÁLIDA. NÃO importe este arquivo. Apague e baixe novamente."
}

# Passo 4 do playbook: importar no VirtualBox
import_ova() {
    log "[Passo 4/5] Importando appliance no VirtualBox..."
    VBoxManage import "$OVA_FILE" | tee -a "$LOG_FILE" >&2

    local vms
    vms="$(VBoxManage list vms)"
    echo "$vms" | tee -a "$LOG_FILE" >&2

    echo "$vms" | grep -qi "Whonix-Gateway" || log "AVISO: 'Whonix-Gateway' não encontrada na lista de VMs — confira o nome manualmente."
    echo "$vms" | grep -qi "Whonix-Workstation" || log "AVISO: 'Whonix-Workstation' não encontrada na lista de VMs — confira o nome manualmente."
}

# Passos 5 e 6 do playbook: subir Gateway primeiro, depois Workstation (opcional)
boot_vms() {
    log "[Passo 5/5] Iniciando Whonix-Gateway (headless)..."
    VBoxManage startvm "Whonix-Gateway" --type headless || log "AVISO: falha ao iniciar Whonix-Gateway automaticamente. Inicie manualmente pela GUI."

    log "Aguardando 20s antes de iniciar a Workstation (dar tempo do Gateway subir)..."
    sleep 20

    log "Iniciando Whonix-Workstation (GUI, para permitir Anon Connection Wizard/systemcheck)..."
    VBoxManage startvm "Whonix-Workstation" --type gui || log "AVISO: falha ao iniciar Whonix-Workstation automaticamente. Inicie manualmente pela GUI."
}

print_manual_steps() {
    cat <<'EOF'

===================================================================
PRÓXIMOS PASSOS — REQUEREM AÇÃO MANUAL DENTRO DAS VMs (NÃO PULAR):

  [Gateway]
    1. Aceite os avisos iniciais.
    2. No Anon Connection Wizard, escolha conexão normal ou bridge.
    3. Aguarde confirmação de "Tor conectado".

  [Workstation]
    4. Rode: systemcheck
       -> deve confirmar Tor OK e rede correta.
    5. Abra o Tor Browser -> https://check.torproject.org
       -> deve dizer "Congratulations. This browser is configured to use Tor."
    6. Confirme que a Workstation NÃO tem rota direta à internet,
       apenas via Gateway (nenhuma segunda placa de rede).
    7. Opcional: ./ztc-whonix-health.sh (ZTC_WHONIX_TOR_CHECK=yes para checagem viva)

  [Ambas as VMs]
    8. sudo apt update && sudo apt full-upgrade

Esses passos não são automatizados de propósito: são a verificação
humana que garante que o isolamento Gateway/Workstation está intacto.
===================================================================
EOF
}

# -------------------------------- Main -------------------------------------

while getopts ":i:s:k:f:t:byh" opt; do
    case "$opt" in
        i) OVA_FILE="$OPTARG" ;;
        s) SIG_FILE="$OPTARG" ;;
        k) KEY_FILE="$OPTARG" ;;
        f) EXPECTED_FPR="$OPTARG" ;;
        t) VARIANT="$OPTARG" ;;
        b) BOOT_VMS=1 ;;
        y) ASSUME_YES=1 ;;
        h) usage ;;
        *) usage ;;
    esac
done

touch "$LOG_FILE" 2>/dev/null || LOG_FILE="./whonix-install.log"
log "===== Iniciando W01 — Instalar Whonix (Gateway + Workstation) ====="

require_vboxmanage
validate_inputs
detect_or_validate_variant

if ! confirm "Importar e verificar '${OVA_FILE}' com a chave '${KEY_FILE}'?"; then
    log "Cancelado pelo usuário."
    exit 0
fi

import_key
verify_fingerprint
verify_signature
import_ova

if [[ "$BOOT_VMS" -eq 1 ]]; then
    boot_vms
fi

print_manual_steps
log "===== W01 (parte automatizável) concluído. Verificação manual pendente — ver instruções acima. ====="
