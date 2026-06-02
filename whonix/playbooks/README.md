# 🧅 Playbooks Whonix — Zero Trust Core

**Execução direta. Zero teoria. Copie e cole.**

Playbooks dedicados para quem usa **Whonix** como ambiente *online persistente e anônimo*. Complementam
o air-gap do Tails: o Tails cria e guarda a master; o Whonix usa as subkeys no dia a dia, sempre atrás do Tor.

> **Pré-requisito de hardware:** host com virtualização (VT-x/AMD-V), ~8 GB RAM, dezenas de GB de disco.  
> Em **PC fraco**, prefira o [guia Tails](../../tails/🐧%20Zero-Trust-Core-Tails.md) — entrega mais anonimato por real.

---

## Organização

```
whonix/playbooks/
├── W01-instalar-whonix.md           ← Gateway + Workstation (verificar + isolar)
├── W02-importar-subkeys-tails.md    ← Subkeys do Tails (master fica no air-gap)
└── W03-bitcoin-psbt-tails-whonix.md ← Watch-only no Whonix, assinatura no Tails
```

```mermaid
flowchart LR
    W1["🚪 W01 — Instalar Whonix<br/>Gateway + Workstation"] --> W2["🔑 W02 — Identidade Online<br/>Subkeys via Tor"]
    W2 --> W3["₿ W03 — Bitcoin PSBT<br/>Watch-only + assinatura offline"]
    style W1 fill:#0f766e,color:#fff
    style W2 fill:#a21caf,color:#fff
    style W3 fill:#f59e0b,color:#000
```

---

## Playbooks

| # | Playbook | O que você terá | Tempo |
|---|----------|-----------------|------:|
| [W01](./W01-instalar-whonix.md) | Instalar Whonix | Gateway + Workstation verificados, Tor forçado, sem vazamento de IP | ~40 min |
| [W02](./W02-importar-subkeys-tails.md) | Importar subkeys do Tails | `sec#` + 3 `ssb` no Whonix; master nunca saiu do air-gap | ~20 min |
| [W03](./W03-bitcoin-psbt-tails-whonix.md) | Bitcoin PSBT Tails↔Whonix | Transação transmitida via Tor sem a seed tocar a rede | ~25 min |

---

## Ordem recomendada

```
Guia Whonix (conceitos) → W01 (instalar) → W02 (identidade) → W03 (Bitcoin, opcional)
```

> **Primeiro:** leia o [guia principal Whonix](../🧅%20Zero-Trust-Core-Whonix.md) — modelo
> Gateway+Workstation, persistência × amnésia, e por que **não** empilhar VPN no Tor.
>
> Depois de W01–W02, valide com o [CHECKPOINT W](../🧅%20Zero-Trust-Core-Whonix.md#checkpoint-w--validação-final).

---

## Correspondência com playbooks Tails

| Whonix | Equivale a (Tails) | Diferença principal |
|--------|---------------------|-------------------|
| W01 | T0 (boot/verificação) + T01 | Instala 2 VMs em vez de gravar 1 pendrive; persistente |
| W02 | [T02](../../tails/playbooks/T02-tails-online-identity.md) | Procedimento **idêntico** no que importa; muda o ambiente de destino |
| W03 | [T0.12 Electrum](../../tails/🐧%20Zero-Trust-Core-Tails.md#t012--electrum-carteira-bitcoin-air-gap-e-online-no-tails) | O "lado online" é o Whonix; a assinatura continua no Tails air-gap |

---

*Zero Trust Core — Guia Whonix · VIPs-com · [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)*
