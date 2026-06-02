# Playbook W03 — Bitcoin PSBT Tails ↔ Whonix

**Objetivo:** Operar Bitcoin com a **seed sempre offline** — montar e transmitir transações no Whonix (via Tor), assinar no Tails air-gap.  
**Tempo:** ~25 min  
**Pré-requisitos:**
- [ ] [W01](./W01-instalar-whonix.md) concluído (Whonix operacional)
- [ ] Seed gerada e testada no **Tails air-gap** + **xpub** salva — ver [T0.12 Electrum no guia Tails](../../tails/🐧%20Zero-Trust-Core-Tails.md#t012--electrum-carteira-bitcoin-air-gap-e-online-no-tails)
- [ ] Pendrive para transportar a PSBT entre os mundos

> 🟢 **A mecânica do Electrum (gerar seed, watch-only, exportar/assinar PSBT) já está em
> [T0.12](../../tails/🐧%20Zero-Trust-Core-Tails.md#t012--electrum-carteira-bitcoin-air-gap-e-online-no-tails).**
> Este playbook mostra **só o que muda** quando o lado online é o Whonix em vez do Tails online.

---

## Visão geral do processo

```mermaid
flowchart LR
    subgraph W1["🧅 Whonix (online · Tor)"]
        A["1 — Carteira watch-only<br/>(importar xpub)"] --> B["2 — Montar transação<br/>exportar PSBT não assinada"]
    end
    subgraph T1["🔒 Tails Air-Gap (offline)"]
        C["3 — Abrir carteira<br/>com a seed"] --> D["4 — Assinar a PSBT"]
    end
    subgraph W2["🧅 Whonix (online · Tor)"]
        E["5 — Importar PSBT assinada"] --> F["6 — Broadcast via Tor"]
    end
    B -->|"USB: tx.psbt"| C
    D -->|"USB: tx-assinada.psbt"| E

    style W1 fill:#1e293b,stroke:#a21caf,color:#e2e8f0
    style T1 fill:#0f172a,stroke:#0f766e,color:#e2e8f0
    style W2 fill:#1e293b,stroke:#a21caf,color:#e2e8f0
    style D fill:#0f766e,color:#fff
    style F fill:#a21caf,color:#fff
```

> 🔴 **Regra absoluta:** a **seed nunca toca o Whonix.** Não há "subchave" de seed — a seed *é* a raiz.
> Se ela aparecer em qualquer sistema online, considere os fundos comprometidos.

---

## 1 — Carteira watch-only no Whonix (só a xpub)

Na **Whonix-Workstation**, instale o Electrum (verificando a assinatura — mesmo rigor do W01) e crie
uma carteira **watch-only** importando **apenas a xpub** gerada no Tails:

```
Electrum → File → New → "Use a master key" → colar a xpub → (NÃO há seed aqui)
```

A carteira mostra saldo e endereços, mas **não consegue assinar** — é exatamente o que queremos online.

> Por padrão, o Electrum no Whonix já sai pelo Tor. Confirme em **Tools → Network** que está conectado
> via Tor/proxy do Gateway.

---

## 2 — Montar a transação e exportar a PSBT

```
Electrum → aba Send → preencher destino, valor e taxa → Pay...
→ em vez de transmitir, escolha "Export" / "Save" → salvar como tx.psbt no pendrive
```

A PSBT é uma transação **não assinada**. Copie `tx.psbt` para o pendrive.

---

## 3–4 — Assinar offline no Tails air-gap

Leve o pendrive ao **Tails air-gap (offline, WiFi desligado)** e siga
[T0.12](../../tails/🐧%20Zero-Trust-Core-Tails.md#t012--electrum-carteira-bitcoin-air-gap-e-online-no-tails):

```
Electrum (offline, carteira com a seed) → Tools → Load transaction → from file → tx.psbt
→ Sign → Export / Save → tx-assinada.psbt no pendrive
```

A seed é usada **apenas aqui**, offline. Ao desligar o Tails, ela some da RAM.

---

## 5–6 — Transmitir no Whonix via Tor

De volta à **Whonix-Workstation**:

```
Electrum (watch-only) → Tools → Load transaction → from file → tx-assinada.psbt
→ Broadcast
```

A transação entra na rede Bitcoin **através do Tor**. O mundo vê a transação; **nunca** a sua seed nem o seu IP.

---

## Por que Whonix aqui (e não só Tails online)?

| | Tails online | Whonix |
|---|---|---|
| Broadcast via Tor | ✅ | ✅ |
| **Vazamento de IP** se o Electrum/app falhar | possível | **bloqueado** pelo Gateway |
| Carteira watch-only **persistente** entre sessões | 🟡 só com Persistent (risco) | ✅ natural |

Para quem transmite com frequência e quer a watch-only sempre à mão, o Whonix soma persistência +
anti-vazamento. Para uso esporádico, o Tails online resolve.

---

✅ **Concluído** — transação Bitcoin anônima, com a seed isolada no air-gap o tempo todo.

📖 **Referência no guia:** [Fluxo Bitcoin: seed sempre offline, PSBT no Whonix](../🧅%20Zero-Trust-Core-Whonix.md#fluxo-bitcoin-seed-sempre-offline-psbt-no-whonix)
