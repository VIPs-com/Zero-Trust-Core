#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Privacy-OS-Hub contributors
#
# ztc-whonix-sign-virtualbox-modules.sh — Zero-Trust-Core (host Linux) - port da suite Privacy-OS-Hub whonix-host v3.5.4
#
# Passo 10 — compilar, assinar (Secure Boot) e carregar módulos vboxdrv.
# Rode DEPOIS de ztc-whonix-install-virtualbox.sh + tela azul MOK (se SB ON).
# Repita após cada apt upgrade que troca o kernel.
#
# Uso:
#   sudo ./ztc-whonix-sign-virtualbox-modules.sh [-y] [--qa-log] [--sign-only]
#
# Exit codes:
#   0 — PASS (vboxdrv carregado)
#   2 — FAIL_MOK (SB ON; chave não enrolada — falta tela azul)
#   1 — FAIL (erro fatal)
#
# Log: /var/log/virtualbox-sign.log
#
# ---------------------------------------------------------------------------
# CHANGELOG (jul/2026):
#   - FIX: removido 'vboxpci' da lista de módulos esperados — esse módulo
#     foi descontinuado pela Oracle desde a série 6.1 (PCI passthrough
#     removido) e não existe em nenhuma instalação atual, incluindo 7.2.
#     Gerava um AVISO alarmante e sem sentido em toda execução.
#   - Novo: diagnose_silent_load_failure() — quando `modprobe vboxdrv`
#     retorna sucesso mas o módulo não aparece no lsmod (falha silenciosa:
#     sem "Key was rejected", sem nada), o script agora checa
#     automaticamente blacklist em /etc/modprobe.d, vermagic do módulo vs.
#     kernel rodando, e as últimas linhas do dmesg — em vez de só dizer
#     "não apareceu no lsmod" sem nenhuma pista de causa.
#   - v3.5.3: vbox_modules_loaded() lê /proc/modules direto — 'lsmod |
#     grep -q' sob pipefail dava falso negativo por SIGPIPE quando o módulo
#     estava carregado (campo bloodyroar: FAIL com vboxdrv Live no kernel)
#   - v3.5.2: publicado sync_mok_to_shim_signed (campo bloodyroar jul/2026)
#   - FIX CRÍTICO (confirmado por evidência de campo): vboxdrv.sh (chamado
#     por /sbin/vboxconfig) procura a chave MOK em
#     /var/lib/shim-signed/mok/, um caminho DIFERENTE do ${MOK_DIR} do Hub.
#     Isso fazia seu auto-sign nativo falhar em TODO rebuild ("does not
#     provide tools for automatic generation of keys"), impedindo o módulo
#     de completar o load pelo mecanismo do próprio pacote — nosso
#     modprobe manual por fora ficava brigando com esse ciclo quebrado.
#     sync_mok_to_shim_signed() copia a mesma chave (já enrolada) para o
#     caminho nativo antes de cada vboxconfig.
# ---------------------------------------------------------------------------

set -euo pipefail

ASSUME_YES=0
QA_LOG=0
QA_LOG_DIR=""
SIGN_ONLY=0
# NOTA (jul/2026): vboxpci foi REMOVIDO do VirtualBox a partir da série 6.1
# (suporte a PCI passthrough descontinuado pela Oracle). Não existe mais em
# nenhuma versão atual, incluindo a 7.2 — não é um módulo "faltando por
# erro", é esperado que não exista. Mantê-lo na lista de módulos esperados
# gerava um AVISO alarmante e sem sentido a cada execução.
VBOX_KMODS=(vboxdrv vboxnetflt vboxnetadp)
MOK_DIR="/root/module-signing"
MOK_PRIV="${MOK_DIR}/MOK.priv"
MOK_DER="${MOK_DIR}/MOK.der"
PROGRESS_FILE="${MOK_DIR}/.hub-vbox-progress"
LOG_FILE="/var/log/virtualbox-sign.log"

_b() { echo -e "\033[1;34m$*\033[0m" >&2; }
_g() { echo -e "\033[1;32m$*\033[0m" >&2; }
_y() { echo -e "\033[1;33m$*\033[0m" >&2; }
_m() { echo -e "\033[1;35m$*\033[0m" >&2; }

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE" >&2
}

warn() { log "AVISO: $*"; }

fail() {
    log "ERRO: $*"
    log "RESULTADO: FAIL"
    log "exit_code: 1"
    exit 1
}

pass_result() {
    log "RESULTADO: PASS"
    log "exit_code: 0"
    exit 0
}

mok_fail() {
    log "ERRO: $*"
    log "RESULTADO: FAIL_MOK"
    log "exit_code: 2"
    exit 2
}

usage() {
    grep '^#' "$0" | sed -e 's/^# \?//' -e '1,/^$/d' | head -n 22
    exit 0
}

progress_mark() {
    install -d -m 0700 "$MOK_DIR"
    grep -q "^${1}=" "$PROGRESS_FILE" 2>/dev/null \
        && sed -i "s/^${1}=.*/${1}=$(date -Iseconds)/" "$PROGRESS_FILE" \
        || echo "${1}=$(date -Iseconds)" >>"$PROGRESS_FILE"
}

secure_boot_enabled() {
    command -v mokutil >/dev/null 2>&1 \
        && mokutil --sb-state 2>/dev/null | grep -qi "enabled"
}

vbox_modules_loaded() {
    # /proc/modules direto — NUNCA 'lsmod | grep -q' aqui: sob pipefail,
    # grep -q fecha o pipe no 1º match e lsmod morre com SIGPIPE (exit 141),
    # gerando falso "não carregado" justamente quando o módulo ESTÁ no topo
    # do lsmod (recém-carregado). Bug de campo bloodyroar 08/jul/2026.
    grep -q '^vboxdrv ' /proc/modules 2>/dev/null
}

mok_key_enrolled() {
    local out fp_der
    [[ -f "$MOK_DER" ]] || return 1
    out="$(mokutil --test-key "$MOK_DER" 2>&1 || true)"
    if echo "$out" | grep -qiE 'not enrolled|is not enrolled'; then
        return 1
    fi
    if echo "$out" | grep -qiE 'is enrolled|already enrolled'; then
        rm -f "${MOK_DIR}/.mok-import-requested"
        return 0
    fi
    fp_der="$(openssl x509 -inform DER -in "$MOK_DER" -noout -fingerprint -sha1 2>/dev/null \
        | cut -d= -f2 | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]:')"
    [[ -n "$fp_der" ]] \
        && mokutil --list-enrolled 2>/dev/null \
            | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]:' \
            | grep -q "$fp_der" \
        && { rm -f "${MOK_DIR}/.mok-import-requested"; return 0; }
    return 1
}

find_module_path() {
    local m="$1" p
    p="$(modinfo -F filename "$m" 2>/dev/null || true)"
    [[ -n "$p" && -f "$p" ]] && { echo "$p"; return 0; }
    find "/lib/modules/$(uname -r)" -name "${m}.ko" -o -name "${m}.ko.zst" 2>/dev/null | head -1
}

ensure_kernel_headers() {
    local kver hdr
    kver="$(uname -r)"
    hdr="/usr/src/linux-headers-${kver}"
    if [[ ! -d "$hdr" ]]; then
        log "Instalando linux-headers-${kver}..."
        apt-get update -qq || fail "apt-get update falhou."
        apt-get install -y -qq "linux-headers-${kver}" \
            || fail "linux-headers-${kver} ausente — kernel pode ter sido removido."
    fi
    [[ -x "${hdr}/scripts/sign-file" ]] \
        || fail "sign-file ausente em ${hdr}/scripts/sign-file"
}

# BUG CONFIRMADO (jul/2026): vboxdrv.sh (dentro de /sbin/vboxconfig) procura
# a MOK em /var/lib/shim-signed/mok/, não em ${MOK_DIR}. Sem isso, seu
# auto-sign falha sempre e o módulo nunca completa o load pelo mecanismo
# nativo do pacote — ver ztc-whonix-install-virtualbox.sh para o mesmo fix.
sync_mok_to_shim_signed() {
    local shim_dir="/var/lib/shim-signed/mok"
    [[ -f "$MOK_PRIV" && -f "$MOK_DER" ]] || return 0
    install -d -m 0700 "$shim_dir" 2>/dev/null || return 0
    if ! cmp -s "$MOK_DER" "${shim_dir}/MOK.der" 2>/dev/null; then
        install -m 0600 "$MOK_PRIV" "${shim_dir}/MOK.priv" 2>/dev/null \
            && install -m 0644 "$MOK_DER" "${shim_dir}/MOK.der" 2>/dev/null \
            && log "Chave MOK sincronizada para ${shim_dir} (caminho nativo do vboxdrv.sh)."
    fi
}

run_vboxconfig() {
    log "[1/4] Recompilando módulos para kernel $(uname -r)..."
    sync_mok_to_shim_signed
    if [[ -x /sbin/vboxconfig ]]; then
        /sbin/vboxconfig 2>&1 | tee -a "$LOG_FILE" >&2 \
            || warn "vboxconfig retornou erro — tentando assinar módulos existentes."
    elif [[ -x /usr/lib/virtualbox/vboxdrv.sh ]]; then
        /usr/lib/virtualbox/vboxdrv.sh setup 2>&1 | tee -a "$LOG_FILE" >&2 \
            || warn "vboxdrv.sh setup retornou erro."
    else
        fail "vboxconfig não encontrado — instale virtualbox primeiro."
    fi
    progress_mark "VBOXCONFIG"
}

sign_modules() {
    local kernelver signfile m modpath signed=0
    kernelver="$(uname -r)"
    signfile="/usr/src/linux-headers-${kernelver}/scripts/sign-file"
    [[ -x "$signfile" ]] || fail "sign-file ausente: ${signfile}"
    [[ -f "$MOK_PRIV" && -f "$MOK_DER" ]] \
        || fail "Chaves MOK ausentes em ${MOK_DIR} — rode ztc-whonix-install-virtualbox.sh primeiro."

    log "[2/4] Assinando módulos com chave MOK (kernel ${kernelver})..."
    for m in "${VBOX_KMODS[@]}"; do
        modpath="$(find_module_path "$m" || true)"
        if [[ -n "$modpath" && -f "$modpath" ]]; then
            if "$signfile" sha256 "$MOK_PRIV" "$MOK_DER" "$modpath"; then
                log "  Assinado: ${m} → ${modpath}"
                signed=1
            else
                warn "Falha ao assinar ${m}"
            fi
        else
            warn "Módulo ${m} não encontrado após vboxconfig."
        fi
    done
    [[ "$signed" -eq 1 ]] || fail "Nenhum módulo assinado — rode vboxconfig ou reinstale virtualbox."
    depmod -a
    progress_mark "MODULES_SIGNED"
}

diagnose_silent_load_failure() {
    local m="$1" modpath vermagic_mod vermagic_run blacklist_hits dmesg_tail
    modpath="$(find_module_path "$m" || true)"

    log "--- Diagnóstico automático para '$m' (modprobe retornou 0, mas não carregou) ---"

    blacklist_hits="$(grep -rHn "blacklist[[:space:]]\+${m}\b" /etc/modprobe.d/ /etc/modules-load.d/ 2>/dev/null || true)"
    if [[ -n "$blacklist_hits" ]]; then
        log "CAUSA PROVÁVEL: '$m' está na blacklist do modprobe (isso faz modprobe retornar sucesso sem carregar nada):"
        log "$blacklist_hits"
    fi

    if [[ -n "$modpath" ]]; then
        vermagic_mod="$(modinfo -F vermagic "$modpath" 2>/dev/null | awk '{print $1}')"
        vermagic_run="$(uname -r)"
        if [[ -n "$vermagic_mod" && "$vermagic_mod" != "$vermagic_run" ]]; then
            log "CAUSA PROVÁVEL: vermagic do módulo ('$vermagic_mod') não bate com o kernel rodando ('$vermagic_run') — módulo foi compilado para outro kernel. Rode vboxconfig de novo (sem --sign-only)."
        fi
    else
        log "AVISO: não encontrei o arquivo .ko de '$m' em /lib/modules/$(uname -r)/ — pode não ter sido (re)compilado para este kernel."
    fi

    dmesg_tail="$(dmesg 2>/dev/null | grep -i "$m" | tail -10 || true)"
    if [[ -n "$dmesg_tail" ]]; then
        log "Últimas linhas do dmesg mencionando '$m':"
        log "$dmesg_tail"
    else
        log "Nenhuma linha sobre '$m' no dmesg (ou sem permissão para lê-lo aqui) — rode 'sudo dmesg | grep -i $m' manualmente."
    fi
}

load_modules() {
    local err
    log "[3/4] Carregando módulos..."
    if ! err="$(modprobe vboxdrv 2>&1)"; then
        if echo "$err" | grep -qi 'Key was rejected'; then
            if secure_boot_enabled && mok_key_enrolled; then
                fail "Key was rejected com MOK enrolada — kernel novo? Rode sem --sign-only."
            elif secure_boot_enabled; then
                mok_fail "Key was rejected — falta Enroll MOK na tela azul."
            else
                fail "modprobe vboxdrv: ${err}"
            fi
        else
            fail "modprobe vboxdrv: ${err:-falhou}"
        fi
    fi
    modprobe vboxnetflt 2>/dev/null || true
    modprobe vboxnetadp 2>/dev/null || true
    if ! vbox_modules_loaded; then
        diagnose_silent_load_failure "vboxdrv"
        fail "vboxdrv não apareceu no lsmod após modprobe (ver diagnóstico automático acima)."
    fi
    progress_mark "MODULES_LOADED"
}

write_qa_log() {
    local log_dir log_file
    log_dir="${QA_LOG_DIR:-$(pwd)/qa-logs}"
    mkdir -p "$log_dir"
    log_file="${log_dir}/10-virtualbox-sign-$(date +%Y%m%d-%H%M%S).txt"
    {
        echo "=== 10-virtualbox-sign — $(date -Iseconds 2>/dev/null || date) ==="
        echo "script: ztc-whonix-sign-virtualbox-modules.sh"
        echo "host: $(hostname 2>/dev/null || echo ?)"
        echo "kernel: $(uname -r 2>/dev/null || echo ?)"
        echo "secure_boot: $(mokutil --sb-state 2>/dev/null || echo ?)"
        echo "mok_enrolled: $(mok_key_enrolled && echo SIM || echo NAO)"
        echo "lsmod vbox: $(lsmod 2>/dev/null | grep '^vbox' | tr '\n' ' ' || echo vazio)"
        echo "RESULTADO: PASS"
        echo "exit_code: 0"
        echo "--- tail sign log ---"
        tail -20 "$LOG_FILE" 2>/dev/null || true
    } >"$log_file"
    _g "  QA log: $log_file"
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -y) ASSUME_YES=1; shift ;;
            --qa-log) QA_LOG=1; shift ;;
            --qa-log-dir) QA_LOG_DIR="${2:?}"; QA_LOG=1; shift 2 ;;
            --sign-only) SIGN_ONLY=1; shift ;;
            -h|--help) usage ;;
            *)
                echo "Opção desconhecida: $1" >&2
                usage
                ;;
        esac
    done
}

main() {
    parse_args "$@"

    [[ "${EUID}" -eq 0 ]] || fail "Execute como root (sudo)."
    touch "$LOG_FILE"

    _m ""
    _m "==============================================================="
    _m "  ztc-whonix-sign-virtualbox-modules.sh — assinar + carregar vbox"
    _m "==============================================================="
    _b "  Kernel: $(uname -r)"
    log "===== Hub Passo 10 — assinatura módulos VirtualBox ====="

    if vbox_modules_loaded; then
        _g "Módulos vbox já carregados — nada a fazer."
        progress_mark "MODULES_LOADED"
        [[ "$QA_LOG" -eq 1 ]] && write_qa_log
        pass_result
    fi

    if secure_boot_enabled; then
        _y "Secure Boot ON — assinatura MOK obrigatória."
        mok_key_enrolled || mok_fail "Chave MOK não enrolada — tela azul Enroll MOK primeiro."
        _g "MOK enrolada — prosseguindo com vboxconfig + sign-file."
        progress_mark "MOK_ENROLLED"
        ensure_kernel_headers
        [[ "$SIGN_ONLY" -eq 0 ]] && run_vboxconfig
        sign_modules
    else
        _g "Secure Boot OFF — vboxconfig + modprobe (sem assinatura)."
        [[ "$SIGN_ONLY" -eq 0 ]] && run_vboxconfig
    fi

    load_modules
    log "[4/4] Verificação..."
    grep '^vbox' /proc/modules | tee -a "$LOG_FILE" >&2 || true
    _g "vboxdrv carregado com sucesso."
    _b "Próximo: sudo ./ztc-whonix-verify-virtualbox-host.sh --qa-log"

    [[ "$QA_LOG" -eq 1 ]] && write_qa_log
    pass_result
}

main "$@"
