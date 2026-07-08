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
# ---------------------------------------------------------------------------
# CHANGELOG de tratamento de erros (revisão):
#   - FIX CRÍTICO: log() agora escreve em stderr, não em stdout. Antes,
#     funções que retornavam valor via `echo` + `$(...)` (ex.:
#     check_arch_and_codename) tinham as linhas de log misturadas ao valor
#     de retorno, corrompendo $CODENAME e quebrando add_repo() silenciosamente.
#   - FIX: verify_repo_signature() agora checa o código de saída REAL do
#     `apt-get update` (via PIPESTATUS) em vez de depender só do grep de
#     NO_PUBKEY/BADSIG, que mascarava outras falhas (404, timeout, DNS).
#   - Novo: trap centralizado (ERR + EXIT) com contexto de linha/comando e
#     limpeza garantida de arquivos temporários.
#   - Novo: checagem prévia de que o repositório publica Release para o
#     codename/série antes de configurar e instalar (evita "quebrar" o
#     apt do usuário com um repo inválido).
#   - Novo: downloads (chave, extpack) com retry/timeout e validação de
#     conteúdo não vazio antes de usar.
#   - Novo: escrita atômica de /etc/apt/sources.list.d/virtualbox.list e do
#     keyring (grava em tmp, só substitui o arquivo real se tudo validar).
#   - Novo: resumo final claro (sucesso/aviso/erro) em vez de só logs soltos.
#   - Novo (jul/2026): sanitize_stale_repo_file() — auto-cura se uma
#     execução anterior (de uma cópia/versão mais antiga deste script, de
#     qualquer pasta — o caminho é global do sistema) deixou
#     /etc/apt/sources.list.d/virtualbox.list corrompido. Sem isso, o
#     apt-get update do Passo 1 quebra ANTES de add_repo() (Passo 4) ter
#     a chance de reescrever o arquivo corretamente.
# ---------------------------------------------------------------------------

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
DL_BASE="https://download.virtualbox.org/virtualbox/debian"
NET_RETRIES=3
NET_TIMEOUT=15

SUPPORTED_CODENAMES=("trixie" "bookworm" "bullseye")

# Rastreamento de avisos não-fatais para o resumo final
WARNINGS=()
TMP_PATHS=()

# ------------------------------- Funções ----------------------------------

# IMPORTANTE: log() escreve em stderr (fd 2), NUNCA em stdout.
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE" >&2
}

warn() {
    log "AVISO: $*"
    WARNINGS+=("$*")
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

# Auto-cura: virtualbox.list corrompido por execução anterior com bug de log/stdout
sanitize_stale_repo_file() {
    if [[ -f "$REPO_FILE" ]]; then
        local n_lines
        n_lines="$(wc -l < "$REPO_FILE" 2>/dev/null || echo 0)"
        if [[ "$n_lines" -ne 1 ]] || ! grep -q '^deb \[' "$REPO_FILE" 2>/dev/null; then
            warn "${REPO_FILE} existente está corrompido/malformado (provavelmente sobra de uma execução anterior com bug) — removendo para evitar que o apt-get update quebre antes mesmo de reconfigurar o repositório. Conteúdo removido: $(cat "$REPO_FILE" 2>/dev/null | tr '\n' '|')"
            rm -f "$REPO_FILE"
        fi
    fi
}

on_error() {
    local exit_code=$1 line_no=$2 command=$3
    log "ERRO: comando '${command}' falhou (código ${exit_code}) na linha ${line_no}."
    log "Consulte ${LOG_FILE} para o histórico completo desta execução."
    cleanup_tmp
    exit "$exit_code"
}

cleanup_tmp() {
    for p in "${TMP_PATHS[@]:-}"; do
        [[ -n "$p" && -e "$p" ]] && rm -rf "$p"
    done
}

trap 'on_error $? $LINENO "$BASH_COMMAND"' ERR
trap cleanup_tmp EXIT

fetch() {
    local url="$1" out="$2"
    local attempt=1
    while (( attempt <= NET_RETRIES )); do
        if wget -q --timeout="$NET_TIMEOUT" --tries=1 -O "$out" "$url"; then
            if [[ -s "$out" ]]; then
                return 0
            fi
            warn "Download de '$url' retornou arquivo vazio (tentativa ${attempt}/${NET_RETRIES})."
        else
            warn "Falha ao baixar '$url' (tentativa ${attempt}/${NET_RETRIES})."
        fi
        ((attempt++))
        sleep 2
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

    if [[ -z "$codename" ]]; then
        fail "Não foi possível determinar VERSION_CODENAME em /etc/os-release."
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
    local release_url="${DL_BASE}/dists/${codename}/Release"
    log "Verificando disponibilidade do repositório para '${codename}'..."

    local http_code
    http_code="$(curl -s -o /dev/null -w '%{http_code}' --max-time "$NET_TIMEOUT" "$release_url" || echo "000")"

    if [[ "$http_code" != "200" ]]; then
        fail "O repositório Oracle ainda não publica pacotes para '${codename}' (HTTP ${http_code} em ${release_url}). Verifique https://www.virtualbox.org/wiki/Linux_Downloads para o status mais recente ou tente uma série/codename diferente com -v."
    fi

    log "Repositório disponível para '${codename}' (${release_url} respondeu 200)."
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
    if ! apt-get update -qq; then
        fail "Falha ao atualizar o índice de pacotes (apt-get update). Verifique conectividade e os repositórios já configurados em /etc/apt/sources.list.d/."
    fi

    if ! apt-get install -y -qq \
        "linux-headers-$(uname -r)" dkms build-essential gcc make perl curl wget gnupg2; then
        fail "Falha ao instalar dependências de build. Alguns pacotes podem não existir para seu kernel/versão (verifique 'linux-headers-$(uname -r)')."
    fi

    if [[ ! -d "/usr/src/linux-headers-$(uname -r)" ]]; then
        fail "Headers do kernel em execução não encontrados. Verifique linux-headers-$(uname -r)."
    fi
    log "Dependências de build OK."
}

install_and_verify_key() {
    log "[Passo 2/9] Baixando a chave pública da Oracle..."

    local tmp_key
    tmp_key="$(mktemp)"
    TMP_PATHS+=("$tmp_key")

    if ! fetch "$KEY_URL" "$tmp_key"; then
        fail "Não foi possível baixar a chave da Oracle em ${KEY_URL} após ${NET_RETRIES} tentativas. Verifique sua conexão."
    fi

    local tmp_keyring
    tmp_keyring="$(mktemp)"
    TMP_PATHS+=("$tmp_keyring")

    if ! gpg --dearmor --yes -o "$tmp_keyring" "$tmp_key"; then
        fail "Falha ao processar a chave baixada com gpg --dearmor."
    fi

    log "[Passo 3/9] Verificando fingerprint da chave (OBRIGATÓRIO)..."
    local fpr
    fpr="$(gpg --show-keys --with-colons --fingerprint "$tmp_keyring" \
        | awk -F: '/^fpr:/ {print $10; exit}')"

    if [[ "$fpr" != "$EXPECTED_FPR" ]]; then
        fail "Fingerprint NÃO confere. Esperado: $EXPECTED_FPR | Obtido: ${fpr:-<vazio>}. Abortando por segurança — chave não confiável."
    fi

    install -m 0644 "$tmp_keyring" "$KEYRING"
    log "Fingerprint verificada com sucesso: $fpr"
    log "Keyring instalado em ${KEYRING}."
}

add_repo() {
    local codename="$1"
    log "[Passo 4/9] Configurando repositório oficial para codename '$codename'..."

    local tmp_repo
    tmp_repo="$(mktemp)"
    TMP_PATHS+=("$tmp_repo")

    echo "deb [arch=amd64 signed-by=${KEYRING}] ${DL_BASE} ${codename} contrib" > "$tmp_repo"

    if [[ "$(wc -l < "$tmp_repo")" -ne 1 ]] || ! grep -q '^deb \[' "$tmp_repo"; then
        fail "Linha de repositório gerada é inválida — \$codename pode estar corrompido. Conteúdo: $(cat "$tmp_repo")"
    fi

    install -m 0644 "$tmp_repo" "$REPO_FILE"
    log "Repositório configurado em ${REPO_FILE}: $(cat "$REPO_FILE")"
}

verify_repo_signature() {
    log "[Passo 5/9] Atualizando índice e verificando assinatura do repositório..."

    local update_out
    update_out="$(mktemp)"
    TMP_PATHS+=("$update_out")

    set +e
    apt-get update 2>&1 | tee -a "$LOG_FILE" > "$update_out"
    local apt_status=${PIPESTATUS[0]}
    set -e

    if [[ "$apt_status" -ne 0 ]]; then
        fail "apt-get update falhou (código ${apt_status}) após configurar o repositório VirtualBox. Saída relevante: $(tail -n 5 "$update_out")"
    fi

    if grep -qiE "NO_PUBKEY|BADSIG" "$update_out"; then
        fail "Falha na verificação de assinatura do repositório (NO_PUBKEY/BADSIG detectado). Abortando — não instale."
    fi

    log "apt-get update concluído sem erros e sem NO_PUBKEY/BADSIG."
}

install_virtualbox() {
    local pkg="virtualbox-${VBOX_SERIES}"
    log "[Passo 6/9] Verificando candidato do pacote ${pkg}..."

    if ! apt-cache policy "$pkg" | grep -q "download.virtualbox.org"; then
        fail "Candidato de ${pkg} não vem do repositório da Oracle (ou o pacote não existe para esta série/codename)."
    fi

    log "Instalando ${pkg}..."
    if ! apt-get install -y "$pkg"; then
        fail "Falha ao instalar ${pkg}. Rode 'apt-get install -y ${pkg}' manualmente para ver o erro completo."
    fi

    modprobe vboxdrv 2>/dev/null || warn "não foi possível carregar vboxdrv via modprobe (verifique DKMS/Secure Boot)."

    if lsmod | grep -q vbox; then
        log "Módulos do VirtualBox carregados com sucesso."
    else
        warn "módulos vbox não aparecem em lsmod. Verifique Secure Boot (passo 7 do playbook)."
    fi
}

configure_group_and_secureboot_notice() {
    log "[Passo 7/9] Configurando grupo vboxusers..."
    local target_user="${SUDO_USER:-$USER}"
    if [[ "$target_user" == "root" ]]; then
        warn "usuário alvo é root; pulei adição ao grupo vboxusers."
    else
        if usermod -aG vboxusers "$target_user"; then
            log "Usuário '$target_user' adicionado ao grupo vboxusers (relogin necessário)."
        else
            warn "Falha ao adicionar '$target_user' ao grupo vboxusers."
        fi
    fi

    if command -v mokutil >/dev/null 2>&1 && mokutil --sb-state 2>/dev/null | grep -qi "enabled"; then
        warn "Secure Boot está HABILITADO. Módulos não assinados podem ser bloqueados."
    fi

    if command -v kvm-ok >/dev/null 2>&1 || lsmod | grep -qE '^kvm_intel|^kvm_amd'; then
        warn "Módulo KVM detectado. Em kernels recentes (Debian 13+) pode causar conflito com VirtualBox."
    fi
}

install_extpack() {
    local pkg="virtualbox-${VBOX_SERIES}"
    local full_version tmp_dir extpack_file

    log "[Passo 8/9] Instalando Extension Pack (opcional)..."
    full_version="$(dpkg-query -W -f='${Version}' "$pkg" 2>/dev/null | cut -d: -f2 | cut -d- -f1)"

    if [[ -z "$full_version" ]]; then
        warn "Não foi possível determinar a versão instalada de ${pkg}; pulando Extension Pack."
        return
    fi

    tmp_dir="$(mktemp -d)"
    TMP_PATHS+=("$tmp_dir")
    extpack_file="Oracle_VirtualBox_Extension_Pack-${full_version}.vbox-extpack"
    local extpack_url="https://download.virtualbox.org/virtualbox/${full_version}/${extpack_file}"

    if ! fetch "$extpack_url" "${tmp_dir}/${extpack_file}"; then
        warn "não foi possível baixar o Extension Pack (${extpack_url})."
        return
    fi

    if ! echo y | VBoxManage extpack install --replace "${tmp_dir}/${extpack_file}"; then
        warn "instalação do Extension Pack retornou erro."
    fi
}

verify_installation() {
    log "[Passo 9/9] Verificação final..."
    if ! VBoxManage --version 2>&1 | tee -a "$LOG_FILE" >&2; then
        warn "VBoxManage não respondeu — instalação pode estar incompleta."
    fi
    if ! lsmod | grep vbox | tee -a "$LOG_FILE" >&2; then
        warn "nenhum módulo vbox carregado — pode ser necessário relogin ou reboot."
    fi
}

print_summary() {
    echo "" >&2
    log "===== Resumo ====="
    if [[ "${#WARNINGS[@]}" -eq 0 ]]; then
        log "Instalação concluída sem avisos."
    else
        log "Instalação concluída com ${#WARNINGS[@]} aviso(s):"
        for w in "${WARNINGS[@]}"; do
            log "  - $w"
        done
    fi
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
sanitize_stale_repo_file
touch "$LOG_FILE"
log "===== Iniciando W00 — Instalar e Configurar o VirtualBox (série ${VBOX_SERIES}) ====="

CODENAME="$(check_arch_and_codename)"
log "Codename detectado (limpo): '${CODENAME}'"

check_repo_availability "$CODENAME"

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
print_summary

log "===== W00 concluído. Faça logout/login para aplicar o grupo vboxusers. Próximo passo: W01 (ztc-whonix-import-ova.sh). ====="
