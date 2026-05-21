# 🔐 Fechamento v1.0.2 — auditoria técnica pré-turma

**Zero Trust Core Expert** · **Chave mestra do repositório** *(sign-off editorial + operacional)*  
**Data:** maio/2026 · **Versão avaliada:** 1.0.2 · [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)

> A **chave mestra** OpenPGP fica no Tails e nunca entra no PC diário.  
> Este documento é a **chave mestra do projeto**: confirma que o repositório está **pronto para alunos e instrutores**, com um único pendente de **sala de aula** (hardware NFC).

* * *

## Veredicto

| Classificação | Resultado |
| --- | --- |
| **Material didático (curso + docs)** | ✅ **APROVADO** — entrega estável v1.0.2 |
| **Repositório GitHub** | ✅ **APROVADO** — navegação, scripts, release, licença |
| **Operação pré-1ª turma** | ⏳ **CONDICIONAL** — fechar [issue #2](https://github.com/VIPs-com/Zero-Trust-Core/issues/2) com evidência NFC + Tails |

**Em uma linha:** o Zero Trust Core Expert está **concluído para publicação e ensino**; a “chave de ouro” operacional é o teste físico documentado no issue #2.

* * *

## Escopo desta auditoria

Complementa [`AUDITORIA-v1.0.1.md`](./AUDITORIA-v1.0.1.md) (gaps v1.0.1 → v1.0.2). Avalia o **estado atual do repositório** após:

- Correções pós-auditoria VIPs-com (2B.2 `age`, 5.3, VeraCrypt CLI, Apêndice D.1)
- Pacote `docs/` (manual, inventário, kits R$, diagramas, slides, checklists)
- README (jornada Mermaid, mapa ASCII, badges, trilhas)
- Mapa §1 do curso (3 camadas, índice clicável, trilhas Turbo/Expert)
- Release [v1.0.2](https://github.com/VIPs-com/Zero-Trust-Core/releases/tag/v1.0.2)

* * *

## Checklist técnico — repositório

### Curso canônico

| Item | OK |
| --- | :---: |
| Partes 0–4 + CHECKPOINTs 1–3 | ✅ |
| COMANDO 2B.2 backup keyfile `age` | ✅ |
| COMANDO 5.3 + `scripts/ztc-open-cofre.sh` | ✅ |
| VeraCrypt 1.26.24 CLI (`-t`) documentado | ✅ |
| Apêndices A–F (incl. inventário + WSL2) | ✅ |
| §1 mapa alinhado v1.0.2 + índice clicável | ✅ |
| 14/14 itens da proposta original (auditoria) | ✅ |

### Documentação pública (`docs/`)

| Arquivo | Função | OK |
| --- | --- | :---: |
| [MANUAL-DE-USO.md](./MANUAL-DE-USO.md) | 1ª visita ao repo | ✅ |
| [INVENTARIO-SOFTWARE-HARDWARE.md](./INVENTARIO-SOFTWARE-HARDWARE.md) | SW/HW + kits A–D (R$) | ✅ |
| [DIAGRAMAS-VISUAIS.md](./DIAGRAMAS-VISUAIS.md) | Fluxos A–E (PDF) | ✅ |
| [SLIDES-ABERTURA-TURMA.md](./SLIDES-ABERTURA-TURMA.md) | 1ª aula (+ `.marp.md`) | ✅ |
| [CHECKLIST-PRE-TURMA-EQUIPE.md](./CHECKLIST-PRE-TURMA-EQUIPE.md) | Instrutor | ✅ |
| [AUDITORIA-v1.0.1.md](./AUDITORIA-v1.0.1.md) | Histórico editorial | ✅ |
| **Este arquivo** | Sign-off pré-turma | ✅ |

### Scripts (`scripts/`)

| Script | COMANDO | Revisão estática | OK |
| --- | --- | --- | :---: |
| `ztc-health.sh` | 5.1 | `set -u`, checagens card/ssh/nfc | ✅ |
| `ztc-rsync-offsite.sh` | 4.2.3 | só blobs, conf `ZTC_*` | ✅ |
| `ztc-open-cofre.sh` | 5.3 | fail imediato sem NTAG | ✅ |
| `ztc.conf.example` | — | variáveis 5.3 + off-site | ✅ |

> Validação **dinâmica** do `ztc-open-cofre.sh` (leitor + tag): pendente issue #2 — não invalida o repositório.

### Integração e governança

| Item | OK |
| --- | :---: |
| [README.md](../README.md) — licença CC BY-SA completa, jornada, kits | ✅ |
| Link recíproco [OpenPGP-GPG do Zero ao Expert](https://github.com/VIPs-com/OpenPGP-GPG-do-Zero-ao-Expert#trilha-integrada-zero-trust-core) | ✅ |
| Links profundos ZTC → OpenPGP (âncoras `-ztc`) | ✅ · [LINKS-OPENPGP-GPG.md](./LINKS-OPENPGP-GPG.md) |
| Tag + release `v1.0.2` | ✅ |
| `.gitignore` — sem vazar `_interno/`, segredos | ✅ |
| Issue #2 rastreando pré-turma | ✅ |

* * *

## Scorecard (pré-turma)

| Dimensão | Nota | Nota |
| --- | :---: | --- |
| Completude editorial | 10/10 | Curso + docs + scripts publicados |
| Navegação do aluno | 10/10 | README → Manual → §1 índice → COMANDO |
| Honestidade técnica (NTAG ≠ smartcard) | 10/10 | Mandamentos + slides + inventário |
| Operacionalização | 8/10 | Falta evidência hardware no issue #2 |
| **Média ponderada (publicação)** | **9,5/10** | **Aprovado para turma** após issue #2 ou turma só Turbo/manual |

* * *

## Go / No-go — 1ª turma

| Cenário | Decisão |
| --- | --- |
| Turma **Turbo** (Kit A/B, sem 5.3 obrigatório) | 🟢 **GO** — material suficiente hoje |
| Turma **Expert** com Módulo 5.3 e NFC no PC | 🟡 **GO** após issue #2 **ou** ensinar fluxo manual 3.1.2 |
| Turma **Expert** sem testar Tails na data da aula | 🟡 Revalidar [tails.net/latest](https://tails.net/latest/) no dia (issue #2) |

* * *

## Pendências (não bloqueiam o “concluído” do repo)

1. **Issue #2** — teste `ztc-open-cofre.sh` + versão Tails (evidência em comentário).  
2. **Opcional** — export PDF dos slides Marp anexado à release.  
3. **Opcional** — tag `v1.0.3` só quando baseline Tails/KeePass mudar no curso.

* * *

## Mapa de navegação (chave mestra do aluno)

```
README → MANUAL → Curso §0 → Curso §1 (índice clicável) → COMANDOs → CHECKPOINTs
         ↓
    INVENTARIO (kits R$) · DIAGRAMAS · SLIDES (instrutor)
```

Curso: [🎓 Zero-Trust-Core-Expert - Versão 1.0.md](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md)

* * *

## Assinatura editorial

| Campo | Valor |
| --- | --- |
| **Projeto** | Zero Trust Core Expert · VIPs-com |
| **Versão sign-off** | **v1.0.2** |
| **Status do repositório** | ✅ **Concluído para publicação e ensino** |
| **Próximo marco operacional** | Fechar issue #2 com evidência |
| **Próximo marco editorial** | Só com mudança de baseline ou feedback de turma piloto |

---

*“A master key signs the roadmap; the subkeys do the daily work.”* — princípio Zero Trust Core

🔐 **Chave mestra do repositório: girada.** Boa turma.

* * *

## Disciplina operacional (o que a turma precisa ouvir)

O curso não vende paranoia — vende **rotina que vira reflexo**:

| Hábito | Quando sai do controle, você sabe a volta |
| --- | --- |
| Restore mensal (4.3) | HD/VM não são “caixa preta” |
| Simulação 6.1 (cartão #2) | Perda do NTAG #1 não vira pânico |
| Ensaio 6.2 (revogação lab) | Roubo de smartcard → Tails, não improviso |
| `ztc-health.sh --check-conf` | Scripts falham com mensagem clara, não mistério |
| Runbook impresso no cartão reserva | Fase 1–3 sem depender da memória |

**Frase para a sala:** *a master fica offline; o resto é subkey e disciplina* — se a disciplina existir, a volta é mecânica.

* * *

## Refinamentos pós-sign-off (opcional, já no repositório)

| Item | Onde |
| --- | --- |
| `ztc-health.sh --check-conf` | COMANDO 5.0 |
| Ensaio revogação lab (sem queimar produção) | COMANDO 6.2 |

* * *

*Documento de fechamento · maio/2026 · alinhado a [AUDITORIA-v1.0.1.md](./AUDITORIA-v1.0.1.md)*
