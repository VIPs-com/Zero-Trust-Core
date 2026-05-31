# Gabarito — CHECKPOINTs 1 a 3

**Público:** instrutor, mantenedor e aluno em autoavaliação · **Versão do curso:** 1.0.2 → meta **1.0.3**  
**Licença:** [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)

Use este arquivo para marcar **como provar** cada item do curso. Não cole senhas, PINs, UIDs reais de produção nem conteúdo de `revogacao.asc` em issues públicas — use placeholders em evidências de turma.

**No curso:** após cada 🏁 CHECKPOINT há um resumo; aqui está o detalhe (comandos e saída esperada).

---

## CHECKPOINT 1 — Identidade air-gapped

| # | Item do curso | Como validar | Saída / critério de sucesso |
| :---: | --- | --- | --- |
| 1 | Pendrive Tails gravado e verificado | No **host**: `gpg --verify tails*.img.sig` (ou fluxo [COMANDO 6.1 OpenPGP](https://github.com/VIPs-com/OpenPGP-GPG-do-Zero-ao-Expert/blob/main/%F0%9F%8E%93%20OpenPGP-GPG%20do%20Zero%20ao%20Expert%20-%20Vers%C3%A3o%201.0.md#comando-6-1-tails-ztc)); boot Tails uma vez | Assinatura **Good signature**; Tails inicia |
| 2 | Master [C] só no Tails, rede off | No Tails: `nmcli networking off` ou cabo desconectado; `gpg --full-generate-key` | Chave primária `sec#` ou master só em smartcard depois do `keytocard` |
| 3 | Subkeys [S][E][A] listadas | `gpg -K --with-subkey-fingerprint` | Três subkeys (sign, encrypt, auth) visíveis |
| 4 | `revogacao.asc` em 2 contextos | Inventário físico + `ls` em mídia air-gap | Arquivo existe; fingerprint anotado no papel/metal |
| 5 | Backup master offline | `age -d` testa restore **sem** rede no PC diário | Arquivo `.age` abre no Tails; **nunca** copiar master para PC online |
| 6 | PC diário sem master | `gpg -K` no Debian/WSL | Mostra `sec>` subkeys ou `ssb` — **não** `sec` da master exportável |
| 7 | Explica NTAG × smartcard × master | Pergunta oral ou 3 linhas escritas | NTAG = keyfile KeePass; smartcard = subkeys; master = só Tails |

**Comandos de referência (lab):**

```sh
# Tails ou host — listar identidade
gpg -K --with-subkey-fingerprint

# PC diário — deve NÃO listar sec da master (após keytocard)
gpg -K | head -20
```

**Falha comum → ação:** master apareceu no PC diário → pare; exporte só públicas; refaça `keytocard` no Tails.

---

## CHECKPOINT 2 — Token + cofre + SSH

| # | Item do curso | Como validar | Saída / critério de sucesso |
| :---: | --- | --- | --- |
| 1 | `gpg --card-status` OK | Cartão inserido: `gpg --card-status` | `Signature key` … `URL of public key` sem erro de leitor |
| 2 | Assinatura teste | `echo test | gpg --clearsign` (PIN) | Bloco `BEGIN PGP SIGNED MESSAGE` |
| 3 | Três NTAG com mesmo keyfile | `nfc-list` em cada tag; hash do keyfile idêntico | Mesmo UID de conteúdo gravado (3 mídias) ou política 1+2 espelho documentada |
| 4 | Backup `.age` do keyfile | [COMANDO 2B.2](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-2b2-backup-cifrado-do-keyfile-age--obrigatório-antes-dos-ntags): `age -d file.age > /tmp/kf.test` | Arquivo restaurado = byte-a-byte do original |
| 5 | KeePass abre | Senha + keyfile (arquivo ou NTAG) | KeePassXC abre entrada de lab |
| 6 | VeraCrypt monta | `veracrypt -t /path/vault.hc /mount/point` | `.kdbx` visível em `$ZTC_MOUNT_POINT` |
| 7 | SSH via subchave [A] | `ssh-add -L`; `ssh -T git@github.com` | Chave listada; GitHub: *Hi USER! You've successfully authenticated* |
| 8 | Segundo cartão ou backup subkeys | Inventário | Smartcard B **ou** export cifrado de backup documentado |

**NFC / script 5.3 (Expert):**

```sh
nfc-list                    # tag presente → UID
~/bin/ztc-open-cofre.sh     # [OK] NTAG presente → VeraCrypt → KeePassXC
# sem tag:
~/bin/ztc-open-cofre.sh; echo exit=$?   # exit ≠ 0, [FAIL] NTAG ausente
```

Evidência de turma: [issue #2](https://github.com/VIPs-com/Zero-Trust-Core/issues/2) · [`CHECKLIST-PRE-TURMA-EQUIPE.md`](./CHECKLIST-PRE-TURMA-EQUIPE.md).

**Falha comum → ação:** `sign_and_send_pubkey: signing failed` → PIN errado ou subkey [A] não no cartão; `gpg --card-status` e `keytocard` no Tails.

---

## CHECKPOINT 3 — Backup e contingência

| # | Item do curso | Como validar | Saída / critério de sucesso |
| :---: | --- | --- | --- |
| 1 | Matriz 3-2-1-1-0 preenchida | Planilha ou tabela no caderno com **caminhos reais** | Cada ativo (master, subkeys, keyfile, kdbx, vault) tem ≥3 cópias em ≥2 mídias |
| 2 | HD externo + `sha256` | `sha256sum -c manifest.txt` após cópia | `OK` em todos os blobs listados |
| 3 | VM só WireGuard | `ssh` na VM **sem** WG falha; com WG OK | Acesso off-site conforme [COMANDO 4.2](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-42-backup-frio-no-hd-externo) |
| 4 | `ztc-health.sh` | `~/bin/ztc-health.sh` (+ `--check-conf` se Expert) | Sem linhas `[FAIL]` críticas; cartão detectado |
| 5 | Ritual backup documentado | Calendário + cron ou checklist mensal | Data da última execução anotada |
| 6 | Restore test | Restaurar **um** blob (ex.: `.kdbx` ou keyfile `.age`) do HD frio | Arquivo abre no ambiente de lab |
| 7 | Simulação 6.1 | Mesa: perda cartão #1 → fluxo NTAG #2 | Checklist 6.1 assinado com data |
| 8 | 6.2 revogação lab (Expert) | Tails: gerar revogação de chave **descartável** ou revisar `revogacao.asc` | Aluno descreve `gpg --import` + `--send-keys` sem publicar ID real |
| 9 | Runbook impresso | PDF Módulo 6 no cofre físico | Fases 1–3 acessíveis sem internet |

**Comandos de referência:**

```sh
~/bin/ztc-health.sh --check-conf
~/bin/ztc-rsync-offsite.sh   # dry-run se documentado no COMANDO 4.2.3
sha256sum -c manifest.txt
```

**Rubrica de mesa (6.1):** em ≤30 min o aluno monta cofre com NTAG #2 e autentica SSH com cartão B **sem** pedir master online.

---

## Folha rápida do instrutor (tempos)

| Aula sugerida | Conteúdo | CHECKPOINT alvo |
| --- | --- | --- |
| 1 | §0 + Mód. 0–1 (Tails) | — |
| 2 | Fim Mód. 1 + revisão | **CP1** |
| 3 | 2A + 2B.2–2B.3 | — |
| 4 | 3.1 + 3.2 + 5.3 opcional | **CP2** |
| 5 | Mód. 4–6 + simulação | **CP3** |

FAQ de erros: [`FAQ-TROUBLESHOOTING.md`](./FAQ-TROUBLESHOOTING.md).

---

*VIPs-com · complemento à [AUDITORIA-v1.0.1.md](./AUDITORIA-v1.0.1.md) (roadmap v1.0.3)*
