# Diagrama "Três Mundos" — Tails Air-Gap × Tails Online × Debian

> Diagrama de navegação para o aluno visualizar onde cada operação acontece e como os dados fluem entre os mundos.

---

## Visão geral — Três Mundos

```mermaid
flowchart TD
    subgraph AIRGAP["🔒 Mundo 1 — Tails Air-Gap (offline · WiFi desligado)"]
        A1["Gerar master [C] + subkeys [S][E][A]<br/><i>Playbook 05</i>"]
        A2["Renovar / revogar chaves (anual)<br/><i>COMANDO 9.2</i>"]
        A3["keytocard → smartcard<br/><i>Playbook 06</i>"]
    end

    subgraph TAILS_ON["🧅 Mundo 2 — Tails Online (Persistent + Tor)"]
        B1["Importar subkeys via USB<br/><i>Playbook T02</i>"]
        B2["Assinar / cifrar via Tor<br/><i>COMANDO T.3</i>"]
        B3["KeePassXC no Persistent Storage<br/><i>Playbook T01</i>"]
        B4["Backup manual → USB cifrado<br/><i>Playbook T03</i>"]
        B5["Health check manual<br/><i>Playbook T04</i>"]
    end

    subgraph DEBIAN["🖥️ Mundo 3 — Debian Diário (opcional)"]
        C1["VeraCrypt + KeePassXC + NFC<br/><i>Playbooks 01-04</i>"]
        C2["SSH via gpg-agent<br/><i>Playbook 07</i>"]
        C3["cron + rsync + WireGuard<br/><i>Playbooks 08-09</i>"]
    end

    A1 -->|"USB cifrado (age)<br/>subkeys.gpg.age"| B1
    A1 -->|"USB cifrado (age)<br/>subkeys.gpg.age"| C2
    A3 -->|"Smartcard físico<br/>subkeys no token"| B2
    A3 -->|"Smartcard físico<br/>subkeys no token"| C2
    B4 -->|"USB + MANIFEST.sha256<br/>backup-TIMESTAMP.age"| DEBIAN
    C3 -.->|"USB para renovação<br/>(boot Tails offline)"| AIRGAP

    style AIRGAP fill:#0f172a,stroke:#0f766e,color:#e2e8f0
    style TAILS_ON fill:#1e293b,stroke:#7c3aed,color:#e2e8f0
    style DEBIAN fill:#1e293b,stroke:#3b82f6,color:#e2e8f0
    style A1 fill:#0f766e,color:#fff
    style B3 fill:#7c3aed,color:#fff
    style C1 fill:#3b82f6,color:#fff
```

---

## Fluxo de dados — o que vai em cada USB

```mermaid
flowchart LR
    subgraph USB_SUBKEYS["🔑 USB Subkeys"]
        US1["subkeys.gpg.age"]
        US2["chave-publica.asc"]
        US3["revogacao.asc"]
    end

    subgraph USB_KEYFILE["🗝️ USB Keyfile"]
        UK1["keepass-keyfile.ztc"]
        UK2["keepass-keyfile.ztc.age"]
    end

    subgraph USB_BACKUP["💾 USB Backup"]
        UB1["backup-YYYYMMDD-HHMMSS.age"]
        UB2["MANIFEST.sha256"]
    end

    AIRGAP["🔒 Air-Gap"] -->|"Playbook 05"| USB_SUBKEYS
    TAILS["🧅 Tails Online"] -->|"Playbook T01"| USB_KEYFILE
    TAILS -->|"Playbook T03"| USB_BACKUP

    style USB_SUBKEYS fill:#0f766e,color:#fff
    style USB_KEYFILE fill:#7c3aed,color:#fff
    style USB_BACKUP fill:#f59e0b,color:#000
```

> **Mínimo de pendrives:** 3 (Tails boot + subkeys/keyfile + backup). Idealmente 4 separados para isolamento.

---

## Ciclo de vida — operações por sessão

```mermaid
sequenceDiagram
    participant U as Usuário
    participant T as Tails (Persistent)
    participant USB as USB Backup

    Note over U,T: Início da sessão
    U->>T: Boot + unlock Persistent Storage
    T->>T: ztc-tails-health.sh
    T->>T: Abrir KeePassXC (senha + keyfile)
    T->>T: Usar GPG/SSH/Tor normalmente

    Note over U,USB: Fim da sessão (antes de desligar)
    T->>USB: ztc-tails-backup.sh
    USB->>USB: backup-TIMESTAMP.age + MANIFEST
    T->>T: Fechar KeePassXC
    U->>T: Shutdown (RAM apagada)
```

---

## Mapa de decisão — qual mundo usar?

```mermaid
flowchart TD
    Q1{"O que você<br/>precisa fazer?"} -->|"Gerar / renovar<br/>chaves PGP"| M1["🔒 Mundo 1<br/>Tails Air-Gap"]
    Q1 -->|"Usar GPG/SSH<br/>no dia a dia"| M2["🧅 Mundo 2<br/>Tails Online"]
    Q1 -->|"Automação<br/>backup off-site"| M3["🖥️ Mundo 3<br/>Debian"]
    Q1 -->|"Abrir KeePassXC<br/>consultar senha"| Q2{"Qual sistema<br/>você usa?"}
    Q2 -->|"Tails"| M2
    Q2 -->|"Debian"| M3

    style M1 fill:#0f766e,color:#fff
    style M2 fill:#7c3aed,color:#fff
    style M3 fill:#3b82f6,color:#fff
    style Q1 fill:#334155,color:#e2e8f0
    style Q2 fill:#334155,color:#e2e8f0
```

---

*Zero Trust Core — Guia Tails · VIPs-com · [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)*
