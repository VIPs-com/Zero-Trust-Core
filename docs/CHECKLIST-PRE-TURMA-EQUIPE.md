# Checklist pré-turma — guia da equipe

**Público:** mantenedores e instrutores VIPs-com · **Versão do curso:** 1.0.2  
**Rastreamento no GitHub:** [Issue #2 — Checklist pré-turma](https://github.com/VIPs-com/Zero-Trust-Core/issues/2)  
**Licença:** [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)

Este documento descreve validações que **não** se resolvem só com commit: hardware NFC real e versão atual do Tails. O issue #2 é o registro público; **feche o issue com evidência** nos comentários (não apenas “funcionou”).

---

## Visão geral

| Quando | O quê | Onde registrar |
| --- | --- | --- |
| **Uma vez** (antes da 1ª turma com Módulo 5) | Teste físico de `ztc-open-cofre.sh` | Comentário no [issue #2](https://github.com/VIPs-com/Zero-Trust-Core/issues/2) |
| **Cada turma** | Revalidar Tails em [tails.net/latest](https://tails.net/latest/) | Comentário no mesmo issue; **reabrir** o issue só para este item se já estiver fechado |
| Referência editorial | Gaps v1.0.1 → v1.0.2 | [`AUDITORIA-v1.0.1.md`](./AUDITORIA-v1.0.1.md) |

---

## 1. Teste de hardware — `ztc-open-cofre.sh`

### Pré-requisitos no PC de teste

Use o **mesmo perfil de hardware** que os alunos terão (ou documente divergências).

- Ubuntu 24.04 (ou distro alvo da turma) com VeraCrypt 1.26.24 e KeePassXC instalados
- Leitor NFC USB (ex.: ACR122U) reconhecido pelo sistema
- `libnfc` + ferramentas CLI (`nfc-list`)
- Volume VeraCrypt de **lab** (`vault.hc`), `.kdbx` e keyfile no disco conforme o curso (Módulos 2B e 3.1)
- Script instalado:

```sh
mkdir -p ~/bin ~/ztc-backup
cp scripts/ztc-open-cofre.sh ~/bin/
chmod +x ~/bin/ztc-open-cofre.sh
cp scripts/ztc.conf.example ~/ztc-backup/ztc.conf
# Editar ~/ztc-backup/ztc.conf — caminhos reais + ZTC_NFC_UID
```

### Obter o UID da tag (antes de configurar)

Com a tag NTAG no leitor:

```sh
nfc-list
# Anote o UID (ex.: 04:ab:cd:ef:12:34:56) — use no ZTC_NFC_UID sem espaços extras
```

Em `~/ztc-backup/ztc.conf`:

```sh
ZTC_NFC_UID="04:ab:cd:ef:12:34:56"   # exemplo — use o seu UID
ZTC_VAULT_HC="/caminho/seguro/vault.hc"
ZTC_MOUNT_POINT="/media/veracrypt-ztc"
ZTC_KDBX="/media/veracrypt-ztc/lab-passwords.kdbx"
ZTC_KEYFILE="$HOME/keepass-keyfile.ztc"
```

### Coletar evidência (obrigatório)

Salve a saída completa dos comandos abaixo em um arquivo local ou cole direto no comentário do issue.

```sh
# Metadados do ambiente
date -Is
uname -a
veracrypt --version 2>/dev/null | head -1
keepassxc --version 2>/dev/null | head -1
libnfc-utils --version 2>/dev/null || nfc-list --version 2>/dev/null || dpkg -l libnfc* 2>/dev/null | head -5
lsusb | grep -iE 'nfc|acr|122' || lsusb

# Leitor + tag presente
echo "=== COM TAG ==="
time nfc-list
time ~/bin/ztc-open-cofre.sh
# (informe senha do VeraCrypt quando pedido; confirme que KeePassXC abriu)
veracrypt -t -d /media/veracrypt-ztc 2>/dev/null || true

# Sem tag (retire a tag do leitor antes)
echo "=== SEM TAG ==="
time ~/bin/ztc-open-cofre.sh; echo "exit=$?"
```

**Comportamento esperado do script (referência v1.0.2):**

| Situação | Saída esperada |
| --- | --- |
| Tag presente + `ZTC_NFC_UID` correto | `[OK] NTAG presente` → prompt VeraCrypt → `[OK] Abrindo KeePassXC...` |
| Tag ausente + `ZTC_NFC_UID` definido | `[FAIL] NTAG ausente (UID esperado: …)` e **exit ≠ 0** (falha imediata; não há timeout longo no script) |
| `nfc-list` ausente | `[FAIL] nfc-list ausente; instale libnfc ou remova ZTC_NFC_UID do conf` |
| `ZTC_NFC_UID` vazio no conf | Script **não** exige NFC; só monta VeraCrypt e abre KeePass |

> 💡 Para turma sem leitor NFC no PC: deixe `ZTC_NFC_UID=""` e documente fluxo manual (COMANDO 3.1.2).

### Dados mínimos para o comentário no issue #2

Copie e preencha o [modelo de comentário](#modelo-de-comentário-issue-2) abaixo.

| Campo | Exemplo |
| --- | --- |
| Data do teste | 2026-05-20 |
| Leitor NFC | ACS ACR122U (lsusb: …) |
| Versão libnfc | saída de `libnfc-utils --version` ou pacote |
| UID em `ZTC_NFC_UID` | `04:ab:cd:…` (mascarar últimos bytes se publicar em issue público) |
| Com tag — tempo `nfc-list` | ex.: 0,3s |
| Com tag — script | OK / FAIL + trecho da saída |
| Sem tag — script | mensagem `[FAIL] NTAG ausente` + `exit=1` |
| KeePass abriu? | sim / não |
| Observações | ex.: precisa `sudo` para VeraCrypt; polkit |

---

## 2. Revalidação do Tails (cada turma)

1. Abra [https://tails.net/latest/](https://tails.net/latest/) no dia da preparação da turma.  
2. Compare com a versão citada no curso (**COMANDO 0.5** e **COMANDO 1.1** — baseline editorial, ex. Tails 7.8).  
3. Se a estável mudou:
   - Atualize as referências no arquivo `🎓 Zero-Trust-Core-Expert - Versão 1.0.md`
   - Commit + nota na release ou changelog interno
   - Comente no issue #2: versão antiga → nova + data da conferência
4. Se **não** mudou: comente apenas `Tails X.Y validado em AAAA-MM-DD — sem alteração no curso`.

**Processo no GitHub:** quando o issue #2 estiver **fechado** após o teste de hardware, **reabra** o issue no início de cada nova turma, adicione o comentário do Tails e feche de novo (ou deixe aberto só com checklist Tails marcado — política da equipe: preferir reabrir para visibilidade).

---

## 3. Quando fechar o issue #2

| Critério | Evidência |
| --- | --- |
| Teste NFC + `ztc-open-cofre.sh` | Comentário com modelo §1 preenchido + saídas coladas ou anexo |
| Tails validado | Comentário com versão e data |
| Ambos OK | Fechar issue com resumo de uma linha |

**Não fechar** com “testamos e funcionou” sem UID, versões e saída sem tag.

---

## Modelo de comentário (issue #2)

Cole no [issue #2](https://github.com/VIPs-com/Zero-Trust-Core/issues/2) (pode dividir em dois comentários: hardware + Tails).

```markdown
## Evidência — teste `ztc-open-cofre.sh`

**Data:** AAAA-MM-DD  
**Responsável:** @usuario  
**Host:** Ubuntu 24.04 / kernel …

### Ambiente
- Leitor NFC: …
- libnfc: … (`libnfc-utils --version` ou pacote)
- VeraCrypt: …
- KeePassXC: …

### Configuração
- `ZTC_NFC_UID`: `04:xx:…` (parcial se público)
- `ZTC_VAULT_HC`: … (caminho genérico, sem senha)

### Com tag presente
- `nfc-list`: (colar saída resumida)
- `time ztc-open-cofre.sh`: …
- KeePassXC abriu: sim/não

### Sem tag
- Saída: `[FAIL] NTAG ausente …`
- `exit`: 1

### Conclusão
- [ ] Aprovado para turma com leitor NFC + libnfc
- [ ] Aprovado só com `ZTC_NFC_UID` vazio (fluxo manual)

---

## Evidência — Tails

**Data:** AAAA-MM-DD  
**Versão em tails.net/latest:** X.Y  
**Versão no curso (COMANDO 0.5 / 1.1):** X.Y  
**Ação:** nenhuma / atualizar curso para X.Y (PR #…)
```

---

## 4. Outros itens recomendados (não bloqueiam o issue)

- Alunos **só Windows:** revisar [Apêndice D.1](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md) na aula de SSH  
- Imprimir runbook (Módulo 6) + guardar com NTAG #2 / smartcard reserva  
- Slides: NTAG clonável = modelo de ameaça, não defeito do curso  

Ver também checklist em [`AUDITORIA-v1.0.1.md`](./AUDITORIA-v1.0.1.md).

---

## Links rápidos

| Recurso | URL |
| --- | --- |
| Issue #2 | https://github.com/VIPs-com/Zero-Trust-Core/issues/2 |
| Release v1.0.2 | https://github.com/VIPs-com/Zero-Trust-Core/releases/tag/v1.0.2 |
| Script | [`scripts/ztc-open-cofre.sh`](../scripts/ztc-open-cofre.sh) |
| COMANDO 5.3 | [curso — Módulo 5](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md) |

---

*Guia da equipe VIPs-com · maio/2026 · alinhado à v1.0.2*
