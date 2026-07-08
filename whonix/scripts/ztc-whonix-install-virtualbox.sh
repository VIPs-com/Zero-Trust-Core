#!/usr/bin/env bash
#
# ztc-whonix-install-virtualbox.sh — Zero-Trust-Core (host Linux) - port da suite Privacy-OS-Hub whonix-host v3.5.4
#
# Passo 10 — pré-requisito: Oracle VirtualBox verificado no Debian/Ubuntu.
# Playbook: whonix/playbooks/W00-instalar-configurar-virtualbox.md
#
# Uso:
#   sudo ./ztc-whonix-install-virtualbox.sh [-v VERSAO] [-y] [--no-extpack] [--skip-mok]
#                                      [--reset-mok] [--new-mok-keys]
#
#   -v VERSAO       Série do VirtualBox (padrão: 7.2)
#   -y              Menos prompts; reboot pós-MOK padrão [S] (Enter = sim)
#   --no-extpack    Não instala Extension Pack (padrão: instala)
#   --skip-mok      Não tenta enroll/assinatura MOK (só avisa Secure Boot)
#   --reset-mok     Limpa enroll MOK pendente (mokutil --reset) antes de instalar
#   --new-mok-keys  Com --reset-mok: apaga chaves em /root/module-signing/ e regera
#   -e              Legado: força Extension Pack (redundante — já é padrão)
#
# Exit codes:
#   0 — pacote instalado; módulos OK ou não aplicável
#   2 — pacote OK; falta reboot + Enroll MOK na tela azul
#   3 — pacote OK; falta ztc-whonix-sign-virtualbox-modules.sh
#   1 — erro fatal
#
# Log: /var/log/virtualbox-install.log (linha RESULTADO: no final)
# Assinatura de módulos: ztc-whonix-sign-virtualbox-modules.sh (log separado)
#
# Changelog jul/2026 v3.5.4:
#   - Extension Pack: check 'Usable: true' sem -A2 (ficava ~7 linhas após o
#     nome e nunca casava — reinstalava toda vez / WARN falso no verify)
# Changelog jul/2026 v3.5.3:
#   - FIX falso negativo: checagem de módulo via /proc/modules (grep direto);
#     'lsmod | grep -q' sob pipefail morria com SIGPIPE quando o módulo
#     estava carregado (campo bloodyroar — FAIL com vboxdrv Live no kernel)
# Changelog jul/2026 v3.5.2:
#   - sync_mok_to_shim_signed(): copia MOK Hub → /var/lib/shim-signed/mok/
#     (caminho que vboxdrv.sh nativo exige — fix campo bloodyroar)
# Changelog jul/2026 v3.5.1:
#   - vboxpci removido (descontinuado desde VBox 6.1)
# Changelog jul/2026 v3.5:
#   - Assinatura separada: ztc-whonix-sign-virtualbox-modules.sh
#   - Fase needs_sign; MOK enrolada antes de pending (fix falso reboot)
#   - Arquivo de progresso: /root/module-signing/.hub-vbox-progress
#   - UX MOK: banner colorido antes da senha; CN/fingerprint do certificado
#   - Card tela azul: View key 0 vazio é normal → escolha Continue
#   - Fase pending: avisa que senha MOK já foi definida
# Changelog jul/2026 v3.3:
#   - --reset-mok / --new-mok-keys: refazer fluxo MOK do zero
#   - -y: reboot pós-import [S/n] — Enter reinicia (systemctl reboot -i)
#   - Card MOK: recuperação se perdeu tela azul
# Changelog jul/2026 v3.2.1:
#   - mokutil --import: envia senha 2× no stdin (mokutil pede confirmação)
# Changelog jul/2026 v3.2:
#   - Assistente em fases (fresh / pendente MOK / pós-reboot / completo)
#   - Retomada: pula passos 1–7 se VirtualBox já instalado
#   - Confirmação visual fingerprint Oracle (auto com -y)
#   - Oferta interativa: systemctl reboot -i (não confundir com systemctl -i)
# Changelog jul/2026 v3.1:
#   - mok_key_enrolled: parseia saída mokutil (Debian: exit 0 + "not enrolled")
#   - Extension Pack: --accept-license com -y; pula se já instalado
#   - Estado .mok-import-requested; reboot via systemctl -i no card MOK
# Changelog jul/2026 v3:
#   - Extension Pack ON por padrão; --no-extpack para pular
#   - MOK: gera chave, mokutil --import, assina módulos pós-enroll
#   - Tela azul MOK no boot continua manual (por design do firmware)
#   - RESULTADO + exit_code estruturados no log

set -euo pipefail

# ----------------------------- Configuração ------------------------------

VBOX_SERIES="7.2"
INSTALL_EXTPACK=1
ASSUME_YES=0
SKIP_MOK=0
RESET_MOK=0
RESET_MOK_KEYS=0
KEYRING="/usr/share/keyrings/oracle-virtualbox.gpg"
REPO_FILE="/etc/apt/sources.list.d/virtualbox.list"
KEY_URL="https://www.virtualbox.org/download/oracle_vbox_2016.asc"
ORACLE_FPR_URL="https://www.virtualbox.org/wiki/Linux_Downloads"
EXPECTED_FPR="B9F8D658297AF3EFC18D5CDFA2F683C52980AECF"
LOG_FILE="/var/log/virtualbox-install.log"
DL_BASE="https://download.virtualbox.org/virtualbox/debian"
MOK_DIR="/root/module-signing"
MOK_PRIV="${MOK_DIR}/MOK.priv"
MOK_DER="${MOK_DIR}/MOK.der"
MOK_STATE_FILE="${MOK_DIR}/.mok-import-requested"
PROGRESS_FILE="${MOK_DIR}/.hub-vbox-progress"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SIGN_SCRIPT="${SCRIPT_DIR}/ztc-whonix-sign-virtualbox-modules.sh"
EXTPL_LICENSE="eb31505e56e9b4d0fbca139104da41ac6f6b98f8e78968bdf01b1f3da3c4f9ae"
NET_RETRIES=3
NET_TIMEOUT=15

SUPPORTED_CODENAMES=("trixie" "bookworm" "bullseye")
# vboxpci removido desde VirtualBox 6.1 — só reset unload dos 3 módulos atuais
VBOX_KMODS_UNLOAD=(vboxdrv vboxnetflt vboxnetadp)

WARNINGS=()
TMP_PATHS=()
FINAL_RESULT=""
FINAL_EXIT=0
MOK_REBOOT_NEEDED=0
WIZARD_PHASE=""

# Fases do assistente (detecção automática):
#   fresh_install        — primeira vez; instala pacote + MOK import
#   pending_mok_reboot   — mokutil --import OK; falta reboot + tela azul
#   needs_sign           — pacote OK; falta assinar/carregar módulos (script sign)
#   installed_need_mok   — falta registrar chave MOK
#   complete             — vboxdrv já carregado

# ------------------------------- Funções ----------------------------------

_b() { echo -e "\033[1;34m$*\033[0m" >&2; }
_g() { echo -e "\033[1;32m$*\033[0m" >&2; }
_y() { echo -e "\033[1;33m$*\033[0m" >&2; }
_m() { echo -e "\033[1;35m$*\033[0m" >&2; }

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE" >&2
}

warn() {
    log "AVISO: $*"
    WARNINGS+=("$*")
}

fail() {
    log "ERRO: $*"
    write_result "FAIL" 1
}

write_result() {
    FINAL_RESULT="$1"
    FINAL_EXIT="$2"
    log "RESULTADO: ${FINAL_RESULT}"
    log "exit_code: ${FINAL_EXIT}"
    exit "$FINAL_EXIT"
}

usage() {
    grep '^#' "$0" | sed -e 's/^# \?//' -e '1,/^$/d' | head -n 28
    exit 1
}

require_root() {
    # Com set -e + trap ERR: [[ ... ]] && fail quebra quando a condição é falsa
    # (ex.: EUID=0 com sudo). Usar || fail.
    [[ "${EUID}" -eq 0 ]] || fail "Este script precisa ser executado como root (use sudo)."
}

sanitize_stale_repo_file() {
    if [[ -f "$REPO_FILE" ]]; then
        local n_lines
        n_lines="$(wc -l < "$REPO_FILE" 2>/dev/null || echo 0)"
        if [[ "$n_lines" -ne 1 ]] || ! grep -q '^deb \[' "$REPO_FILE" 2>/dev/null; then
            warn "${REPO_FILE} corrompido/malformado — removendo antes do apt-get update. Conteúdo: $(cat "$REPO_FILE" 2>/dev/null | tr '\n' '|')"
            rm -f "$REPO_FILE"
        fi
    fi
}

on_error() {
    local exit_code=$1 line_no=$2 command=$3
    log "ERRO: comando '${command}' falhou (código ${exit_code}) na linha ${line_no}."
    log "Consulte ${LOG_FILE} para o histórico completo."
    cleanup_tmp
    write_result "FAIL" "$exit_code"
}

cleanup_tmp() {
    for p in "${TMP_PATHS[@]:-}"; do
        [[ -n "$p" && -e "$p" ]] && rm -rf "$p"
    done
}

trap 'on_error $? $LINENO "$BASH_COMMAND"' ERR
trap cleanup_tmp EXIT

fetch() {
    local url="$1" out="$2" attempt=1
    while (( attempt <= NET_RETRIES )); do
        if wget -q --timeout="$NET_TIMEOUT" --tries=1 -O "$out" "$url" && [[ -s "$out" ]]; then
            return 0
        fi
        warn "Download falhou (tentativa ${attempt}/${NET_RETRIES}): $url"
        ((attempt++))
        sleep 2
    done
    return 1
}

secure_boot_enabled() {
    command -v mokutil >/dev/null 2>&1 \
        && mokutil --sb-state 2>/dev/null | grep -qi "enabled"
}

vbox_modules_loaded() {
    # /proc/modules direto — 'lsmod | grep -q' sob pipefail dá falso negativo
    # (SIGPIPE no lsmod quando grep -q casa cedo). Campo bloodyroar 08/jul/2026.
    grep -qE '^vbox' /proc/modules 2>/dev/null
}

check_arch_and_codename() {
    local arch codename
    arch="$(dpkg --print-architecture)"
    # shellcheck disable=SC1091
    . /etc/os-release
    codename="${VERSION_CODENAME:-}"

    [[ "$arch" == "amd64" ]] || fail "Arquitetura não suportada: $arch (esperado: amd64)."
    [[ -n "$codename" ]] || fail "VERSION_CODENAME ausente em /etc/os-release."

    local supported=0 c
    for c in "${SUPPORTED_CODENAMES[@]}"; do
        [[ "$codename" == "$c" ]] && supported=1 && break
    done
    [[ "$supported" -eq 1 ]] || fail "Codename '$codename' não suportado (${SUPPORTED_CODENAMES[*]})."

    log "Sistema validado: arch=$arch codename=$codename"
    echo "$codename"
}

check_repo_availability() {
    local codename="$1"
    local release_url="${DL_BASE}/dists/${codename}/Release"
    local http_code
    log "Verificando repositório Oracle para '${codename}'..."
    http_code="$(curl -s -o /dev/null -w '%{http_code}' --max-time "$NET_TIMEOUT" "$release_url" || echo "000")"
    [[ "$http_code" == "200" ]] || fail "Repositório sem Release para '${codename}' (HTTP ${http_code})."
    log "Release OK (HTTP 200)."
}

confirm() {
    [[ "$ASSUME_YES" -eq 1 ]] && return 0
    read -r -p "$1 [s/N] " resp
    [[ "$resp" =~ ^[sSyY]$ ]]
}

virtualbox_pkg_installed() {
    dpkg -l "virtualbox-${VBOX_SERIES}" 2>/dev/null | grep -q '^ii'
}

detect_wizard_phase() {
    if vbox_modules_loaded; then
        WIZARD_PHASE="complete"
        return
    fi
    if ! virtualbox_pkg_installed; then
        WIZARD_PHASE="fresh_install"
        return
    fi
    if secure_boot_enabled && [[ "$SKIP_MOK" -eq 0 ]]; then
        [[ -f "$MOK_DER" ]] || { WIZARD_PHASE="installed_need_mok"; return; }
        if mok_key_enrolled; then
            WIZARD_PHASE="needs_sign"
        elif mok_enrollment_pending; then
            WIZARD_PHASE="pending_mok_reboot"
        else
            WIZARD_PHASE="installed_need_mok"
        fi
    else
        WIZARD_PHASE="needs_sign"
    fi
}

invoke_sign_script() {
    local sign_rc=0
    if [[ ! -x "$SIGN_SCRIPT" ]]; then
        warn "ztc-whonix-sign-virtualbox-modules.sh ausente em ${SIGN_SCRIPT}"
        warn "Rode: sudo ./ztc-whonix-sign-virtualbox-modules.sh -y --qa-log"
        return 1
    fi
    log "Delegando assinatura → ztc-whonix-sign-virtualbox-modules.sh"
    set +e
    "$SIGN_SCRIPT" -y 2>&1 | tee -a "$LOG_FILE" >&2
    sign_rc=${PIPESTATUS[0]}
    set -e
    if [[ "$sign_rc" -eq 0 ]]; then
        log "Assinatura OK (ztc-whonix-sign-virtualbox-modules.sh)."
        return 0
    elif [[ "$sign_rc" -eq 2 ]]; then
        warn "Assinatura: FAIL_MOK — falta tela azul Enroll MOK."
        MOK_REBOOT_NEEDED=1
        return 2
    else
        warn "Assinatura falhou (exit ${sign_rc}) — veja /var/log/virtualbox-sign.log"
        return 1
    fi
}

print_wizard_intro() {
    local phase_msg
    case "$WIZARD_PHASE" in
        complete)
            phase_msg="Fase: COMPLETO — módulos vbox já carregados."
            ;;
        pending_mok_reboot)
            phase_msg="Fase: AGUARDANDO REBOOT — Enroll MOK na tela azul (1 ação humana no firmware)."
            ;;
        needs_sign)
            phase_msg="Fase: ASSINAR MÓDULOS — MOK OK ou SB off; rode ztc-whonix-sign-virtualbox-modules.sh."
            ;;
        installed_need_mok)
            phase_msg="Fase: MOK — VirtualBox instalado; falta registrar chave Secure Boot."
            ;;
        *)
            phase_msg="Fase: INSTALAÇÃO — download Oracle verificado + pacote + MOK se necessário."
            ;;
    esac
    _m ""
    _m "==================================================================="
    _m "  Assistente VirtualBox — Zero-Trust-Core · v3.5.4"
    _m "==================================================================="
    _b "  ${phase_msg}"
    echo "" >&2
    _g "  [1] install  →  [2] tela azul (SB)  →  [3] sign  →  [4] verify"
    _g "  Este script: instala pacote + MOK import. Assinatura = script sign."
    if [[ "$WIZARD_PHASE" == "pending_mok_reboot" ]]; then
        _y "  Senha MOK já definida — use a MESMA na tela azul."
        _y "  Próximo: reboot → Enroll MOK → Continue → Yes → senha → Reboot"
    elif [[ "$WIZARD_PHASE" == "installed_need_mok" ]]; then
        _y "  ATENÇÃO: em breve pedirá senha MOK (nada aparece ao digitar)."
    elif [[ "$WIZARD_PHASE" == "needs_sign" ]]; then
        _y "  Próximo: sudo ./ztc-whonix-sign-virtualbox-modules.sh -y --qa-log"
    fi
    echo "" >&2
    _b "  Validar: ./ztc-whonix-verify-virtualbox-host.sh --qa-log"
    _b "  Progresso: ${PROGRESS_FILE}"
    _b "  Log install: ${LOG_FILE}"
    _m "==================================================================="
    log "Assistente: ${phase_msg}"
}

confirm_fingerprint_visual() {
    local fpr="$1"
    local grouped expected_grouped
    grouped="$(echo "$fpr" | sed 's/\(..\)/\1:/g; s/:$//')"
    expected_grouped="$(echo "$EXPECTED_FPR" | sed 's/\(..\)/\1:/g; s/:$//')"
    echo "" >&2
    echo "┌─ Confirmação visual — chave Oracle (fonte oficial) ─────────" >&2
    echo "│  Site:  ${ORACLE_FPR_URL}" >&2
    echo "│  Chave: ${KEY_URL}" >&2
    echo "│  FPR obtida:  ${grouped}" >&2
    echo "│  FPR esperada: ${expected_grouped}" >&2
    echo "└─ Script já validou com GPG (fail-closed). Confira se quiser." >&2
    if [[ "$ASSUME_YES" -eq 1 ]]; then
        log "Fingerprint Oracle aceita automaticamente (-y)."
        return 0
    fi
    read -r -p "Fingerprint confere com o site oficial? [S/n] " resp
    [[ ! "$resp" =~ ^[nN]$ ]]
}

offer_reboot_now() {
    [[ "$MOK_REBOOT_NEEDED" -eq 1 ]] || return 0
    [[ -t 0 ]] || return 0
    echo "" >&2
    echo "┌─ Reiniciar AGORA para a tela azul MOK? ──────────────────────" >&2
    echo "│  Comando:  sudo systemctl reboot -i" >&2
    echo "│  ERRADO:   sudo systemctl -i   (só lista serviços!)" >&2
    echo "│  Na tela azul: Enroll MOK → Continue → Yes → senha → Reboot" >&2
    echo "│  (View key 0 vazio é normal — escolha Continue)" >&2
    echo "│  A tela azul some RÁPIDO — reaja assim que o PC reiniciar." >&2
    echo "└──────────────────────────────────────────────────────────────" >&2
    local resp=""
    if [[ "$ASSUME_YES" -eq 1 ]]; then
        read -r -p "Reiniciar com systemctl reboot -i? [S/n] " resp
        resp="${resp:-S}"
    else
        read -r -p "Reiniciar com systemctl reboot -i? [s/N] " resp
    fi
    if [[ "$resp" =~ ^[sSyY]$ ]]; then
        log "Reiniciando em 8 segundos (systemctl reboot -i) — prepare-se para a tela azul..."
        sleep 8
        systemctl reboot -i
    else
        log "Reboot adiado — rode quando estiver pronto: sudo systemctl reboot -i"
        warn "Se perdeu a tela azul antes: sudo mokutil --list-new (vazio = --reset-mok --new-mok-keys -y)"
    fi
}

reset_mok_state() {
    log "===== Reset MOK (teste do zero) ====="
    rm -f "$MOK_STATE_FILE"
    if command -v mokutil >/dev/null 2>&1; then
        set +e
        mokutil --reset 2>&1 | tee -a "$LOG_FILE" >&2
        set -e
        log "mokutil --reset executado (limpa enroll pendente no firmware)."
    fi
    if [[ "$RESET_MOK_KEYS" -eq 1 ]]; then
        rm -f "$MOK_PRIV" "$MOK_DER"
        log "Chaves removidas de ${MOK_DIR} — nova par será gerada neste run."
    fi
    for m in "${VBOX_KMODS_UNLOAD[@]}"; do
        modprobe -r "$m" 2>/dev/null || true
    done
    log "Reset MOK concluído — continuando instalação."
}

install_build_deps() {
    log "[Passo 1/11] apt update + dependências de build (DKMS, headers, openssl)..."
    apt-get update -qq || fail "apt-get update falhou — verifique /etc/apt/sources.list.d/."
    apt-get install -y -qq \
        "linux-headers-$(uname -r)" dkms build-essential gcc make perl \
        curl wget gnupg2 openssl mokutil \
        || fail "Falha ao instalar dependências (headers/DKMS/openssl/mokutil)."
    [[ -d "/usr/src/linux-headers-$(uname -r)" ]] \
        || fail "Headers do kernel ausentes: linux-headers-$(uname -r)."
    log "Dependências OK."
}

install_and_verify_key() {
    log "[Passo 2/11] Baixando chave Oracle..."
    local tmp_key tmp_keyring fpr
    tmp_key="$(mktemp)"; TMP_PATHS+=("$tmp_key")
    fetch "$KEY_URL" "$tmp_key" || fail "Falha ao baixar chave Oracle."

    tmp_keyring="$(mktemp)"; TMP_PATHS+=("$tmp_keyring")
    gpg --dearmor --yes -o "$tmp_keyring" "$tmp_key" || fail "gpg --dearmor falhou."

    log "[Passo 3/11] Verificando fingerprint Oracle (OBRIGATÓRIO)..."
    fpr="$(gpg --show-keys --with-colons --fingerprint "$tmp_keyring" | awk -F: '/^fpr:/ {print $10; exit}')"
    [[ "$fpr" == "$EXPECTED_FPR" ]] \
        || fail "Fingerprint Oracle inválida. Esperado: $EXPECTED_FPR | Obtido: ${fpr:-<vazio>}."
    confirm_fingerprint_visual "$fpr" || fail "Instalação cancelada — fingerprint Oracle não confirmada."
    install -m 0644 "$tmp_keyring" "$KEYRING"
    log "Fingerprint Oracle OK: $fpr"
}

add_repo() {
    local codename="$1" tmp_repo
    log "[Passo 4/11] Configurando repositório para '$codename'..."
    tmp_repo="$(mktemp)"; TMP_PATHS+=("$tmp_repo")
    echo "deb [arch=amd64 signed-by=${KEYRING}] ${DL_BASE} ${codename} contrib" >"$tmp_repo"
    [[ "$(wc -l <"$tmp_repo")" -eq 1 ]] && grep -q '^deb \[' "$tmp_repo" \
        || fail "Linha de repo inválida: $(cat "$tmp_repo")"
    install -m 0644 "$tmp_repo" "$REPO_FILE"
    log "Repo: $(cat "$REPO_FILE")"
}

verify_repo_signature() {
    log "[Passo 5/11] apt-get update + verificação de assinatura do repo..."
    local update_out apt_status
    update_out="$(mktemp)"; TMP_PATHS+=("$update_out")
    set +e
    apt-get update 2>&1 | tee -a "$LOG_FILE" >"$update_out"
    apt_status=${PIPESTATUS[0]}
    set -e
    [[ "$apt_status" -eq 0 ]] || fail "apt-get update falhou (exit ${apt_status}): $(tail -n 5 "$update_out")"
    if grep -qiE "NO_PUBKEY|BADSIG" "$update_out"; then
        fail "NO_PUBKEY/BADSIG no repositório VirtualBox."
    fi
    log "Índice apt OK; sem NO_PUBKEY/BADSIG."
}

install_virtualbox() {
    local pkg="virtualbox-${VBOX_SERIES}"
    log "[Passo 6/11] Instalando ${pkg}..."
    apt-cache policy "$pkg" | grep -q "download.virtualbox.org" \
        || fail "${pkg} não disponível no repo Oracle para este codename."
    apt-get install -y "$pkg" || fail "apt-get install ${pkg} falhou."
    log "Pacote ${pkg} instalado."
    install -d -m 0700 "$MOK_DIR"
    echo "INSTALL_OK=$(date -Iseconds)" >>"$PROGRESS_FILE"
}

run_full_install_pipeline() {
    local codename="$1"
    confirm "Instalar virtualbox-${VBOX_SERIES} no Debian '${codename}'?" \
        || { log "Cancelado."; exit 0; }
    install_build_deps
    install_and_verify_key
    add_repo "$codename"
    verify_repo_signature
    install_virtualbox
    configure_vboxusers
}

run_resume_pipeline() {
    log "Retomada automática: VirtualBox já instalado — pulando passos 1–7."
    configure_vboxusers
}

configure_vboxusers() {
    log "[Passo 7/11] Grupo vboxusers..."
    local target_user="${SUDO_USER:-$USER}"
    if [[ "$target_user" == "root" ]]; then
        warn "usuário root — pulei vboxusers."
    elif usermod -aG vboxusers "$target_user"; then
        log "Usuário '$target_user' → vboxusers (relogin necessário)."
    else
        warn "Falha ao adicionar '$target_user' ao grupo vboxusers."
    fi
    if command -v kvm-ok >/dev/null 2>&1 || grep -qE '^kvm_intel|^kvm_amd' /proc/modules 2>/dev/null; then
        warn "KVM carregado — pode conflitar com VirtualBox em Debian 13+."
    fi
}

ensure_mok_keypair() {
    if [[ -f "$MOK_PRIV" && -f "$MOK_DER" ]]; then
        log "Par MOK já existe em ${MOK_DIR}."
        chmod 600 "$MOK_PRIV"
        sync_mok_to_shim_signed
        return 0
    fi
    log "Gerando par de chaves MOK em ${MOK_DIR}..."
    install -d -m 0700 "$MOK_DIR"
    openssl req -new -x509 -newkey rsa:2048 \
        -keyout "$MOK_PRIV" -outform DER -out "$MOK_DER" \
        -nodes -days 36500 -subj "/CN=VirtualBox MOK Privacy-OS-Hub/" \
        || fail "openssl falhou ao gerar par MOK."
    chmod 600 "$MOK_PRIV"
    chmod 644 "$MOK_DER"
    log "Par MOK gerado (MOK.priv + MOK.der)."
    sync_mok_to_shim_signed
}

# BUG CONFIRMADO (jul/2026): o vboxdrv.sh do pacote Debian (chamado por
# /sbin/vboxconfig) tenta assinar os módulos SOZINHO em toda execução, mas
# procura a chave em /var/lib/shim-signed/mok/ — um caminho DIFERENTE do
# nosso ${MOK_DIR}. Isso faz seu auto-sign falhar sempre (mensagem própria
# dele: "does not provide tools for automatic generation of keys"), e o
# módulo nunca termina de subir pelo mecanismo nativo — ficamos brigando
# com o próprio pacote a cada rebuild. Copiar (não symlink — algumas
# distros validam se é arquivo regular) a MESMA chave para o caminho nativo
# resolve isso na raiz: o vboxdrv.sh passa a assinar e carregar sozinho,
# sem precisarmos mais do nosso modprobe manual por fora do fluxo do pacote.
sync_mok_to_shim_signed() {
    local shim_dir="/var/lib/shim-signed/mok"
    [[ -f "$MOK_PRIV" && -f "$MOK_DER" ]] || return 0
    install -d -m 0700 "$shim_dir" 2>/dev/null || { warn "Não consegui criar ${shim_dir} — vboxconfig pode continuar falhando o auto-sign (não fatal, nosso script assina por fora mesmo assim)."; return 0; }
    if ! cmp -s "$MOK_DER" "${shim_dir}/MOK.der" 2>/dev/null; then
        install -m 0600 "$MOK_PRIV" "${shim_dir}/MOK.priv" 2>/dev/null \
            && install -m 0644 "$MOK_DER" "${shim_dir}/MOK.der" 2>/dev/null \
            && log "Chave MOK sincronizada para ${shim_dir} (caminho nativo do vboxdrv.sh) — evita a falha de auto-sign do pacote a cada rebuild." \
            || warn "Falha ao sincronizar chave MOK para ${shim_dir}."
    fi
}

mok_test_key_output() {
    # Debian trixie: mokutil --test-key imprime "is not enrolled" mas sai com exit 0.
    # Nunca confiar só no exit code — parsear a mensagem.
    [[ -f "$MOK_DER" ]] || return 1
    command -v mokutil >/dev/null 2>&1 || return 1
    mokutil --test-key "$MOK_DER" 2>&1
}

mok_enrollment_pending() {
    [[ -f "$MOK_STATE_FILE" ]] && return 0
    command -v mokutil >/dev/null 2>&1 \
        && mokutil --list-new 2>/dev/null | grep -q .
}

mok_key_enrolled() {
    local out fp_der
    [[ -f "$MOK_DER" ]] || return 1
    out="$(mok_test_key_output 2>/dev/null || true)"
    if echo "$out" | grep -qiE 'not enrolled|is not enrolled'; then
        return 1
    fi
    if echo "$out" | grep -qiE 'is enrolled|already enrolled'; then
        rm -f "$MOK_STATE_FILE"
        return 0
    fi
    # Fallback: SHA1 do nosso .der aparece em --list-enrolled
    fp_der="$(openssl x509 -inform DER -in "$MOK_DER" -noout -fingerprint -sha1 2>/dev/null \
        | cut -d= -f2 | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]:')"
    [[ -n "$fp_der" ]] \
        && mokutil --list-enrolled 2>/dev/null \
            | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]:' \
            | grep -q "$fp_der" \
        && { rm -f "$MOK_STATE_FILE"; return 0; }
    return 1
}

mark_mok_import_pending() {
    install -d -m 0700 "$MOK_DIR"
    date -Iseconds >"$MOK_STATE_FILE"
}

print_mok_reboot_card() {
    cat >&2 <<'EOF'

===================================================================
  REBOOT OBRIGATÓRIO — Enroll MOK (ação humana no firmware)
===================================================================
  VirtualBox no Linux com Secure Boot ≠ .exe do Windows: o kernel só
  aceita módulos assinados com SUA chave MOK enrolada no firmware.

  O pacote já está instalado. Falta 1 reboot + confirmação na tela azul.

  1) Reinicie (GNOME pode bloquear "sudo reboot" — use uma destas):
       sudo systemctl reboot -i
     ou feche apps e: sudo reboot

  2) No boot, tela AZUL "MOK Management" (só neste reboot):
       Enroll MOK → Continue → Yes → senha MOK → Reboot
     View key 0 pode aparecer VAZIO — isso é normal; escolha Continue.

  3) De volta ao Debian (ordem recomendada):
       sudo ./ztc-whonix-sign-virtualbox-modules.sh -y --qa-log
       sudo ./ztc-whonix-verify-virtualbox-host.sh --qa-log
       sudo ./ztc-whonix-install-virtualbox.sh -y    # Extension Pack se faltar

  Esperado: verify RESULTADO: PASS · vboxdrv no lsmod.

  PERDEU a tela azul? (passou rápido / não interagiu)
  · sudo mokutil --list-new     → se VAZIO, enroll não está pendente
  · Refaça do zero:
      sudo ./ztc-whonix-install-virtualbox.sh --reset-mok --new-mok-keys -y
  · Ou manual: sudo mokutil --import /root/module-signing/MOK.der
              → sudo systemctl reboot -i  (logo em seguida!)

  A tela azul não pode ser automatizada — é proteção do Secure Boot.
===================================================================
EOF
}

print_mok_password_banner() {
    local cn fp
    cn="$(openssl x509 -inform DER -in "$MOK_DER" -noout -subject 2>/dev/null \
        | sed 's/subject= *//' || echo 'CN=VirtualBox MOK Privacy-OS-Hub')"
    fp="$(openssl x509 -inform DER -in "$MOK_DER" -noout -fingerprint -sha256 2>/dev/null \
        | cut -d= -f2 || echo '?')"
    _m ""
    _m "╔══════════════════════════════════════════════════════════════╗"
    _m "║  AÇÃO HUMANA — defina senha MOK (Secure Boot)               ║"
    _m "╠══════════════════════════════════════════════════════════════╣"
    _m "║  Certificado: ${cn}"
    _m "║  SHA256:      ${fp}"
    _y "║  Nada aparece ao digitar — é normal (senha oculta).          ║"
    _y "║  Use a MESMA senha na tela azul: Enroll MOK → Continue       ║"
    _m "╚══════════════════════════════════════════════════════════════╝"
    _m ""
}

enroll_mok_key() {
    local pw1 pw2 import_out import_rc=0
    log "Registrando chave MOK no firmware (mokutil --import)..."
    if [[ ! -t 0 ]]; then
        warn "Sem TTY — não consigo pedir senha MOK. Rode manualmente:"
        warn "  sudo mokutil --import ${MOK_DER}"
        warn "  sudo systemctl reboot -i  →  Enroll MOK na tela azul  →  rode este script de novo"
        mark_mok_import_pending
        MOK_REBOOT_NEEDED=1
        return 1
    fi
    print_mok_password_banner
    _y "Digite a senha MOK agora (cursor piscando = aguardando input):" >&2
    read -r -s -p "Senha MOK: " pw1; echo >&2
    read -r -s -p "Confirme senha MOK: " pw2; echo >&2
    _g "Senhas capturadas — registrando no firmware (mokutil --import)..." >&2
    [[ "$pw1" == "$pw2" && -n "$pw1" ]] || fail "Senhas MOK não conferem ou vazias."
    # mokutil --import pede senha duas vezes (input password / input password again)
    import_out="$(printf '%s\n%s\n' "$pw1" "$pw2" | mokutil --import "$MOK_DER" 2>&1)" || import_rc=$?
    if [[ "$import_rc" -ne 0 ]]; then
        if echo "$import_out" | grep -qiE 'already in the enrollment request|already enrolled'; then
            log "Chave MOK já agendada para enroll — falta reboot + tela azul."
            mark_mok_import_pending
            MOK_REBOOT_NEEDED=1
            return 0
        fi
        fail "mokutil --import falhou: ${import_out}"
    fi
    log "mokutil --import OK — reboot necessário para Enroll MOK."
    mark_mok_import_pending
    echo "MOK_IMPORTED=$(date -Iseconds)" >>"$PROGRESS_FILE"
    MOK_REBOOT_NEEDED=1
}

handle_secure_boot_modules() {
    log "[Passo 8/11] Módulos kernel — delegado ao ztc-whonix-sign-virtualbox-modules.sh"

    if vbox_modules_loaded; then
        log "Módulos vbox já carregados — OK."
        return 0
    fi

    if [[ "$SKIP_MOK" -eq 1 ]] || ! secure_boot_enabled; then
        invoke_sign_script || true
        return 0
    fi

    log "Secure Boot HABILITADO — fluxo MOK (Linux ≠ .exe do Windows)."
    ensure_mok_keypair

    if mok_key_enrolled; then
        rm -f "$MOK_STATE_FILE"
        invoke_sign_script || true
        return 0
    fi

    if mok_enrollment_pending; then
        warn "Enroll MOK pendente — falta reboot + confirmação na tela azul."
        print_mok_reboot_card
        MOK_REBOOT_NEEDED=1
        offer_reboot_now
        return 0
    fi

    enroll_mok_key || true
    if [[ "$MOK_REBOOT_NEEDED" -eq 1 ]]; then
        print_mok_reboot_card
        offer_reboot_now
    fi
}

install_extpack() {
    local pkg="virtualbox-${VBOX_SERIES}" full_version tmp_dir extpack_file extpack_url
    local extpack_args=(extpack install --replace)
    log "[Passo 9/11] Extension Pack (padrão ON)..."
    full_version="$(dpkg-query -W -f='${Version}' "$pkg" 2>/dev/null | cut -d: -f2 | cut -d- -f1)"
    [[ -n "$full_version" ]] || { warn "Versão do pacote ausente — pulando Extension Pack."; return; }

    # 'Usable: true' fica ~7 linhas após o nome do pack — grep -A2 não
    # alcançava e reinstalava o extpack toda vez (falso "ausente").
    local extlist
    extlist="$(VBoxManage list extpacks 2>/dev/null || true)"
    if grep -q "Oracle VirtualBox Extension Pack" <<<"$extlist" \
        && grep -qE '^Usable: *true' <<<"$extlist"; then
        log "Extension Pack já instalado e utilizável — pulando."
        return
    fi

    tmp_dir="$(mktemp -d)"; TMP_PATHS+=("$tmp_dir")
    extpack_file="Oracle_VirtualBox_Extension_Pack-${full_version}.vbox-extpack"
    extpack_url="https://download.virtualbox.org/virtualbox/${full_version}/${extpack_file}"

    [[ "$ASSUME_YES" -eq 1 ]] && extpack_args+=(--accept-license="$EXTPL_LICENSE")

    if fetch "$extpack_url" "${tmp_dir}/${extpack_file}"; then
        if VBoxManage "${extpack_args[@]}" "${tmp_dir}/${extpack_file}"; then
            log "Extension Pack ${full_version} instalado."
        else
            warn "VBoxManage extpack install retornou erro."
        fi
    else
        warn "Download do Extension Pack falhou: ${extpack_url}"
    fi
}

verify_installation() {
    log "[Passo 10/11] Verificação final..."
    VBoxManage --version 2>&1 | tee -a "$LOG_FILE" >&2 || warn "VBoxManage não respondeu."
    if vbox_modules_loaded; then
        grep '^vbox' /proc/modules | tee -a "$LOG_FILE" >&2 || true
        log "Módulos vbox presentes (/proc/modules)."
    else
        warn "Módulos vbox AUSENTES — VMs não ligam até resolver MOK/SB."
    fi
}

print_summary() {
    local next_action="Relogin (vboxusers) → ztc-whonix-import-ova.sh"
    echo "" >&2
    log "===== Resumo [11/11] ====="
    if vbox_modules_loaded; then
        log "Módulos kernel: OK (vboxdrv carregado)"
        next_action="sudo ./ztc-whonix-verify-virtualbox-host.sh --qa-log → ztc-whonix-import-ova.sh"
    elif [[ "$MOK_REBOOT_NEEDED" -eq 1 ]]; then
        log "Módulos kernel: PENDENTE_REBOOT_MOK"
        next_action="sudo systemctl reboot -i → Enroll MOK → ztc-whonix-sign-virtualbox-modules.sh -y"
    elif virtualbox_pkg_installed; then
        log "Módulos kernel: PENDENTE_SIGN"
        next_action="sudo ./ztc-whonix-sign-virtualbox-modules.sh -y --qa-log"
    else
        log "Módulos kernel: AUSENTE"
        next_action="Revise avisos acima"
    fi
    if [[ "${#WARNINGS[@]}" -gt 0 ]]; then
        log "Avisos (${#WARNINGS[@]}):"
        for w in "${WARNINGS[@]}"; do log "  - $w"; done
    fi
    log "Próximo passo: ${next_action}"
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -v) VBOX_SERIES="${2:?}"; shift 2 ;;
            -y) ASSUME_YES=1; shift ;;
            -e) INSTALL_EXTPACK=1; shift ;;
            --no-extpack) INSTALL_EXTPACK=0; shift ;;
            --skip-mok) SKIP_MOK=1; shift ;;
            --reset-mok) RESET_MOK=1; shift ;;
            --new-mok-keys) RESET_MOK=1; RESET_MOK_KEYS=1; shift ;;
            -h|--help) usage ;;
            *)
                echo "Opção desconhecida: $1" >&2
                usage
                ;;
        esac
    done
}

# -------------------------------- Main -------------------------------------

parse_args "$@"

require_root
sanitize_stale_repo_file
touch "$LOG_FILE"
[[ "$RESET_MOK" -eq 1 ]] && reset_mok_state
log "===== Hub Passo 10 — VirtualBox (série ${VBOX_SERIES}) extpack=${INSTALL_EXTPACK} skip_mok=${SKIP_MOK} reset_mok=${RESET_MOK} ====="

CODENAME="$(check_arch_and_codename)"
log "Codename: '${CODENAME}'"
detect_wizard_phase
print_wizard_intro

case "$WIZARD_PHASE" in
    complete)
        log "Retomada: sistema já pronto — verificação rápida."
        verify_installation
        print_summary
        write_result "PASS" 0
        ;;
    pending_mok_reboot)
        check_repo_availability "$CODENAME" 2>/dev/null || true
        print_mok_reboot_card
        MOK_REBOOT_NEEDED=1
        verify_installation
        print_summary
        offer_reboot_now
        write_result "PASS_PENDING_MOK_REBOOT" 2
        ;;
    fresh_install)
        check_repo_availability "$CODENAME"
        run_full_install_pipeline "$CODENAME"
        handle_secure_boot_modules
        [[ "$INSTALL_EXTPACK" -eq 1 ]] && install_extpack
        verify_installation
        print_summary
        ;;
    needs_sign)
        check_repo_availability "$CODENAME" 2>/dev/null || true
        run_resume_pipeline
        invoke_sign_script || true
        [[ "$INSTALL_EXTPACK" -eq 1 ]] && install_extpack
        verify_installation
        print_summary
        ;;
    installed_need_mok)
        check_repo_availability "$CODENAME" 2>/dev/null || true
        run_resume_pipeline
        handle_secure_boot_modules
        [[ "$INSTALL_EXTPACK" -eq 1 ]] && install_extpack
        verify_installation
        print_summary
        ;;
    *)
        fail "Fase do assistente desconhecida: ${WIZARD_PHASE}"
        ;;
esac

log "===== Hub Passo 10 — pacote instalado. Ver RESULTADO abaixo. ====="

if vbox_modules_loaded; then
    write_result "PASS" 0
elif [[ "$MOK_REBOOT_NEEDED" -eq 1 ]]; then
    write_result "PASS_PENDING_MOK_REBOOT" 2
elif virtualbox_pkg_installed; then
    write_result "PASS_NEEDS_SIGN" 3
else
    write_result "PASS_MODULES_MISSING" 2
fi
