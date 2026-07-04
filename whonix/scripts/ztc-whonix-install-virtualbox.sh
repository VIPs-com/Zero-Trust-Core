#!/usr/bin/env bash
#
# ztc-whonix-install-virtualbox.sh — Zero Trust Core
#
# Automação do Playbook W00 — Instalar e Configurar o VirtualBox no Debian 13 (Trixie).
# Guia: whonix/playbooks/W00-instalar-configurar-virtualbox.md
# Baixa e verifica a chave GPG da Oracle, configura o repositório oficial,
# verifica a assinatura do repo, instala dependências/pacote e (opcionalmente)
# o Extension Pack. Aborta em qualquer falha de verificação — sem bypass.
#
# Uso:
#   sudo ./ztc-whonix-install-virtualbox.sh [-v VERSAO] [-e] [-y]
#
#   -v VERSAO   Série do VirtualBox a instalar (padrão: 7.2)
#   -e          Também baixa e instala o Extension Pack correspondente
#   -y          Não pede confirmação (modo não-interativo, para CI/automação)
#
# Log: /var/log/virtualbox-install.log
# Referência: playbooks/W00-instalar-configurar-virtualbox.md

set -euo pipefail

# ----------------------------- Configuração ------------------------------

VBOX_SERIES="7.2"
INSTALL_EXTPACK=0
ASSUME_YES=0
KEYRING="/usr/share/keyrings/oracle-virtualbox.gpg"
REPO_FILE="/etc/apt/sources.list.d/virtualbox.list"
KEY_URL="https://www.virtualbox.org/download/oracle_vbox_2016.asc"
EXPECTED_FPR="B9F8D658297AF3EFC18D5CDFA2F683C52980AECF"
LOG_FILE="/var/log/virtualbox-install.log"

SUPPORTED_CODENAMES=("trixie" "bookworm" "bullseye")

# ------------------------------- Funções ----------------------------------

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

fail() {
    log "ERRO: $*"
    exit 1
}

usage() {
    grep '^#' "$0" | sed -e 's/^#//' -e '1d'
    exit 1
}

require_root() {
    if [[ "${EUID}" -ne 0 ]]; then
        fail "Este script precisa ser executado como root (use sudo)."
    fi
}

# Passo 1 do playbook: validação de host antes de qualquer alteração
check_arch_and_codename() {
    local arch codename
    arch="$(dpkg --print-architecture)"
    # shellcheck disable=SC1091
    . /etc/os-release
    codename="${VERSION_CODENAME:-}"

    if [[ "$arch" != "amd64" ]]; then
        fail "Arquitetura não suportada: $arch (esperado: amd64)."
    fi

    local supported=0
    for c in "${SUPPORTED_CODENAMES[@]}"; do
        [[ "$codename" == "$c" ]] && supported=1 && break
    done

    if [[ "$supported" -ne 1 ]]; then
        fail "Codename '$codename' não está na lista suportada (${SUPPORTED_CODENAMES[*]})."
    fi

    log "Sistema validado: arch=$arch codename=$codename"
    echo "$codename"
}

confirm() {
    if [[ "$ASSUME_YES" -eq 1 ]]; then
        return 0
    fi
    read -r -p "$1 [s/N] " resp
    [[ "$resp" =~ ^[sSyY]$ ]]
}

# Passo 1 do playbook: preparar o sistema
install_build_deps() {
    log "[Passo 1/9] Atualizando índice de pacotes e instalando dependências de build..."
    apt-get update -qq
    apt-get install -y -qq \
        "linux-headers-$(uname -r)" dkms build-essential gcc make perl curl wget gnupg2

    if [[ ! -d "/usr/src/linux-headers-$(uname -r)" ]]; then
        fail "Headers do kernel em execução não encontrados. Verifique linux-headers-$(uname -r)."
    fi
    log "Dependências de build OK."
}

# Passos 2 e 3 do playbook: importar chave + verificar fingerprint (OBRIGATÓRIO)
install_and_verify_key() {
    log "[Passo 2/9] Baixando a chave pública da Oracle..."
    wget -qO- "$KEY_URL" | gpg --dearmor --yes -o "$KEYRING"

    log "[Passo 3/9] Verificando fingerprint da chave (OBRIGATÓRIO)..."
    local fpr
    fpr="$(gpg --show-keys --with-colons --fingerprint "$KEYRING" \
        | awk -F: '/^fpr:/ {print $10; exit}')"

    if [[ "$fpr" != "$EXPECTED_FPR" ]]; then
        rm -f "$KEYRING"
        fail "Fingerprint NÃO confere. Esperado: $EXPECTED_FPR | Obtido: ${fpr:-<vazio>}. Abortando por segurança — chave não confiável."
    fi

    log "Fingerprint verificada com sucesso: $fpr"
}

# Passo 4 do playbook: configurar repositório oficial
add_repo() {
    local codename="$1"
    log "[Passo 4/9] Configurando repositório oficial para codename '$codename'..."
    echo "deb [arch=amd64 signed-by=${KEYRING}] https://download.virtualbox.org/virtualbox/debian ${codename} contrib" \
        > "$REPO_FILE"
    log "Repositório configurado em ${REPO_FILE}."
}

# Passo 5 do playbook: verificar assinatura do repositório
verify_repo_signature() {
    log "[Passo 5/9] Atualizando índice e verificando assinatura do repositório..."
    if apt-get update 2>&1 | tee -a "$LOG_FILE" | grep -qiE "NO_PUBKEY|BADSIG"; then
        fail "Falha na verificação de assinatura do repositório (NO_PUBKEY/BADSIG detectado). Abortando — não instale."
    fi
    log "Nenhum erro de assinatura detectado (NO_PUBKEY/BADSIG)."
}

# Passo 6 do playbook: instalar o pacote
install_virtualbox() {
    local pkg="virtualbox-${VBOX_SERIES}"
    log "[Passo 6/9] Verificando candidato do pacote ${pkg}..."
    if ! apt-cache policy "$pkg" | grep -q "download.virtualbox.org"; then
        fail "Candidato de ${pkg} não vem do repositório da Oracle. Abortando."
    fi

    log "Instalando ${pkg}..."
    apt-get install -y "$pkg"

    modprobe vboxdrv 2>/dev/null || log "Aviso: não foi possível carregar vboxdrv via modprobe (verifique DKMS/Secure Boot)."

    if lsmod | grep -q vbox; then
        log "Módulos do VirtualBox carregados com sucesso."
    else
        log "AVISO: módulos vbox não aparecem em lsmod. Verifique Secure Boot (passo 7 do playbook)."
    fi
}

# Passo 7 do playbook: grupo vboxusers (Secure Boot é decisão manual, apenas alertamos)
configure_group_and_secureboot_notice() {
    log "[Passo 7/9] Configurando grupo vboxusers..."
    local target_user="${SUDO_USER:-$USER}"
    if [[ "$target_user" == "root" ]]; then
        log "Aviso: usuário alvo é root; pulei adição ao grupo vboxusers."
    else
        usermod -aG vboxusers "$target_user"
        log "Usuário '$target_user' adicionado ao grupo vboxusers (relogin necessário)."
    fi

    if command -v mokutil >/dev/null 2>&1 && mokutil --sb-state 2>/dev/null | grep -qi "enabled"; then
        log "AVISO: Secure Boot está HABILITADO. Módulos não assinados podem ser bloqueados — ver Passo 7 do playbook (assinar módulos via MOK ou desabilitar Secure Boot)."
    fi
}

# Passo 8 do playbook: Extension Pack (opcional)
install_extpack() {
    local pkg="virtualbox-${VBOX_SERIES}"
    local full_version tmp_dir extpack_file

    log "[Passo 8/9] Instalando Extension Pack (opcional)..."
    full_version="$(dpkg-query -W -f='${Version}' "$pkg" | cut -d: -f2 | cut -d- -f1)"
    tmp_dir="$(mktemp -d)"
    extpack_file="Oracle_VirtualBox_Extension_Pack-${full_version}.vbox-extpack"

    if ! wget -q -P "$tmp_dir" "https://download.virtualbox.org/virtualbox/${full_version}/${extpack_file}"; then
        log "AVISO: não foi possível baixar o Extension Pack para a versão ${full_version}. Pulei esta etapa."
        rm -rf "$tmp_dir"
        return
    fi

    echo y | VBoxManage extpack install --replace "${tmp_dir}/${extpack_file}" \
        || log "AVISO: instalação do Extension Pack retornou erro. Verifique manualmente."

    rm -rf "$tmp_dir"
}

# Passo 9 do playbook: verificação final
verify_installation() {
    log "[Passo 9/9] Verificação final..."
    VBoxManage --version 2>&1 | tee -a "$LOG_FILE" || log "AVISO: VBoxManage não respondeu."
    lsmod | grep vbox | tee -a "$LOG_FILE" || log "AVISO: nenhum módulo vbox carregado."
}

# -------------------------------- Main -------------------------------------

while getopts ":v:eyh" opt; do
    case "$opt" in
        v) VBOX_SERIES="$OPTARG" ;;
        e) INSTALL_EXTPACK=1 ;;
        y) ASSUME_YES=1 ;;
        h) usage ;;
        *) usage ;;
    esac
done

require_root
touch "$LOG_FILE"
log "===== Iniciando W00 — Instalar e Configurar o VirtualBox (série ${VBOX_SERIES}) ====="

CODENAME="$(check_arch_and_codename)"

if ! confirm "Prosseguir com a instalação do virtualbox-${VBOX_SERIES} no Debian '${CODENAME}'?"; then
    log "Cancelado pelo usuário."
    exit 0
fi

install_build_deps
install_and_verify_key
add_repo "$CODENAME"
verify_repo_signature
install_virtualbox
configure_group_and_secureboot_notice

if [[ "$INSTALL_EXTPACK" -eq 1 ]]; then
    install_extpack
fi

verify_installation

log "===== W00 concluído. Faça logout/login para aplicar o grupo vboxusers. Próximo passo: W01. ====="
