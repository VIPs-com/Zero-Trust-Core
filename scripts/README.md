# Scripts Zero Trust Core (v1)

Scripts oficiais do curso [Zero Trust Core Expert](https://github.com/VIPs-com/Zero-Trust-Core), organizados por **mundo operacional** (Três Mundos).

| Mundo | Pasta | Scripts |
| --- | --- | --- |
| 🖥️ **Debian** (host diário) | [`debian/`](./debian/) | cofre, snapshot, rsync, borg, restore-test, health |
| 🔒 **Tails** (air-gap) | [`../tails/scripts/`](../tails/scripts/) | backup, health, manutenção, restore-test |
| 🧅 **Whonix** (online anônimo) | [`../whonix/scripts/`](../whonix/scripts/) | health por sessão |

Correspondem aos COMANDOs **4.2.3**, **5.1**, **5.2** e **5.3** no arquivo canônico do curso.

## Instalação (Debian)

```sh
mkdir -p ~/bin ~/ztc-backup/manifest
cd scripts/debian
cp ztc-health.sh ztc-rsync-offsite.sh ztc-open-cofre.sh ztc-close-cofre.sh ~/bin/
chmod +x ~/bin/ztc-*.sh
cp ztc.conf.example ~/ztc-backup/ztc.conf
# Edite ~/ztc-backup/ztc.conf com seus caminhos e IP da VM (WireGuard)
~/bin/ztc-health.sh --check-conf
```

Tails e Whonix: copie os scripts da pasta do respectivo mundo para `~/Persistent/bin/` (Tails) ou `~/bin/` (Whonix) — veja os guias dedicados.

## Arquivos — Debian (`debian/`)

| Arquivo | Função |
| --- | --- |
| `ztc-health.sh` | `--check-conf` + smartcard, `ssh-add`, NFC, manifesto |
| `ztc-rsync-offsite.sh` | Envia `vault.hc` + manifestos para VM (só blobs opacos · espelho) |
| `ztc-borg-offsite.sh` | **Off-site imutável (append-only):** versões à prova de ransomware na VM — a perna "1 imutável" do 3-2-1-1-0 |
| `ztc-open-cofre.sh` | NTAG opcional → monta VeraCrypt → abre KeePassXC |
| `ztc-close-cofre.sh` | Detecta KeePassXC aberto → `sync` → desmonta VeraCrypt → snapshot automático |
| `ztc-snapshot-vault.sh` | Cópia versionada do `vault.hc` (sha256 + rotação de N versões) |
| `ztc-restore-test.sh` | **Restore test (a "0 erros" do 3-2-1-1-0):** sha256 vs MANIFEST → monta snapshot read-only → abre `.kdbx` com senha + keyfile. Ritual mensal (COMANDO 4.3) |
| `ztc.conf.example` | Modelo de configuração (`ZTC_*`) |

## Arquivos — Tails (`../tails/scripts/`)

| Arquivo | Função |
| --- | --- |
| `ztc-tails-backup.sh` | Backup Persistent → USB cifrado com `age` + manifesto sha256 |
| `ztc-tails-health.sh` | Health check manual (GPG, Persistent, KeePassXC, backup) |
| `ztc-tails-manutencao.sh` | Diagnóstico do pendrive (espaço, filesystem, flash USB, limpeza) |
| `ztc-tails-restore-test.sh` | Restore test completo (descriptografa + valida .kdbx + GPG + keyfile + revogação) |

## Arquivos — Whonix (`../whonix/scripts/`)

| Arquivo | Função |
| --- | --- |
| `ztc-whonix-health.sh` | Health check por sessão (ambiente, Tor via `systemcheck`, subkeys com master ausente, gpg-agent, `age`) |

## Segurança

- Nunca coloque senhas, keyfiles ou chaves PGP em `ztc.conf`.
- A VM off-site deve receber apenas arquivos **já criptografados**.
- Revise o script antes de agendar no `cron`.

## Licença

Mesma do repositório: [CC BY-SA 4.0](../LICENSE).
