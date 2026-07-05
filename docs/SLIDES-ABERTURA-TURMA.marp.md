---
marp: true
theme: default
paginate: true
title: Zero Trust Core Expert — Abertura de turma
description: 4 slides · VIPs-com · v1.0.3
style: |
  section { font-size: 28px; }
  table { font-size: 22px; }
  h1 { color: #1e3a8a; }
  h2 { color: #0f766e; }
---

# Zero Trust Core Expert
## Abertura de turma · 4 slides

VIPs-com · v1.0.3 · [Repositório](https://github.com/VIPs-com/Zero-Trust-Core/releases/tag/v1.0.3)

---

## Slide 1 — O problema

### Duas YubiKeys não são o único caminho

| Abordagem | Custo (BR) | O que você leva |
| --- | --- | --- |
| **2× YubiKey** | **~R$ 800 – 1.200** | Hardware fechado |
| **Zero Trust Core** | **~R$ 50 – 265** (Turbo) | Defesa em profundidade **+ você entende cada camada** |

**Mensagem:** comece hoje com tags NFC + software **R$ 0** (open-source).

---

## Slide 2 — Os 4 kits

| Kit | Trilha | Investimento |
| --- | --- | --- |
| **A** | Turbo mínimo | **~R$ 50 – 105** |
| **B** | Turbo + NFC no PC | **~R$ 130 – 265** |
| **C** | Expert (PGP + HD) | **~R$ 725 – 1.770** |
| **D** | Expert + VM | **~R$ 770 – 2.150** + VPS/mês |

`A → B → C → D` · Detalhes: [Inventário § Kits](https://github.com/VIPs-com/Zero-Trust-Core/blob/main/docs/INVENTARIO-SOFTWARE-HARDWARE.md#-kit-mínimo-de-compra-brasil--referência-2026)

---

## Slide 3 — As 5 camadas

1. **Cofre** — KeePassXC + VeraCrypt  
2. **Token físico** — NTAG (keyfile) ou smartcard (subkeys)  
3. **Identidade** — Master no Tails + subkeys [S][E][A]  
4. **SSH** — `gpg-agent` (subchave [A])  
5. **Backup** — 3-2-1-1-0 + runbook de contingência  

**Turbo:** camadas 1–2 · **Expert:** todas

---

## Slide 4 — Regra de ouro

| | **NTAG** | **Smartcard OpenPGP** |
| --- | --- | --- |
| **Serve para** | Keyfile KeePass | PGP + **SSH** |
| **`keytocard`?** | Não | Sim |
| **Módulo** | **2B** | **2A** |

**ERRADO:** só NTAG e esperar SSH/OpenPGP no token  
**CERTO:** NTAG = cofre · Smartcard = identidade

→ Próximo: **Módulo 0** no curso

---

## Links

- Curso: [Zero-Trust-Core-Expert](https://github.com/VIPs-com/Zero-Trust-Core/blob/main/%F0%9F%8E%93%20Zero-Trust-Core-Expert%20-%20Vers%C3%A3o%201.0.md)
- Manual: [MANUAL-DE-USO.md](https://github.com/VIPs-com/Zero-Trust-Core/blob/main/docs/MANUAL-DE-USO.md)
- Versão com notas do instrutor: [SLIDES-ABERTURA-TURMA.md](./SLIDES-ABERTURA-TURMA.md)
