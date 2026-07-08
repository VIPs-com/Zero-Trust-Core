#!/usr/bin/env bash
#
# ztc-whonix-verify-image.sh — Zero Trust Core
#
# Playbook W01 — verificação PGP da imagem Whonix (somente verify, sem import).
# Baixa derivative.asc, confere fingerprint informado pelo operador (-f),
# executa gpg --verify com VALIDSIG + fingerprint. Aborta em qualquer falha.
#
# Uso:
#   ./ztc-whonix-verify-image.sh \
#        -i /caminho/Whonix-LXQt-VERSAO.Intel_AMD64.ova \
#        -s /caminho/Whonix-LXQt-VERSAO.Intel_AMD64.ova.asc \
#        -f "FINGERPRINT_DA_wiki_Verify_the_images" \
#        [-k /caminho/derivative.asc] \
#        [--kvm]   # .libvirt.xz em vez de .ova
#
# Se -k omitido, baixa de https://www.whonix.org/keys/derivative.asc (3 tentativas)
# Próximo passo após OK: ztc-whonix-import-ova.sh ou import manual.
#
# Changelog jul/2026 (espelho Privacy-OS-Hub v1.0.9.1):
#   - retry + timeout no download de derivative.asc
#   - VALIDSIG + fingerprint (não "Good signature"); EXPKEYSIG

set -euo pipefail

IMAGE=""
SIG=""
KEY_FILE=""
EXPECTED_FPR=""
FORMAT="ova"
DERIVATIVE_URL="https://www.whonix.org/keys/derivative.asc"
GNUPGHOME_DIR=""
WORKDIR=""
FETCH_RETRIES=3
FETCH_TIMEOUT=120

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >&2; }
fail() { log "ERRO: $*"; cleanup; exit 1; }

cleanup() {
    [[ -n "$GNUPGHOME_DIR" && -d "$GNUPGHOME_DIR" ]] && rm -rf "$GNUPGHOME_DIR"
    [[ -n "$WORKDIR" && -d "$WORKDIR" ]] && rm -rf "$WORKDIR"
}
trap cleanup EXIT

usage() {
    grep '^#' "$0" | sed -e 's/^# \?//' -e '1,/^$/d' | head -n 20
    exit 1
}

fetch_url() {
    local url="$1" dest="$2"
    local n
    for ((n=1; n<=FETCH_RETRIES; n++)); do
        if curl -fsSL --max-time "$FETCH_TIMEOUT" -o "$dest" "$url" && [[ -s "$dest" ]]; then
            return 0
        fi
        log "AVISO: download falhou (tentativa ${n}/${FETCH_RETRIES}): $url"
        sleep 5
    done
    return 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -i) IMAGE="$2"; shift 2 ;;
        -s) SIG="$2"; shift 2 ;;
        -k) KEY_FILE="$2"; shift 2 ;;
        -f) EXPECTED_FPR="$2"; shift 2 ;;
        --kvm) FORMAT="libvirt"; shift ;;
        -h) usage ;;
        *) fail "Opção desconhecida: $1" ;;
    esac
done

[[ -n "$IMAGE" ]] || fail "Informe a imagem com -i."
[[ -n "$SIG" ]]    || fail "Informe a assinatura com -s."
[[ -n "$EXPECTED_FPR" ]] || fail "Informe -f (de https://www.whonix.org/wiki/Verify_the_images)."
[[ -f "$IMAGE" ]] || fail "Imagem não encontrada: $IMAGE"
[[ -f "$SIG" ]]   || fail "Assinatura não encontrada: $SIG"

command -v gpg >/dev/null 2>&1 || fail "gpg não encontrado."
command -v curl >/dev/null 2>&1 || fail "curl não encontrado."

log "===== ztc-whonix-verify-image (formato: $FORMAT) ====="

WORKDIR="$(mktemp -d)"
GNUPGHOME_DIR="$(mktemp -d)"
chmod 700 "$GNUPGHOME_DIR"
export GNUPGHOME="$GNUPGHOME_DIR"

if [[ -z "$KEY_FILE" ]]; then
    KEY_FILE="${WORKDIR}/derivative.asc"
    log "Baixando derivative.asc (até ${FETCH_RETRIES} tentativas)..."
    fetch_url "$DERIVATIVE_URL" "$KEY_FILE" || fail "Falha ao baixar derivative.asc após ${FETCH_RETRIES} tentativas"
elif [[ ! -f "$KEY_FILE" ]]; then
    fail "Chave não encontrada: $KEY_FILE"
fi

log "Importando chave..."
gpg --quiet --import "$KEY_FILE" 2>&1 | cat >&2

normalized_expected="$(echo "$EXPECTED_FPR" | tr -d ' ' | tr '[:lower:]' '[:upper:]')"
matched=0
while read -r fpr; do
    normalized_actual="$(echo "$fpr" | tr -d ' ' | tr '[:lower:]' '[:upper:]')"
    [[ "$normalized_actual" == "$normalized_expected" ]] && matched=1 && break
done < <(gpg --with-colons --fingerprint 2>/dev/null | awk -F: '/^fpr:/ {print $10}')

[[ "$matched" -eq 1 ]] || fail "Fingerprint NÃO confere com -f. Confira a wiki oficial."

log "Fingerprint OK."

gpg_log="${WORKDIR}/whonix-verify.log"
gpg --status-fd 1 --verify-options show-notations --verify "$SIG" "$IMAGE" \
    >"$gpg_log" 2>&1 || true

if grep -q "^\[GNUPG:\] VALIDSIG .*${normalized_expected}" "$gpg_log"; then
    cat "$gpg_log" >&2
    log "===== OK — VALIDSIG + fingerprint. Próximo: ztc-whonix-import-ova.sh ====="
    exit 0
fi
if grep -qi "EXPKEYSIG" "$gpg_log"; then
    cat "$gpg_log" >&2
    fail "EXPKEYSIG — reimporte derivative.asc e confira fingerprint em Verify_the_images."
fi
cat "$gpg_log" >&2
fail "Assinatura INVÁLIDA. NÃO importe."
