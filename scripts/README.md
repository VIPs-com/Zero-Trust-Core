# Scripts Zero Trust Core (v1)

Scripts oficiais do curso [Zero Trust Core Expert](https://github.com/VIPs-com/Zero-Trust-Core). Correspondem aos COMANDOs **4.2.3**, **5.1**, **5.2** e **5.3** no arquivo canônico do curso.

## Instalação

```sh
mkdir -p ~/bin ~/ztc-backup/manifest
cp ztc-health.sh ztc-rsync-offsite.sh ztc-open-cofre.sh ztc-close-cofre.sh ~/bin/
chmod +x ~/bin/ztc-*.sh
cp ztc.conf.example ~/ztc-backup/ztc.conf
# Edite ~/ztc-backup/ztc.conf com seus caminhos e IP da VM (WireGuard)
~/bin/ztc-health.sh --check-conf
```

## Arquivos

| Arquivo | Função |
| --- | --- |
| `ztc-health.sh` | `--check-conf` + smartcard, `ssh-add`, NFC, manifesto |
| `ztc-rsync-offsite.sh` | Envia `vault.hc` + manifestos para VM (só blobs opacos) |
| `ztc-open-cofre.sh` | NTAG opcional → monta VeraCrypt → abre KeePassXC |
| `ztc-close-cofre.sh` | Detecta KeePassXC aberto → `sync` → desmonta VeraCrypt |
| `ztc.conf.example` | Modelo de configuração (`ZTC_*`) |

## Segurança

- Nunca coloque senhas, keyfiles ou chaves PGP em `ztc.conf`.
- A VM off-site deve receber apenas arquivos **já criptografados**.
- Revise o script antes de agendar no `cron`.

## Licença

Mesma do repositório: [CC BY-SA 4.0](../LICENSE).
