# FAQ — troubleshooting Zero Trust Core Expert

**Versão:** 1.0.2 (esqueleto v1.0.3) · Atualize após turma piloto.

| Sintoma | Causa provável | O que fazer |
| --- | --- | --- |
| Tails não boota | BIOS/UEFI, pendrive ruim, Secure Boot | Regravar [COMANDO 6.1 OpenPGP](https://github.com/VIPs-com/OpenPGP-GPG-do-Zero-ao-Expert/blob/main/%F0%9F%8E%93%20OpenPGP-GPG%20do%20Zero%20ao%20Expert%20-%20Vers%C3%A3o%201.0.md#comando-6-1-tails-ztc); testar outra porta USB |
| `gpg: signing failed: No secret key` | Subkey não no cartão ou agente errado | `gpg --card-status`; refazer `keytocard` no Tails |
| `gpg-agent` não pede PIN no SSH | Socket WSL vs Linux nativo | Apêndice D.1; `gpgconf --kill gpg-agent` |
| `veracrypt: command not found` após `apt install` | VeraCrypt **não está** nos repos Debian/Ubuntu — instalação via `.deb` oficial | Baixar em veracrypt.fr/en/Downloads.html → `sudo dpkg -i veracrypt-*.deb` (em Debian 13, use o .deb Ubuntu 22.04 — compatível via glibc) ([COMANDO 3.1.1](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-311-criar-volume-veracrypt)) |
| VeraCrypt `Wrong password` com senha certa | Header corrompido ou `-t` em versão antiga | `veracrypt --version`; [COMANDO 3.1.1](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-311-criar-volume-veracrypt) flags 1.26.24 |
| KeePass “keyfile invalid” | NTAG não é o keyfile gravado no 2B.3 | Restaurar de `keepass-keyfile.ztc.age` (2B.2) |
| **KeePassXC diz "Destrancar falhou — você quer tentar com senha vazia?"** | `keepassxc --keyfile X file.kdbx` **ignora `--keyfile`** em 2.7.x — abre sem keyfile e falha | Use `keepassxc file.kdbx` e marque **Key File** no diálogo (ele lembra). Ou `keepassxc-cli open --key-file X file.kdbx` para CLI. Script atualizado em `ztc-open-cofre.sh` |
| `nfc-list` vazio | Driver, cabo, tag não ISO14443A | `lsusb`; outro leitor (ver inventário Kit B) |
| `ztc-open-cofre.sh` FAIL NTAG ausente | UID errado em `ztc.conf` ou tag longe | `nfc-list` → copiar UID exato para `ZTC_NFC_UID` |
| Nomes dos arquivos (`vault.hc`, `keepass-keyfile.ztc`, script `ztc-*`) são gritantes | Setup do curso é didático por design | Seção 9 do [Playbook 04](../playbooks/1-cofre/04-abrir-cofre-auto.md) — migração OpSec para nomes discretos (`archive-2023.tar`, `morning-routine.sh`, etc.) |
| Script monta sem NFC | `ZTC_NFC_UID=""` | Esperado em lab sem leitor; turma Expert deve preencher UID |
| `ssh -T git@github.com` Permission denied | Chave [A] não no agente | `gpg --card-status`; `ssh-add -L` |
| `ztc-health.sh` FAIL card | Cartão não inserido ou CCID | Reinserir cartão; `pcscd` ativo |
| rsync off-site falha | WG down ou `ZTC_*` paths | `ztc-health.sh --check-conf`; testar `ping` na VM |
| **O cofre protege contra keylogger?** | Não totalmente — keylogger captura ANTES da cripto | SO limpo (base) + Tails para alto valor + smartcard (PIN inútil sem hardware). Ver [Módulo 7 § Keylogger](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-keylogger--o-que-o-cofre-não-protege-e-como-mitigar) e [Playbook 00](../playbooks/1-cofre/00-uso-diario.md) |
| Restore `.age` falha | Passphrase errada ou arquivo truncado | Regenerar backup 2B.2 no Tails |
| iPhone sem smartcard | Limitação da plataforma | Onboarding §0; fluxo PC/Android OpenKeychain |
| Aluno só Windows | NFC 5.3 não suportado nativamente | WSL2 D.1 **ou** PC Linux/USB live para Mód. 5.3 |
| Revogação publicada por engano | Lab 6.2 em chave descartável | Usar subkey de teste; nunca ID de produção |
| `gpg --verify revogacao.asc` falha com erro | Certificado de revogação é pacote OpenPGP cru — **não** mensagem assinada | `gpg --import revogacao.asc` e `gpg --list-keys` para confirmar `[revoked:]`; `--verify` não se aplica |
| `gpg --gen-revoke` não reconhecido | Opção renomeada no GnuPG 2.2+ | Usar `gpg --generate-revocation` ([COMANDO 1.3](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-13-certificado-de-revogação-no-mesmo-dia)) |
| Cron configurado mas só dispara às vezes | Sintaxe `1-7 * 0` = OR não AND — domingos de qualquer semana + dias 1–7 de qualquer dia | Usar guarda de data: `[ "$(date +\%d)" -le 7 ] &&` ([COMANDO 5.2](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-52-cron-backup--health)) |
| Termux SSH fecha quando tela do celular desliga | Android mata processos em background por padrão | Configurações → Bateria → Termux → **Sem otimização de bateria** + rodar `termux-wake-lock` no Termux ([Apêndice G H3b](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#apêndice-g--módulos-h-turbo-híbrido)) |
| KeePassDX não abre o cofre com keyfile do NTAG | NTAG presente não é o mesmo gravado no [COMANDO 2B.3](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-2b3-gravar-o-mesmo-keyfile-em-3-ntags) | Confirmar com `nfc-list` que o UID confere; restaurar keyfile de `keepass-keyfile.ztc.age` ([COMANDO 2B.2](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-2b2-backup-cifrado-do-keyfile-age--obrigatório-antes-dos-ntags)) se necessário |
| VM no PC não acessa a rede local / rsync falha | Adaptador de rede configurado como NAT (padrão VirtualBox) | Trocar para **Bridged Adapter** nas configurações de rede da VM ([Apêndice G H5a](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#apêndice-g--módulos-h-turbo-híbrido)) |

**Instrutor:** registre novos itens após a turma piloto (issue ou PR em `docs/FAQ-TROUBLESHOOTING.md`).

---

*Ver também: [GABARITO-CHECKPOINTS.md](./GABARITO-CHECKPOINTS.md) · [CHECKLIST-PRE-TURMA-EQUIPE.md](./CHECKLIST-PRE-TURMA-EQUIPE.md)*
