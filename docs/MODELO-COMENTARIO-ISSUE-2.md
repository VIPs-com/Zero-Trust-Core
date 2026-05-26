# Modelo de comentário — issue #2

**Uso:** execute os testes em [`CHECKLIST-PRE-TURMA-EQUIPE.md`](./CHECKLIST-PRE-TURMA-EQUIPE.md), cole a saída nos blocos abaixo e publique em  
https://github.com/VIPs-com/Zero-Trust-Core/issues/2  

Pode enviar **um** comentário com as duas secções ou **dois** comentários (hardware + Tails).

**Não publique:** senhas, PINs, conteúdo de `.kdbx`, keyfile em claro — mascare o UID (`04:ab:cd:xx:xx:56`).

---

## Comandos para gerar a evidência (copiar no terminal)

```sh
# Metadados
date -Is
uname -a
veracrypt --version 2>/dev/null | head -1
keepassxc --version 2>/dev/null | head -1
dpkg -l 'libnfc*' 2>/dev/null | head -5 || true
lsusb | grep -iE 'nfc|acr|122' || lsusb

# Com tag no leitor
echo "=== COM TAG ==="
time nfc-list
time ~/bin/ztc-open-cofre.sh
# (informe senha VeraCrypt; confirme KeePassXC)
veracrypt -t -d /media/veracrypt-ztc 2>/dev/null || true

# Sem tag (retire a tag antes)
echo "=== SEM TAG ==="
time ~/bin/ztc-open-cofre.sh; echo "exit=$?"
```

---

## Bloco 1 — colar no GitHub (hardware NFC)

```markdown
## Evidência — teste `ztc-open-cofre.sh`

**Data:** [PREENCHER AAAA-MM-DD]  
**Responsável:** @[PREENCHER usuario GitHub]  
**Host:** [PREENCHER ex.: Ubuntu 24.04.2 LTS / kernel 6.8.0-xx-amd64]  
**Commit / release do curso:** v1.0.2 · scripts de `master` em [PREENCHER data do clone]

### Ambiente
- **Leitor NFC:** [PREENCHER ex.: ACS ACR122U — colar linha relevante do `lsusb`]
- **libnfc:** [PREENCHER versão pacote ou saída `nfc-list --version`]
- **VeraCrypt:** [PREENCHER ex.: 1.26.24]
- **KeePassXC:** [PREENCHER ex.: 2.7.12]

### Configuração (`~/ztc-backup/ztc.conf`)
- **`ZTC_NFC_UID`:** `04:xx:xx:xx:xx:xx` *(mascarar bytes finais se issue público)*
- **`ZTC_VAULT_HC`:** `[PREENCHER caminho genérico, ex.: ~/ztc-lab/vault.hc]`
- **`ZTC_MOUNT_POINT`:** `/media/veracrypt-ztc`
- **Obs.:** `ZTC_NFC_UID` vazio? sim / não

### Com tag presente
<details>
<summary>Saída `nfc-list` (colar)</summary>

```
[PREENCHER — colar saída completa]
```

</details>

<details>
<summary>Saída `ztc-open-cofre.sh` (colar)</summary>

```
[PREENCHER — deve conter [OK] NTAG presente → prompt VeraCrypt → [OK] Abrindo KeePassXC...]
```

</details>

- **Tempo `nfc-list`:** [PREENCHER ex.: 0,3s]
- **Tempo script (com tag):** [PREENCHER]
- **KeePassXC abriu:** sim / não

### Sem tag
<details>
<summary>Saída `ztc-open-cofre.sh` sem tag (colar)</summary>

```
[PREENCHER — esperado: [FAIL] NTAG ausente (UID esperado: …)]
```

</details>

- **`exit`:** [PREENCHER — esperado: `1`]

### Conclusão (marque uma)
- [ ] **Aprovado** — turma Expert com leitor NFC + `libnfc` + `ZTC_NFC_UID` configurado
- [ ] **Aprovado com ressalva** — só fluxo manual (`ZTC_NFC_UID=""` / COMANDO 3.1.2); documentar na aula
- [ ] **Reprovado** — descrever bloqueio: [PREENCHER]

### Observações
[PREENCHER — ex.: precisou `sudo` para VeraCrypt; polkit; leitor só funciona em USB2; Kit B do inventário]

---
*Checklist: [`docs/CHECKLIST-PRE-TURMA-EQUIPE.md`](https://github.com/VIPs-com/Zero-Trust-Core/blob/main/docs/CHECKLIST-PRE-TURMA-EQUIPE.md) · Gabarito CP2: [`docs/GABARITO-CHECKPOINTS.md`](https://github.com/VIPs-com/Zero-Trust-Core/blob/main/docs/GABARITO-CHECKPOINTS.md)*
```

---

## Bloco 2 — colar no GitHub (Tails)

```markdown
## Evidência — Tails

**Data:** [PREENCHER AAAA-MM-DD]  
**Responsável:** @[PREENCHER]

| Campo | Valor |
| --- | --- |
| **Versão em [tails.net/latest](https://tails.net/latest/)** | [PREENCHER ex.: 7.8] |
| **Versão citada no curso (COMANDO 0.5 / 1.1)** | [PREENCHER ex.: 7.8] |
| **Assinatura OpenPGP da imagem verificada?** | sim / não |
| **Ação no repositório** | nenhuma / atualizar curso para [X.Y] (PR #…) |

**Texto curto:** Tails [X.Y] validado em [DATA] — [sem alteração no curso | curso atualizado para X.Y].

---
*Recorrente: reabrir issue #2 no início de cada turma só para este bloco, se hardware já estiver fechado.*
```

---

## Fechar a issue (comentário final opcional)

Depois dos dois blocos preenchidos:

```markdown
## Fechamento issue #2

- [x] Hardware NFC + `ztc-open-cofre.sh` documentado
- [x] Tails revalidado em [DATA]

**Resumo:** Aprovado para turma Expert com [leitor/modelo] · Tails [X.Y] alinhado ao curso.

Próximo marco: scorecard v1.0.3 em [`docs/AUDITORIA-v1.0.1.md`](https://github.com/VIPs-com/Zero-Trust-Core/blob/main/docs/AUDITORIA-v1.0.1.md#roadmap-v103--scorecard-1010).
```

---

*VIPs-com · maio/2026*
