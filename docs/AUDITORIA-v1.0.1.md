# Auditoria — Zero Trust Core Expert

**Repositório:** [VIPs-com/Zero-Trust-Core](https://github.com/VIPs-com/Zero-Trust-Core)  
**Arquivo auditado:** `🎓 Zero-Trust-Core-Expert - Versão 1.0.md`  
**Versão do curso (entrada):** 1.0.1 (revisão editorial, maio/2026)  
**Versão do curso (saída):** **1.0.2** (correções pós-auditoria, maio/2026)  
**Data da auditoria original:** maio/2026 · equipe VIPs-com (sob requisição)  
**Data da revisão pós-auditoria:** maio/2026  
**Licença do curso:** [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)

---

## Veredicto geral

| Fase | Veredicto |
| --- | --- |
| **v1.0.1 (auditoria original)** | ✅ Repositório aprovado — entrega viável; gaps gerenciáveis; dois itens obrigatórios antes da primeira turma (backup keyfile + COMANDO 5.3) |
| **v1.0.2 (após correções)** | ✅ **Aprovado para primeira turma** — itens obrigatórios da auditoria incorporados ao curso e aos `scripts/` |

> O material continua honesto sobre limitações (NTAG clonável, iOS, Tails por release). A proposta do aluno — alternativa funcional a duas YubiKeys com hardware de consumo — permanece **entregável** com este repositório.

---

## Scorecard por dimensão

### Auditoria original (v1.0.1)

| Dimensão | Nota | Observação |
| --- | :---: | --- |
| Cobertura técnica | 9/10 | Quase todos os tópicos com COMANDO executável |
| Didática | 8/10 | Checkpoints, legenda de cores, mandamentos |
| Praticabilidade NFC | 7/10 | NTAG vs smartcard bem separado; mount condicional era esboço |
| Segurança operacional | 9/10 | 3-2-1-1-0, runbook, simulação obrigatória |

### Reavaliação (v1.0.2)

| Dimensão | Nota | Δ | Observação |
| --- | :---: | :---: | --- |
| Cobertura técnica | 9/10 | — | + COMANDO 2B.2 (`age`), VeraCrypt CLI validado, script 5.3 |
| Didática | 8/10 | — | Aviso Ramo D antecipado no Módulo 2B |
| Praticabilidade NFC | **8/10** | +1 | `ztc-open-cofre.sh` + COMANDO 5.3 implementável |
| Segurança operacional | **10/10** | +1 | Backup keyfile obrigatório antes dos NTAGs |

---

## Gaps — status após v1.0.2

| Prioridade | Gap (auditoria original) | Status v1.0.2 | Onde foi resolvido |
| :---: | --- | :---: | --- |
| 🔴 Alto | Backup do keyfile NTAG subestimado | ✅ Fechado | [COMANDO 2B.2](https://github.com/VIPs-com/Zero-Trust-Core/blob/main/%F0%9F%8E%93%20Zero-Trust-Core-Expert%20-%20Vers%C3%A3o%201.0.md), matriz de ativos, CHECKPOINT 2 |
| 🟡 Médio | COMANDO 5.3 era esboço | ✅ Fechado | [COMANDO 5.3](https://github.com/VIPs-com/Zero-Trust-Core/blob/main/%F0%9F%8E%93%20Zero-Trust-Core-Expert%20-%20Vers%C3%A3o%201.0.md), [`scripts/ztc-open-cofre.sh`](../scripts/ztc-open-cofre.sh) |
| 🟡 Médio | CLI VeraCrypt não validado | ✅ Fechado | COMANDO 3.1.1 (`veracrypt -t`, Ubuntu 24.04 + 1.26.24) |
| 🟡 Médio | WSL2 sem passo a passo | ✅ Fechado | Apêndice D.1 no curso |
| Pedagogia | Ramo D só no Módulo 6 | ✅ Fechado | Callout no início do Módulo 2B |
| 🔵 Baixo | iOS sem paridade smartcard | ⚪ Documentado | Onboarding §0 + Apêndice D |
| 🔵 Baixo | Versão Tails por release | ⚪ Processo | Checklist mantenedor (abaixo) |

**Alinhamento com a proposta original:** **14 de 14** itens cobertos (integral ou com script opcional documentado).

| Item da proposta | v1.0.1 | v1.0.2 |
| --- | :---: | :---: |
| KeePass + keyfile | ✅ | ✅ |
| VeraCrypt dupla proteção | ✅ | ✅ (+ CLI testado) |
| Cartão NFC token físico | ⚠️ | ✅ (2B + backup `age`) |
| GnuPG master air-gap Tails | ✅ | ✅ |
| Subkeys ed25519/cv25519 | ✅ | ✅ |
| SSH via subchave [A] | ✅ | ✅ |
| Script UID NFC antes de montar | ⚠️ esboço | ✅ `ztc-open-cofre.sh` |
| VM + túnel off-site | ✅ | ✅ |
| Backup 3-2-1 + restore test | ✅ | ✅ |
| Air-gap Tails / celular | ✅ | ✅ |
| Contingência perda cartão | ✅ | ✅ |
| Health-check automatizado | ✅ | ✅ |
| Threat modeling | ✅ | ✅ |
| Horizonte PQC | ✅ | ✅ |

---

## O que mudou no curso (changelog v1.0.2)

1. **COMANDO 2B.2** — backup cifrado do keyfile com `age` (obrigatório **antes** de gravar NTAGs).  
2. **Renumerção 2B** — gravar NTAGs → 2B.3; abrir cofre → 2B.4.  
3. **COMANDO 3.1.1 / 3.1.2** — flags VeraCrypt 1.26.24 com `-t` (não mais “ilustrativo”).  
4. **COMANDO 5.3** — fluxo completo + `scripts/ztc-open-cofre.sh` + variáveis em `ztc.conf.example`.  
5. **Apêndice D.1** — WSL2 + `gpg-agent` passo a passo.  
6. **Onboarding** — expectativa iPhone.  
7. **CHECKPOINT 2** — item de restore do `.age`.  
8. **Runbook Ramo D** — link explícito ao COMANDO 2B.2.

---

## Pontos fortes (mantidos)

1. Distinção **NTAG ≠ smartcard OpenPGP** — corrige o equívoco mais perigoso da proposta original.  
2. **20 Mandamentos** — checklist mental portátil.  
3. **Matriz de ativos** no backup — específica do ecossistema ZTC.  
4. **Runbook em 3 fases** + **COMANDO 6.1** (simulação de mesa obrigatória).  
5. **Break-glass da VM** — off-site não trava com perda do token diário.  
6. **PQC sem alarmismo** — horizonte ⚫, não pânico Q-Day.

---

## Checklist da equipe antes da primeira turma

### Obrigatórias (auditoria original) — concluídas no repositório

- [x] COMANDO dedicado backup keyfile NTAG (`age`, air-gap)  
- [x] COMANDO 5.3 + `ztc-open-cofre.sh`  
- [x] Flags VeraCrypt 1.26.24 documentadas para Ubuntu 24.04  

### Recomendadas (processo + turma)

Rastreamento: [issue #2](https://github.com/VIPs-com/Zero-Trust-Core/issues/2) · procedimento: [`CHECKLIST-PRE-TURMA-EQUIPE.md`](./CHECKLIST-PRE-TURMA-EQUIPE.md).

- [ ] Revalidar [tails.net/latest](https://tails.net/latest) antes de cada turma (versão no curso: Tails 7.8).  
- [ ] Testar `ztc-open-cofre.sh` no **mesmo** hardware dos alunos (leitor NFC + `libnfc`).  
- [ ] Alunos **Windows-only:** revisar Apêndice D.1 na aula 3.2 ou oferecer PC Linux / live USB.  
- [ ] Imprimir runbook (Módulo 6) + guardar com NTAG #2 / smartcard reserva.

### Opcional

- [ ] Slides reforçando: clonabilidade NTAG = modelo de ameaça, não “bug”.  
- [ ] Tag Git `v1.0.2` após merge na `main`.

---

## Análise por dimensão (resumo)

| Dimensão | v1.0.1 | v1.0.2 |
| --- | --- | --- |
| 1. Air-gap + Tails | ✅ | ✅ (revalidar versão por turma) |
| 2. NTAG vs smartcard | ✅ | ✅ (+ aviso 2B no início) |
| 3. KeePassXC + VeraCrypt | ⚠️ CLI ilustrativo | ✅ CLI testado |
| 4. SSH via GPG Agent | ✅ | ✅ (+ D.1 WSL2) |
| 5. Backup 3-2-1-1-0 | ⚠️ keyfile | ✅ COMANDO 2B.2 |
| 6. VM + WireGuard | ✅ | ✅ |
| 7. Automação / health | ⚠️ 5.3 esboço | ✅ script publicado |
| 8. Contingência / runbook | ✅ | ✅ (Ramo D ↔ 2B.2) |
| 9. Threat model + PQC | ✅ | ✅ |

---

## Roadmap v1.0.3 → scorecard 10/10

Meta: atualizar a tabela **Reavaliação (v1.0.2)** após evidência de turma + pacote didático abaixo. **Segurança operacional** já está em 10/10 — manter disciplina (2B.2, 6.1, runbook).

| Dimensão | v1.0.2 | Meta v1.0.3 | Entregável | Responsável |
| --- | :---: | :---: | --- | --- |
| Cobertura técnica | 9/10 | **10/10** | [issue #2](https://github.com/VIPs-com/Zero-Trust-Core/issues/2) fechada + tabela **dispositivos testados** no inventário + checklist Tails no Mód. 1 | Equipe + commit |
| Didática | 8/10 | **10/10** | [`GABARITO-CHECKPOINTS.md`](./GABARITO-CHECKPOINTS.md) + [`FAQ-TROUBLESHOOTING.md`](./FAQ-TROUBLESHOOTING.md) + feedback turma piloto (≥3 itens no FAQ) | Editorial |
| Praticabilidade NFC | 8/10 | **10/10** | Evidência `ztc-open-cofre.sh` no issue #2 + fallback manual destacado no COMANDO 5.3 | Hardware lab |
| Segurança operacional | 10/10 | 10/10 | Sem mudança de nota — revalidar restore 2B.2 por turma | Instrutor |

### Checklist de fechamento v1.0.3

- [x] Gabarito CHECKPOINT 1–3 publicado (instrutor + autoavaliação)  
- [x] FAQ troubleshooting (esqueleto; expandir após piloto)  
- [ ] Fechar [issue #2](https://github.com/VIPs-com/Zero-Trust-Core/issues/2) com log NFC + Tails  
- [ ] Turma piloto: anotar 3 pontos de atrito → patch FAQ ou curso  
- [ ] Atualizar scorecard neste arquivo para **v1.0.3** e tag Git opcional `v1.0.3`  

### Scorecard previsto (v1.0.3 — após itens acima)

| Dimensão | Nota | Observação |
| --- | :---: | --- |
| Cobertura técnica | 10/10 | COMANDOs + evidência hardware + Tails por turma documentado |
| Didática | 10/10 | Gabarito + FAQ + piloto incorporado |
| Praticabilidade NFC | 10/10 | Script validado no kit real dos alunos |
| Segurança operacional | 10/10 | Mantido |

---

## Conclusão

A auditoria original classificou o **Zero Trust Core Expert v1.0.1** como material completo e honesto, com três complementos obrigatórios antes da turma. A **versão 1.0.2** incorpora esses complementos no curso canônico e na pasta `scripts/`, elevando praticabilidade NFC e segurança operacional do keyfile sem refatorar a estrutura pedagógica (checkpoints, mandamentos, simulação).

**Referências**

- Curso: [`🎓 Zero-Trust-Core-Expert - Versão 1.0.md`](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md)  
- Manual: [`docs/MANUAL-DE-USO.md`](./MANUAL-DE-USO.md)  
- Gabarito CHECKPOINTs: [`docs/GABARITO-CHECKPOINTS.md`](./GABARITO-CHECKPOINTS.md)  
- FAQ: [`docs/FAQ-TROUBLESHOOTING.md`](./FAQ-TROUBLESHOOTING.md)  
- Scripts: [`scripts/README.md`](../scripts/README.md)  
- Diagramas: [`docs/DIAGRAMAS-VISUAIS.md`](./DIAGRAMAS-VISUAIS.md)

---

**Sign-off pré-turma (chave mestra do repositório):** [AUDITORIA-TECNICA-PRE-TURMA.md](./AUDITORIA-TECNICA-PRE-TURMA.md)

*Documento de resposta à auditoria VIPs-com · maio/2026*
