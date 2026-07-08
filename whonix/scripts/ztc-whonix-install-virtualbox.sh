#!/usr/bin/env bash
#
# ztc-whonix-install-virtualbox.sh — Zero Trust Core
#
# Automação do Playbook W00 — Instalar e Configurar o VirtualBox no Debian 13 (Trixie).
# Guia: whonix/playbooks/W00-instalar-configurar-virtualbox.md
#
# Uso:
#   sudo ./ztc-whonix-install-virtualbox.sh [-v VERSAO] [-e] [-y]
#
#   -v VERSAO   Série do VirtualBox a instalar (padrão: 7.2)
#   -e          Também baixa e instala o Extension Pack correspondente
#   -y          Não pede confirmação (modo não-interativo, para CI/automação)
#
# Log: /var/log/virtualbox-install.log
#
# Changelog jul/2026:
#   - log() em stderr (evita poluir $(check_arch_and_codename))
#   - apt-get update: exit code real + NO_PUBKEY/BADSIG
#   - check_repo_availability() antes de escrever sources.list
#   - escrita atômica keyring/repo; fetch com retry

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
FETCH_RETRIES=3
FETCH_TIMEOUT=120

SUPPORTED_CODENAMES=("trixie" "bookworm" "bullseye")

# ------------------------------- Funções ----------------------------------

# stderr: não poluir captura $(...) de funções que retornam valor
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE" >&2
}

fail() {
    log "ERRO: $*"
    exit 1
}

on_err() {
    local ec=$?
    log "ERRO na linha ${BASH_LINENO[0]}: ${BASH_COMMAND} (exit ${ec}). Ver ${LOG_FILE}"
    exit "$ec"
}
trap on_err ERR

usage() {
    grep '^#' "$0" | sed -e 's/^#//' -e '1d'
    exit 1
}

require_root() {
    if [[ "${EUID}" -ne 0 ]]; then
        fail "Este script precisa ser executado como root (use sudo)."
    fi
}

fetch_to_file() {
    local url="$1" dest="$2" tool="${3:-curl}"
    local n
    for ((n=1; n<=FETCH_RETRIES; n++)); do
        if [[ "$tool" == "wget" ]]; then
            wget -qO "$dest" --timeout="$FETCH_TIMEOUT" "$url" && [[ -s "$dest" ]] && return 0
        else
            curl -fsSL --max-time "$FETCH_TIMEOUT" -o "$dest" "$url" && [[ -s "$dest" ]] && return 0
        fi
        log "AVISO: download falhou (tentativa ${n}/${FETCH_RETRIES}): $url"
        sleep 5
    done
    return 1
}

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

check_repo_availability() {
    local codename="$1"
    local release_url="https://download.virtualbox.org/virtualbox/debian/dists/${codename}/Release"
    local http_code
    log "Verificando repositório Oracle para codename '${codename}'..."
    http_code="$(curl -fsSL -o /dev/null -w '%{http_code}' --max-time "$FETCH_TIMEOUT" "$release_url" 2>/dev/null || echo 000)"
    if [[ "$http_code" != "200" ]]; then
        fail "Repositório Oracle sem Release para '${codename}' (HTTP ${http_code}). Confira: ${release_url}"
    fi
    log "Release do repositório OK (HTTP 200)."
}

confirm() {
    if [[ "$ASSUME_YES" -eq 1 ]]; then
        return 0
    fi
    read -r -p "$1 [s/N] " resp
    [[ "$resp" =~ ^[sSyY]$ ]]
}

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

install_and_verify_key() {
    log "[Passo 2/9] Baixando a chave pública da Oracle..."
    local tmp_keyring tmp_asc
    tmp_keyring="$(mktemp)"
    tmp_asc="$(mktemp)"
    trap 'rm -f "$tmp_keyring" "$tmp_asc"' RETURN

    fetch_to_file "$KEY_URL" "$tmp_asc" curl || fail "Falha ao baixar chave Oracle: $KEY_URL"
    gpg --dearmor --yes -o "$tmp_keyring" <"$tmp_asc" || fail "gpg --dearmor falhou na chave Oracle."

    log "[Passo 3/9] Verificando fingerprint da chave (OBRIGATÓRIO)..."
    local fpr
    fpr="$(gpg --show-keys --with-colons --fingerprint "$tmp_keyring" \
        | awk -F: '/^fpr:/ {print $10; exit}')"

    if [[ "$fpr" != "$EXPECTED_FPR" ]]; then
        fail "Fingerprint NÃO confere. Esperado: $EXPECTED_FPR | Obtido: ${fpr:-<vazio>}. Abortando — chave não confiável."
    fi

    install -m 644 "$tmp_keyring" "$KEYRING"
    log "Fingerprint verificada com sucesso: $fpr"
}

add_repo() {
    local codename="$1"
    local tmp_repo
    tmp_repo="$(mktemp)"
    trap 'rm -f "$tmp_repo"' RETURN

    log "[Passo 4/9] Configurando repositório oficial para codename '$codename'..."
    check_repo_availability "$codename"
    echo "deb [arch=amd64 signed-by=${KEYRING}] https://download.virtualbox.org/virtualbox/debian ${codename} contrib" \
        >"$tmp_repo"
    install -m 644 "$tmp_repo" "$REPO_FILE"
    log "Repositório configurado em ${REPO_FILE}."
}

verify_repo_signature() {
    log "[Passo 5/9] Atualizando índice e verificando assinatura do repositório..."
    local apt_out apt_rc
    apt_out="$(mktemp)"
    trap 'rm -f "$apt_out"' RETURN

    set +e
    apt-get update 2>&1 | tee -a "$LOG_FILE" >"$apt_out"
    apt_rc=${PIPESTATUS[0]}
    set -e

    if grep -qiE "NO_PUBKEY|BADSIG" "$apt_out"; then
        fail "Falha na verificação de assinatura do repositório (NO_PUBKEY/BADSIG). Abortando — não instale."
    fi
    if [[ "$apt_rc" -ne 0 ]]; then
        fail "apt-get update falhou (exit ${apt_rc}). Verifique rede, codename e ${REPO_FILE}."
    fi
    log "Índice apt atualizado; nenhum NO_PUBKEY/BADSIG."
}

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

    if [[ -e /dev/kvm ]] && lsmod 2>/dev/null | grep -qE '^kvm(_intel|_amd)?'; then
        log "AVISO: KVM carregado — pode conflitar com vboxdrv em kernels novos (Debian 13/trixie). Se o VBox falhar, descarregue kvm temporariamente."
    fi
}

install_extpack() {
    local pkg="virtualbox-${VBOX_SERIES}"
    local full_version tmp_dir extpack_file

    log "[Passo 8/9] Instalando Extension Pack (opcional)..."
    full_version="$(dpkg-query -W -f='${Version}' "$pkg" | cut -d: -f2 | cut -d- -f1)"
    tmp_dir="$(mktemp -d)"
    extpack_file="Oracle_VirtualBox_Extension_Pack-${full_version}.vbox-extpack"
    local ext_url="https://download.virtualbox.org/virtualbox/${full_version}/${extpack_file}"

    if ! fetch_to_file "$ext_url" "${tmp_dir}/${extpack_file}" wget; then
        log "AVISO: não foi possível baixar o Extension Pack (${full_version}). Pulei esta etapa."
        rm -rf "$tmp_dir"
        return
    fi

    echo y | VBoxManage extpack install --replace "${tmp_dir}/${extpack_file}" \
        || log "AVISO: instalação do Extension Pack retornou erro. Verifique manualmente."

    rm -rf "$tmp_dir"
}

verify_installation() {
    log "[Passo 9/9] Verificação final..."
    VBoxManage --version 2>&1 | tee -a "$LOG_FILE" >&2 || log "AVISO: VBoxManage não respondeu."
    lsmod | grep vbox | tee -a "$LOG_FILE" >&2 || log "AVISO: nenhum módulo vbox carregado."
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

log "===== W00 concluído. Faça logout/login para aplicar o grupo vboxusers. Próximo passo: W01 (ztc-whonix-import-ova.sh). ====="
