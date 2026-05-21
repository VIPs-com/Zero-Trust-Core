# FAQ — troubleshooting Zero Trust Core Expert

**Versão:** 1.0.2 (esqueleto v1.0.3) · Atualize após turma piloto.

| Sintoma | Causa provável | O que fazer |
| --- | --- | --- |
| Tails não boota | BIOS/UEFI, pendrive ruim, Secure Boot | Regravar COMANDO 6.1 OpenPGP; testar outra porta USB |
| `gpg: signing failed: No secret key` | Subkey não no cartão ou agente errado | `gpg --card-status`; refazer `keytocard` no Tails |
| `gpg-agent` não pede PIN no SSH | Socket WSL vs Linux nativo | Apêndice D.1; `gpgconf --kill gpg-agent` |
| VeraCrypt `Wrong password` com senha certa | Header corrompido ou `-t` em versão antiga | `veracrypt --version`; COMANDO 3.1.1 flags 1.26.24 |
| KeePass “keyfile invalid” | NTAG não é o keyfile gravado no 2B.3 | Restaurar de `keepass-keyfile.ztc.age` (2B.2) |
| `nfc-list` vazio | Driver, cabo, tag não ISO14443A | `lsusb`; outro leitor (ver inventário Kit B) |
| `ztc-open-cofre.sh` FAIL NTAG ausente | UID errado em `ztc.conf` ou tag longe | `nfc-list` → copiar UID exato para `ZTC_NFC_UID` |
| Script monta sem NFC | `ZTC_NFC_UID=""` | Esperado em lab sem leitor; turma Expert deve preencher UID |
| `ssh -T git@github.com` Permission denied | Chave [A] não no agente | `gpg --card-status`; `ssh-add -L` |
| `ztc-health.sh` FAIL card | Cartão não inserido ou CCID | Reinserir cartão; `pcscd` ativo |
| rsync off-site falha | WG down ou `ZTC_*` paths | `ztc-health.sh --check-conf`; testar `ping` na VM |
| Restore `.age` falha | Passphrase errada ou arquivo truncado | Regenerar backup 2B.2 no Tails |
| iPhone sem smartcard | Limitação da plataforma | Onboarding §0; fluxo PC/Android OpenKeychain |
| Aluno só Windows | NFC 5.3 não suportado nativamente | WSL2 D.1 **ou** PC Linux/USB live para Mód. 5.3 |
| Revogação publicada por engano | Lab 6.2 em chave descartável | Usar subkey de teste; nunca ID de produção |

**Instrutor:** registre novos itens após a turma piloto (issue ou PR em `docs/FAQ-TROUBLESHOOTING.md`).

---

*Ver também: [GABARITO-CHECKPOINTS.md](./GABARITO-CHECKPOINTS.md) · [CHECKLIST-PRE-TURMA-EQUIPE.md](./CHECKLIST-PRE-TURMA-EQUIPE.md)*
