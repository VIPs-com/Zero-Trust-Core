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

**Adições pós-v1.0.2 (sem nova tag ainda):**
- **Apêndice G — Módulos H Turbo Híbrido** (commit `2b48034`): H1 QR · H2 metal · H3 Android (a/b/c/d) · H4 iPhone · H5 servidor 5 opções · H6 TOTP+Aegis. Custo extra R$0–50 por módulo. Requer abertura de turma comunicando os módulos disponíveis.
- **[APOSTILA-GUIA-PRATICO.md](./APOSTILA-GUIA-PRATICO.md)** (commit `c41020f`): guia complementar 9 capítulos — ranking Top 20, Frankenstein Key DIY, protocolos avançados, cronograma manutenção, governança home lab, playbook 5 cenários, cockpit Prometheus/Grafana + PowerShell/Rainmeter. Incorpora 61 arquivos de pesquisa.
- **[playbooks/ — diagramas Mermaid](../playbooks/)** (commit `db89547`): `## Visão geral do processo` em cada um dos 10 playbooks com flowchart por módulo + atualização de `playbooks/README.md` e `docs/DIAGRAMAS-VISUAIS.md`.
- **Auditoria de links** (commit `2766a2c`): deep links para COMMANDs em todos os 10 playbooks, FAQ, INICIE-AQUI, DIAGRAMAS, CHECKLIST, GABARITO, INVENTARIO, APOSTILA e MANUAL — 18 arquivos, zero referências soltas.
- **Tabela de dispositivos testados** no [INVENTARIO](./INVENTARIO-SOFTWARE-HARDWARE.md): 14 linhas (SO, Tails, KeePassXC, VeraCrypt, leitores NFC, NTAG, smartcards, Windows, macOS) com status ✅/⏳/🟡 e links diretos para COMMANDs. Itens ⏳ fecham com issue #2.
- **Playbooks reorganizados em 3 blocos** (commit `2888f22`): `1-cofre/`, `2-identidade-pgp/`, `3-backup-resiliencia/` com README por bloco. **2 scripts novos** (`ztc-close-cofre.sh`, `ztc-snapshot-vault.sh`) — total 5. Distro canônica padronizada para **Debian 13 (Trixie)**.
- **Auditoria Red/Blue/Purple Team** (commit `a896e63`): 10 ataques simulados nos scripts reais. 1 crítico (A1: chave SSH sem `command=rrsync` na VM) + 5 médios + 4 cosméticos — **todos corrigidos**. Endurecimentos: `command=rrsync`, `rsync --checksum`, `StrictHostKeyChecking`, `chmod 600` no conf, Reset Code do smartcard. Detalhes em [AUDITORIA-v1.0.1.md](./AUDITORIA-v1.0.1.md). **Scorecard de segurança: 8.7 → 9.2/10.**
- **Playbook 00 — Uso diário** (commit `512d18f`): reincluído após recomendação da auditoria Blue/Purple. Modelo 3 fatores + operação manual + auto-lock KeePassXC + seção keylogger com 7 mitigações. Total: **11 playbooks** em 3 blocos.
- **Seção Keylogger no Módulo 7** (commit `21bcb61`): "Keylogger fora do escopo" eliminado do diagrama de superfície de ataque. Agora seção dedicada no curso com tabela de proteção, 7 mitigações ranqueadas, operação por nível de valor, e conclusão honesta.
- **Auditoria v2 — correções N1–N4** (commit `d926ff9`): guard `fuser -m` no close-cofre (N1), comentário POSIX no snapshot (N2), comentário defensivo no `exec` GUI (N3), nota shred no Playbook 00 (N4), nota ztc.conf no Playbook 08 (gap). Curso alinhado (commit `ba688e6`). **Scorecard: 9.2 → 9.4/10.** Âncoras L4–L7 verificadas.

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
| [APOSTILA-GUIA-PRATICO.md](./APOSTILA-GUIA-PRATICO.md) | Aluno avançado — 9 capítulos + ref. rápida | ✅ |
| [DIAGRAMAS-VISUAIS.md](./DIAGRAMAS-VISUAIS.md) | Fluxos A–E (PDF) | ✅ |
| [SLIDES-ABERTURA-TURMA.md](./SLIDES-ABERTURA-TURMA.md) | 1ª aula (+ `.marp.md`) | ✅ |
| [CHECKLIST-PRE-TURMA-EQUIPE.md](./CHECKLIST-PRE-TURMA-EQUIPE.md) | Instrutor + Módulos H | ✅ |
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
| Link recíproco [OpenPGP-GPG do Zero ao Expert](https://github.com/VIPs-com/OpenPGP-GPG-do-Zero-ao-Expert#trilha-integrada-zero-trust-core-expert) | ✅ |
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
         ↓ (avançado)
    APOSTILA Cap 1–9 (DIY, governança, cockpit) + Cap 10 (ref. rápida por cenário)
    Apêndice G (Módulos H Turbo Híbrido — conforme hardware do aluno)
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
