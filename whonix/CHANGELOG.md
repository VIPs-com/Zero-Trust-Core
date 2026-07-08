# Changelog — Whonix (Zero Trust Core)

## [scripts] 2026-07-07 — robustez (espelho Privacy-OS-Hub v1.0.9.1)

### `ztc-whonix-install-virtualbox.sh` (W00)
- `log()` → stderr (`tee -a "$LOG_FILE" >&2`)
- `check_repo_availability()` antes de escrever `sources.list`
- `fetch_to_file()` com retry; escrita atômica de keyring e repo
- `verify_repo_signature()`: `PIPESTATUS[0]` em `apt-get update` + detecção `NO_PUBKEY`/`BADSIG`
- `trap ERR`; aviso KVM vs vboxdrv; Extension Pack com retry

### `ztc-whonix-import-ova.sh` (W01)
- `log()` e saídas de `gpg`/`VBoxManage` → stderr
- `verify_signature()`: `VALIDSIG` + fingerprint (não depende de locale "Good signature")
- Tratamento `EXPKEYSIG`; `fetch_url()` com retry se `-k` omitido (conveniência — `-f` continua obrigatório)

### `ztc-whonix-verify-image.sh` (W01)
- Download `derivative.asc` com retry + timeout
- Verificação `VALIDSIG` + fingerprint; `EXPKEYSIG`

### `ztc-whonix-health.sh` (Workstation)
- Checagem Tor opcional (`ZTC_WHONIX_TOR_CHECK=yes`) com retry + timeout
- SOCKS `127.0.0.1:9050` + fallback transparente Whonix
- Finais de linha LF
