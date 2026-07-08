#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Privacy-OS-Hub contributors
#
# ztc-whonix-verify-virtualbox-host.sh — Privacy-OS-Hub
#
# Validação READ-ONLY do VirtualBox no HOST (Debian/Ubuntu).
# Não instala nem assina — só reporta PASS/FAIL + --qa-log.
#
# Uso:
#   sudo ./ztc-whonix-verify-virtualbox-host.sh [--qa-log]
#
# Exit codes:
#   0 — PASS (vboxdrv OK)
#   1 — FAIL (problema crítico)
#   2 — FAIL_MOK (falta tela azul Enroll MOK)
#   3 — FAIL_SIGN (MOK OK; falta ztc-whonix-sign-virtualbox-modules.sh)

set -euo pipefail

VBOX_SERIES="${VBOX_SERIES:-7.2}"
MOK_DER="/root/module-signing/MOK.der"
INSTALL_LOG="/var/log/virtualbox-install.log"
SIGN_LOG="/var/log/virtualbox-sign.log"
PROGRESS_FILE="/root/module-signing/.hub-vbox-progress"
QA_LOG=0
QA_LOG_DIR=""

PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0
CHECK_LINES=()
FAIL_SIGN_DETECTED=0
FAIL_MOK_DETECTED=0

b() { echo -e "\033[1;34m$*\033[0m"; }
g() { echo -e "\033[1;32m$*\033[0m"; }
y() { echo -e "\033[1;33m$*\033[0m"; }
r() { echo -e "\033[1;31m$*\033[0m"; }
m() { echo -e "\033[1;35m$*\033[0m"; }

usage() {
    grep '^#' "$0" | sed -e 's/^# \?//' -e '1,/^$/d' | head -n 20
    exit 0
}

record_check() {
    local status="$1" label="$2" detail="$3"
    CHECK_LINES+=("${status}|${label}|${detail}")
    case "$status" in
        PASS) PASS_COUNT=$((PASS_COUNT + 1)); g "  [PASS] ${label}: ${detail}" ;;
        FAIL) FAIL_COUNT=$((FAIL_COUNT + 1)); r "  [FAIL] ${label}: ${detail}" ;;
        WARN) WARN_COUNT=$((WARN_COUNT + 1)); y "  [WARN] ${label}: ${detail}" ;;
        SKIP) y "  [SKIP] ${label}: ${detail}" ;;
    esac
}

secure_boot_enabled() {
    command -v mokutil >/dev/null 2>&1 \
        && mokutil --sb-state 2>/dev/null | grep -qi "enabled"
}

mok_key_enrolled() {
    local out fp_der
    [[ -f "$MOK_DER" ]] || return 1
    out="$(mokutil --test-key "$MOK_DER" 2>&1 || true)"
    if echo "$out" | grep -qiE 'not enrolled|is not enrolled'; then
        return 1
    fi
    if echo "$out" | grep -qiE 'is enrolled|already enrolled'; then
        return 0
    fi
    fp_der="$(openssl x509 -inform DER -in "$MOK_DER" -noout -fingerprint -sha1 2>/dev/null \
        | cut -d= -f2 | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]:')"
    [[ -n "$fp_der" ]] \
        && mokutil --list-enrolled 2>/dev/null \
            | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]:' \
            | grep -q "$fp_der"
}

vbox_modules_loaded() {
    # /proc/modules direto — 'lsmod | grep -q' sob pipefail dá falso negativo
    # (SIGPIPE no lsmod quando grep -q casa cedo). Campo bloodyroar 08/jul/2026.
    grep -q '^vboxdrv ' /proc/modules 2>/dev/null
}

grep_log_resultado() {
    local logfile="$1"
    [[ -f "$logfile" ]] || { echo ""; return; }
    grep 'RESULTADO:' "$logfile" 2>/dev/null | tail -1 | sed 's/.*RESULTADO: *//' | awk '{print $1}'
}

check_secure_boot() {
    b "[1/9] Secure Boot..."
    if ! command -v mokutil >/dev/null 2>&1; then
        record_check SKIP "mokutil" "comando ausente"
        return
    fi
    local sb
    sb="$(mokutil --sb-state 2>/dev/null || true)"
    if echo "$sb" | grep -qi "enabled"; then
        record_check PASS "Secure Boot" "$sb"
    elif echo "$sb" | grep -qi "disabled"; then
        record_check WARN "Secure Boot" "desligado — assinatura MOK não obrigatória"
    else
        record_check WARN "Secure Boot" "${sb:-estado desconhecido}"
    fi
}

check_mok_enrolled() {
    b "[2/9] Chave MOK no firmware..."
    if ! secure_boot_enabled; then
        record_check SKIP "MOK enrolada" "Secure Boot off"
        return
    fi
    if [[ ! -f "$MOK_DER" ]]; then
        record_check FAIL "MOK.der" "ausente — rode ztc-whonix-install-virtualbox.sh"
        FAIL_MOK_DETECTED=1
        return
    fi
    local out cn
    cn="$(openssl x509 -inform DER -in "$MOK_DER" -noout -subject 2>/dev/null \
        | sed 's/subject=//' || echo '?')"
    out="$(mokutil --test-key "$MOK_DER" 2>&1 || true)"
    if mok_key_enrolled; then
        record_check PASS "MOK enrolada" "$cn"
    else
        record_check FAIL "MOK enrolada" "$(echo "$out" | head -1) — falta tela azul"
        FAIL_MOK_DETECTED=1
    fi
}

check_vbox_package() {
    b "[3/9] Pacote VirtualBox..."
    local pkg="virtualbox-${VBOX_SERIES}" ver
    if dpkg -l "$pkg" 2>/dev/null | grep -q '^ii'; then
        ver="$(dpkg-query -W -f='${Version}' "$pkg" 2>/dev/null || echo '?')"
        record_check PASS "pacote ${pkg}" "$ver"
    else
        record_check FAIL "pacote ${pkg}" "não instalado — ztc-whonix-install-virtualbox.sh"
    fi
}

check_vbox_modules() {
    b "[4/9] Módulos kernel vboxdrv..."
    if vbox_modules_loaded; then
        record_check PASS "vboxdrv" "$(lsmod | grep '^vbox' | tr '\n' ' ')"
        return
    fi
    local err
    err="$(modprobe vboxdrv 2>&1 || true)"
    if vbox_modules_loaded; then
        record_check PASS "vboxdrv" "carregado após modprobe"
        return
    fi
    if echo "$err" | grep -qi 'Key was rejected'; then
        if secure_boot_enabled && mok_key_enrolled; then
            record_check FAIL "vboxdrv" "Key was rejected — kernel novo; rode ztc-whonix-sign-virtualbox-modules.sh"
            FAIL_SIGN_DETECTED=1
        else
            record_check FAIL "vboxdrv" "Key was rejected — falta Enroll MOK"
            FAIL_MOK_DETECTED=1
        fi
    elif [[ -z "$err" ]]; then
        # modprobe "teve sucesso" (sem stderr) mas o módulo não carregou —
        # falha silenciosa. Sem isso, o operador só vê "não carregado" sem
        # nenhuma pista real de causa (blacklist? vermagic? outro motivo?).
        local blacklist_hit vermagic_mod vermagic_run modpath detail
        blacklist_hit="$(grep -rHn 'blacklist[[:space:]]\+vboxdrv\b' /etc/modprobe.d/ /etc/modules-load.d/ 2>/dev/null | head -1 || true)"
        modpath="$(modinfo -F filename vboxdrv 2>/dev/null || true)"
        detail="modprobe retornou sucesso mas vboxdrv não entrou no kernel (falha silenciosa)."
        if [[ -n "$blacklist_hit" ]]; then
            detail="${detail} Provável causa: entrada de blacklist em ${blacklist_hit}"
        elif [[ -n "$modpath" ]]; then
            vermagic_mod="$(modinfo -F vermagic "$modpath" 2>/dev/null | awk '{print $1}')"
            vermagic_run="$(uname -r)"
            if [[ -n "$vermagic_mod" && "$vermagic_mod" != "$vermagic_run" ]]; then
                detail="${detail} Provável causa: vermagic '${vermagic_mod}' != kernel rodando '${vermagic_run}' (recompile com ztc-whonix-sign-virtualbox-modules.sh)."
            else
                detail="${detail} Rode: sudo dmesg | grep -i vbox"
            fi
        else
            detail="${detail} .ko não encontrado para $(uname -r) — rode ztc-whonix-sign-virtualbox-modules.sh."
        fi
        record_check FAIL "vboxdrv" "$detail"
        FAIL_SIGN_DETECTED=1
    elif secure_boot_enabled && mok_key_enrolled; then
        record_check FAIL "vboxdrv" "não carregado — rode ztc-whonix-sign-virtualbox-modules.sh -y"
        FAIL_SIGN_DETECTED=1
    else
        record_check FAIL "vboxdrv" "${err:-não carregado}"
    fi
}

check_vboxmanage() {
    b "[5/9] VBoxManage..."
    if ! command -v VBoxManage >/dev/null 2>&1; then
        record_check FAIL "VBoxManage" "ausente"
        return
    fi
    local ver err
    err="$(VBoxManage --version 2>&1 || true)"
    ver="$(echo "$err" | tail -1)"
    if vbox_modules_loaded; then
        record_check PASS "VBoxManage" "$ver"
    else
        record_check WARN "VBoxManage" "${ver} (módulos ausentes — VMs não ligam)"
    fi
}

check_extpack() {
    b "[6/9] Extension Pack (opcional)..."
    if ! command -v VBoxManage >/dev/null 2>&1; then
        record_check SKIP "Extension Pack" "VBoxManage ausente"
        return
    fi
    # 'Usable: true' fica ~7 linhas após o nome do pack — grep -A3 nunca
    # alcançava e dava WARN falso com extpack instalado (bloodyroar 08/jul).
    local extlist
    extlist="$(VBoxManage list extpacks 2>/dev/null || true)"
    if grep -q "Oracle VirtualBox Extension Pack" <<<"$extlist" \
        && grep -qE '^Usable: *true' <<<"$extlist"; then
        record_check PASS "Extension Pack" "instalado e utilizável"
    else
        record_check WARN "Extension Pack" "ausente — rode install -y (USB 2.0 etc.)"
    fi
}

check_logs() {
    b "[7/9] Logs (install + sign)..."
    local ir sr
    ir="$(grep_log_resultado "$INSTALL_LOG")"
    sr="$(grep_log_resultado "$SIGN_LOG")"
    if [[ "$ir" == "PASS" ]]; then
        record_check PASS "install log" "RESULTADO: PASS"
    elif [[ "$ir" == "PASS_PENDING_MOK_REBOOT" ]]; then
        record_check WARN "install log" "PASS_PENDING_MOK_REBOOT"
    elif [[ "$ir" == "PASS_NEEDS_SIGN" ]]; then
        if [[ "$sr" == "PASS" ]]; then
            record_check PASS "install log" "PASS_NEEDS_SIGN (superado — sign PASS)"
        else
            record_check WARN "install log" "PASS_NEEDS_SIGN — falta sign"
        fi
    elif [[ -n "$ir" ]]; then
        record_check WARN "install log" "RESULTADO: ${ir}"
    else
        record_check WARN "install log" "${INSTALL_LOG} sem RESULTADO"
    fi
    if [[ "$sr" == "PASS" ]]; then
        record_check PASS "sign log" "RESULTADO: PASS"
    elif [[ -f "$SIGN_LOG" ]]; then
        record_check WARN "sign log" "RESULTADO: ${sr:-?}"
    else
        record_check WARN "sign log" "${SIGN_LOG} ausente"
    fi
}

check_progress() {
    b "[8/9] Arquivo de progresso..."
    if [[ ! -f "$PROGRESS_FILE" ]]; then
        record_check WARN "progresso" "${PROGRESS_FILE} ausente (primeira vez?)"
        return
    fi
    record_check PASS "progresso" "$(tr '\n' ' ' <"$PROGRESS_FILE")"
}

check_vboxusers() {
    b "[9/9] Grupo vboxusers..."
    local user="${SUDO_USER:-${USER:-}}"
    if [[ -z "$user" || "$user" == "root" ]]; then
        record_check SKIP "vboxusers" "SUDO_USER indefinido"
        return
    fi
    if id -nG "$user" 2>/dev/null | grep -qw vboxusers; then
        record_check PASS "vboxusers" "$user é membro"
    else
        record_check WARN "vboxusers" "$user não no grupo — relogin"
    fi
}

write_qa_log() {
    local log_dir log_file final_result exit_code
    log_dir="${QA_LOG_DIR:-$(pwd)/qa-logs}"
    mkdir -p "$log_dir"
    log_file="${log_dir}/10-virtualbox-host-$(date +%Y%m%d-%H%M%S).txt"
    if vbox_modules_loaded; then
        final_result="PASS"; exit_code=0
    elif [[ "$FAIL_MOK_DETECTED" -eq 1 ]]; then
        final_result="FAIL_MOK"; exit_code=2
    elif [[ "$FAIL_SIGN_DETECTED" -eq 1 ]] || [[ "$FAIL_COUNT" -gt 0 ]]; then
        final_result="FAIL_SIGN"; exit_code=3
    else
        final_result="FAIL"; exit_code=1
    fi
    {
        echo "=== 10-virtualbox-host — $(date -Iseconds 2>/dev/null || date) ==="
        echo "script: ztc-whonix-verify-virtualbox-host.sh"
        echo "host: $(hostname 2>/dev/null || echo ?)"
        echo "kernel: $(uname -r 2>/dev/null || echo ?)"
        echo "secure_boot: $(mokutil --sb-state 2>/dev/null || echo ?)"
        echo "--- checks ---"
        for line in "${CHECK_LINES[@]}"; do echo "$line" | tr '|' ' '; done
        echo "---"
        echo "PASS: ${PASS_COUNT}  FAIL: ${FAIL_COUNT}  WARN: ${WARN_COUNT}"
        echo "RESULTADO: ${final_result}"
        echo "exit_code: ${exit_code}"
        [[ -f "$PROGRESS_FILE" ]] && echo "--- progress ---" && cat "$PROGRESS_FILE"
        [[ -f "$SIGN_LOG" ]] && echo "--- tail sign log ---" && tail -8 "$SIGN_LOG"
    } >"$log_file"
    g "  QA log: $log_file"
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --qa-log) QA_LOG=1; shift ;;
            --qa-log-dir) QA_LOG_DIR="${2:?}"; QA_LOG=1; shift 2 ;;
            -h|--help) usage ;;
            *) r "Opção desconhecida: $1"; usage ;;
        esac
    done
}

main() {
    parse_args "$@"

    echo ""
    m "==============================================================="
    m "  ztc-whonix-verify-virtualbox-host.sh — validação host (Passo 10)"
    m "==============================================================="
    m "  Fluxo: install → (tela azul) → sign → verify (este script)"
    echo ""

    check_secure_boot
    check_mok_enrolled
    check_vbox_package
    check_vbox_modules
    check_vboxmanage
    check_extpack
    check_logs
    check_progress
    check_vboxusers

    echo ""
    m "----- Resumo -----"
    g "  PASS: ${PASS_COUNT}"
    [[ "$WARN_COUNT" -gt 0 ]] && y "  WARN: ${WARN_COUNT}"
    [[ "$FAIL_COUNT" -gt 0 ]] && r "  FAIL: ${FAIL_COUNT}"
    echo ""

    if vbox_modules_loaded; then
        g "RESULTADO: PASS — VirtualBox funcional no host."
        g "  Próximo: ztc-whonix-verify-image.sh → ztc-whonix-import-ova.sh"
        [[ "$QA_LOG" -eq 1 ]] && write_qa_log
        exit 0
    fi
    if [[ "$FAIL_MOK_DETECTED" -eq 1 ]]; then
        r "RESULTADO: FAIL_MOK — falta tela azul Enroll MOK."
        r "  Próximo: sudo systemctl reboot -i → Enroll MOK → sign"
        [[ "$QA_LOG" -eq 1 ]] && write_qa_log
        exit 2
    fi
    if [[ "$FAIL_SIGN_DETECTED" -eq 1 ]]; then
        y "RESULTADO: FAIL_SIGN — MOK OK; falta assinar módulos (kernel novo?)."
        y "  Próximo: sudo ./ztc-whonix-sign-virtualbox-modules.sh -y --qa-log"
        [[ "$QA_LOG" -eq 1 ]] && write_qa_log
        exit 3
    fi
    r "RESULTADO: FAIL — corrija itens [FAIL] acima."
    [[ "$QA_LOG" -eq 1 ]] && write_qa_log
    exit 1
}

main "$@"
