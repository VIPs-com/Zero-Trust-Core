# Diagramas Whonix — Gateway+Workstation × Laboratório/Escritório × Decisão

> Diagramas de apoio ao [guia Whonix](../🧅%20Zero-Trust-Core-Whonix.md). Visualizam o isolamento de
> rede, o fluxo Tails↔Whonix e como escolher entre os três sistemas.

---

## 1 — Isolamento de rede (Gateway + Workstation)

O coração do Whonix: a Workstation **não tem rota para a internet** — só fala com o Gateway, que só fala Tor.

```mermaid
flowchart TB
    subgraph HOST["🖥️ Host (VirtualBox / KVM / Qubes)"]
        subgraph WS["🧅 Whonix-Workstation"]
            APP["Thunderbird · Electrum<br/>Tor Browser · terminal"]
        end
        subgraph GW["🚪 Whonix-Gateway"]
            TOR["Tor — única saída"]
        end
        APP -->|"rede interna<br/>(sem outra rota)"| TOR
    end
    TOR -->|"circuito Tor"| NET["🌐 Internet"]
    LEAK["❌ conexão direta<br/>(IP real)"] -.->|"impossível:<br/>não existe rota"| APP

    style HOST fill:#0f172a,stroke:#334155,color:#e2e8f0
    style WS fill:#1e293b,stroke:#a21caf,color:#e2e8f0
    style GW fill:#1e293b,stroke:#0f766e,color:#e2e8f0
    style APP fill:#a21caf,color:#fff
    style TOR fill:#0f766e,color:#fff
    style NET fill:#334155,color:#e2e8f0
    style LEAK fill:#7f1d1d,color:#fff
```

> Mesmo um malware que comprometa a Workstation **não acha um IP real para vazar** — é *fail-closed*.

---

## 2 — Laboratório (Tails) ↔ Escritório (Whonix)

A master nasce e mora no Tails air-gap. Só **subkeys** (e PSBTs assinadas) cruzam para o Whonix.

```mermaid
flowchart LR
    subgraph LAB["🔒 Tails Air-Gap — o laboratório"]
        M["master [C]<br/>(raiz, nunca sai)"]
        SUB["gerar subkeys [S][E][A]"]
        SIGN["assinar PSBT Bitcoin"]
    end
    subgraph OFFICE["🧅 Whonix — o escritório anônimo"]
        IMP["importar subkeys"]
        WORK["e-mail PGP · SSH · fóruns<br/>watch-only · broadcast"]
    end
    SUB -->|"USB cifrado (age)"| IMP
    SIGN -->|"USB: PSBT assinada"| WORK
    IMP --> WORK
    M -.->|"fica para trás (offline)"| M

    style LAB fill:#0f172a,stroke:#0f766e,color:#e2e8f0
    style OFFICE fill:#1e293b,stroke:#a21caf,color:#e2e8f0
    style M fill:#0f766e,color:#fff
    style WORK fill:#a21caf,color:#fff
```

---

## 3 — Mapa de decisão: qual sistema usar?

```mermaid
flowchart TD
    Q1{"O que você<br/>precisa fazer?"} -->|"Gerar / renovar chaves<br/>· assinar offline"| M1["🔒 Tails Air-Gap"]
    Q1 -->|"Trabalhar online<br/>com anonimato"| Q2{"Qual seu<br/>hardware?"}
    Q1 -->|"Automação · cofre<br/>VeraCrypt · NFC · backup"| M4["🖥️ Debian diário"]

    Q2 -->|"PC fraco / pendrive<br/>· sessão sem rastro"| M2["🧅 Tails Online<br/>(amnésico, portátil)"]
    Q2 -->|"Máquina capaz + preciso de<br/>identidade persistente"| M3["🧅 Whonix<br/>(anti-vazamento de IP)"]

    style Q1 fill:#334155,color:#e2e8f0
    style Q2 fill:#334155,color:#e2e8f0
    style M1 fill:#0f766e,color:#fff
    style M2 fill:#7c3aed,color:#fff
    style M3 fill:#a21caf,color:#fff
    style M4 fill:#3b82f6,color:#fff
```

---

## 4 — Ciclo Bitcoin (seed nunca online)

```mermaid
sequenceDiagram
    participant W as 🧅 Whonix (online)
    participant USB as 💾 Pendrive
    participant T as 🔒 Tails (offline)

    Note over W: watch-only (só xpub)
    W->>W: montar transação
    W->>USB: exportar tx.psbt (não assinada)
    USB->>T: levar ao air-gap
    Note over T: carteira com a seed
    T->>T: assinar offline
    T->>USB: tx-assinada.psbt
    USB->>W: voltar ao escritório
    W->>W: broadcast via Tor
    Note over W: mundo vê a tx, nunca a seed
```

---

*Zero Trust Core — Guia Whonix · VIPs-com · [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)*
