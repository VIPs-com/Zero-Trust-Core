# 📊 Diagramas visuais — Zero Trust Core Expert

**Síntese para leitura, impressão ou PDF** · Maio/2026

Use este arquivo quando quiser **só os fluxos**, sem os COMANDOs. O conteúdo didático completo continua em [🎓 Zero-Trust-Core-Expert - Versão 1.0.md](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md).

**Como gerar PDF:** abra no GitHub → *Print* do navegador, ou cole cada bloco em [mermaid.live](https://mermaid.live) → *Export* PNG/SVG.

**Montagem do ambiente (software/hardware):** [INVENTARIO-SOFTWARE-HARDWARE.md](./INVENTARIO-SOFTWARE-HARDWARE.md).

* * *

## Legenda de cores (todos os diagramas)

| Cor | Hex (referência) | Significado |
| --- | --- | --- |
| Azul escuro | `#1e3a8a` | Início, planejamento, trilha |
| Verde-água | `#0f766e` | Air-gap — Tails, master, revogação |
| Azul | `#0369a1` | Uso diário — cofres, tokens, SSH |
| Roxo | `#7c3aed` | Backup 3-2-1-1-0, VM, automação |
| Índigo | `#4f46e5` | Scripts, health-check, rsync |
| Âmbar | `#b45309` / `#ca8a04` | Decisão / onboarding |
| Verde | `#15803d` | Checkpoints concluídos |
| Vermelho | `#991b1b` | Contingência, perda, roubo |
| Cinza | `#475569` | Parte 4 — expert e horizonte |

* * *

## A) Fluxograma geral da estratégia

Da decisão de montar o ecossistema até o plano de contingência.

```mermaid
flowchart TD
    A["Inicio - planejamento e trilha"] --> B["Aprendizado e ferramentas"]
    B --> C["Ambiente air-gapped Tails"]
    C --> D["Geracao master e subkeys OpenPGP"]
    D --> E["Tokens: 2A smartcard e 2B NTAG"]
    E --> F["Cofres diarios KeePass e VeraCrypt"]
    F --> G["Backup 3-2-1-1-0"]
    G --> H["Automacao e health-check"]
    H --> I["Uso diario SSH e cofres"]
    I --> J["Monitoramento e restore mensal"]
    J --> K["Contingencia perda ou roubo"]

    subgraph camadas["Camadas de seguranca"]
        F
        E
        I
    end

    subgraph airgap["Air-gap"]
        C
        D
    end

    classDef inicio fill:#1e3a8a,color:#fff,stroke:#1e40af
    classDef airgap fill:#0f766e,color:#fff,stroke:#115e59
    classDef camada fill:#0369a1,color:#fff,stroke:#075985
    classDef resiliencia fill:#7c3aed,color:#fff,stroke:#6d28d9
    classDef alerta fill:#991b1b,color:#fff,stroke:#7f1d1d

    class A,B inicio
    class C,D airgap
    class E,F,I camada
    class G,H resiliencia
    class J camada
    class K alerta
```

* * *

## B) Jornada operacional (10 passos + contingência)

Trilha **Expert**. O ramo inferior é o fluxo de **emergência**, não o caminho feliz.

```mermaid
flowchart TD
    Start([Inicio]) --> Learn["Base OpenPGP-GPG Mod 0-3"]
    Learn --> Tails["1 Tails air-gapped"]
    Tails --> Generate["2 Master e subkeys S E A"]
    Generate --> Revoke["3 Certificado de revogacao"]
    Revoke --> Card["4 keytocard 2A e backup cartao"]
    Card --> Kee["5 KeePass keyfile NTAG 2B e VeraCrypt"]
    Kee --> Auto["6 Health-check e scripts Mod 5"]
    Auto --> Backup["7 Backup 3-2-1-1-0 e VM 4.2"]
    Backup --> Daily["8 Uso diario SSH e cofres"]
    Daily --> Test["9 Restore test mensal"]
    Test --> Monitor["10 Auditoria e atualizacoes Mod 9"]

    Loss["Perda ou roubo do token"] --> RevokeNow["Fase 1 contenção"]
    RevokeNow --> Branch{NTAG ou smartcard?}
    Branch -->|NTAG| NTAG2["Cartao reserva 2 ou 3"]
    Branch -->|smartcard| SCARD["Cartao B ou Tails revogar"]
    NTAG2 --> Restore["Fase 3 restabelecer resiliencia"]
    SCARD --> Restore

    classDef inicio fill:#1e3a8a,color:#fff
    classDef airgap fill:#0f766e,color:#fff
    classDef camada fill:#0369a1,color:#fff
    classDef resiliencia fill:#7c3aed,color:#fff
    classDef alerta fill:#991b1b,color:#fff
    classDef decisao fill:#b45309,color:#fff

    class Start,Learn inicio
    class Tails,Generate,Revoke airgap
    class Card,Kee,Daily camada
    class Auto,Backup,Test,Monitor resiliencia
    class Loss,RevokeNow,Restore alerta
    class Branch decisao
    class NTAG2,SCARD camada
```

* * *

## C) Arquitetura — como as peças se conectam

```mermaid
flowchart TB
    subgraph uso_diario["Uso diario - Parte 2"]
        NTAG["NTAG keyfile - Mod 2B"]
        SCARD["Smartcard OpenPGP - Mod 2A"]
        KC["KeePassXC .kdbx"]
        VC["Volume VeraCrypt"]
        GPG["GnuPG e gpg-agent"]
        SSH["SSH servidores Git"]
        NTAG -->|keyfile| KC
        KC --> VC
        SCARD -->|subkeys no token| GPG
        GPG --> SSH
    end

    subgraph airgap_gen["Geracao air-gap - Parte 1"]
        TAILS["Tails USB offline"]
        MASTER["Chave mestra PGP"]
        REV["Revogacao e backup master"]
        TAILS --> MASTER
        TAILS --> REV
        MASTER -.->|so subkeys| SCARD
    end

    subgraph backup["Backup 3-2-1-1-0 - Parte 3"]
        LOCAL["HD externo frio"]
        OFFSITE["VM via WireGuard"]
        PHYS["NTAG reserva 2 e 3 + smartcard B"]
        IMMUT["Papel metal fingerprints"]
        KC --> LOCAL
        VC --> LOCAL
        KC --> OFFSITE
        GPG --> LOCAL
        REV --> IMMUT
        NTAG --> PHYS
        SCARD --> PHYS
    end

    subgraph automacao["Automacao - Modulo 5"]
        HC["ztc-health"]
        RSYNC["rsync blobs cifrados"]
        HC --> RSYNC
        RSYNC --> OFFSITE
    end

    classDef airgap fill:#0f766e,color:#fff
    classDef camada fill:#0369a1,color:#fff
    classDef resiliencia fill:#7c3aed,color:#fff
    classDef automacao fill:#4f46e5,color:#fff

    class TAILS,MASTER,REV airgap
    class NTAG,SCARD,KC,VC,GPG,SSH camada
    class LOCAL,OFFSITE,PHYS,IMMUT resiliencia
    class HC,RSYNC automacao
```

* * *

## D) Partes do curso × checkpoints

```mermaid
flowchart LR
    subgraph P0["0 Onboarding"]
        T0[Trilhas e mandamentos]
    end
    subgraph P1["1 Primeiros passos"]
        M0[Mod 0 Lab]
        M1[Mod 1 Tails]
        C1[CHECKPOINT 1]
    end
    subgraph P2["2 Hardware"]
        M2A[Mod 2A]
        M2B[Mod 2B]
        M3[Mod 3]
        C2[CHECKPOINT 2]
    end
    subgraph P3["3 Resiliencia"]
        M4[Mod 4]
        M42[Mod 4.2 VM]
        M5[Mod 5]
        M6[Mod 6]
        C3[CHECKPOINT 3]
    end
    subgraph P4["4 Expert"]
        M7[Mod 7]
        M8[Mod 8]
        M9[Mod 9]
    end
    P0 --> P1 --> P2 --> P3 --> P4
    M0 --> M1 --> C1
    M2A --> M3
    M2B --> M3
    M3 --> C2
    M4 --> M42 --> M5 --> M6 --> C3

    classDef onboarding fill:#ca8a04,color:#fff
    classDef parte1 fill:#0f766e,color:#fff
    classDef parte2 fill:#0369a1,color:#fff
    classDef parte3 fill:#7c3aed,color:#fff
    classDef parte4 fill:#475569,color:#fff
    classDef checkpoint fill:#15803d,color:#fff

    class T0 onboarding
    class M0,M1 parte1
    class C1 checkpoint
    class M2A,M2B,M3 parte2
    class C2 checkpoint
    class M4,M42,M5,M6 parte3
    class C3 checkpoint
    class M7,M8,M9 parte4
```

* * *

## E) Parte 3 — módulos interligados

```mermaid
flowchart LR
    M2A[Mod 2A OpenPGP]
    M2B[Mod 2B NTAG]
    M3[Mod 3 cofres]
    M4[Mod 4 backup]
    M42[Mod 4.2 VM]
    M5[Mod 5 scripts]
    M6[Mod 6 runbook]
    M2A --> M4
    M2B --> M4
    M3 --> M4
    M4 --> M42
    M42 --> M5
    M4 --> M6
    M6 -.->|restore test| M42
    M2B -.->|keyfile nunca na VM| M42

    classDef origem fill:#0369a1,color:#fff
    classDef backup fill:#7c3aed,color:#fff
    classDef ops fill:#4f46e5,color:#fff
    classDef critico fill:#991b1b,color:#fff

    class M2A,M2B,M3 origem
    class M4,M42 backup
    class M5 ops
    class M6 critico
```

* * *

## Trilha integrada OpenPGP-GPG ↔ Zero Trust Core

```mermaid
flowchart LR
    subgraph opgp["OpenPGP-GPG do Zero ao Expert"]
        O0[Mod 0-2 GnuPG]
        O3[Mod 3-5 SSH Git]
        O6[Mod 6-8 Tails token]
    end
    subgraph ztc["Zero Trust Core Expert"]
        Z1[Parte 1 Tails]
        Z2[Parte 2 tokens cofres]
        Z3[Parte 3 backup VM]
        Z4[Parte 4 expert]
    end
    O0 --> O3 --> Z1
    O6 --> Z2
    Z1 --> Z2 --> Z3 --> Z4

    classDef opgp fill:#1e3a8a,color:#fff
    classDef ztc fill:#0369a1,color:#fff
    class Z1 airgap
    class Z3 resiliencia

    classDef airgap fill:#0f766e,color:#fff
    classDef resiliencia fill:#7c3aed,color:#fff

    class O0,O3,O6 opgp
    class Z2,Z4 ztc
```

* * *

## Índice rápido → módulo no curso

| Diagrama | Ir para no curso |
| --- | --- |
| A | Visão geral antes da Parte 1 |
| B | Durante Partes 1–3; revisar antes do Módulo 6 |
| C | Antes da Parte 2; revisar antes da Parte 3 |
| D | Sempre que mudar de Parte |
| E | Início da Parte 3 |
| OpenPGP ↔ ZTC | [Manual de uso](./MANUAL-DE-USO.md) §3 |

*Manual visual · [VIPs-com/Zero-Trust-Core](https://github.com/VIPs-com/Zero-Trust-Core)*
