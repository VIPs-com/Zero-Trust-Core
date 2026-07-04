# 📊 Diagramas visuais — Zero Trust Core Expert

**Síntese para leitura, impressão ou PDF** · Maio/2026

Use este arquivo quando quiser **só os fluxos**, sem os COMANDOs. O conteúdo didático completo continua em [🎓 Zero-Trust-Core-Expert - Versão 1.0.md](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md).

**Como gerar PDF:** abra no GitHub → *Print* do navegador, ou cole cada bloco em [mermaid.live](https://mermaid.live) → *Export* PNG/SVG.

**Montagem do ambiente (software/hardware):** [INVENTARIO-SOFTWARE-HARDWARE.md](./INVENTARIO-SOFTWARE-HARDWARE.md) · **Guia complementar (9 capítulos + ref. rápida):** [APOSTILA-GUIA-PRATICO.md](./APOSTILA-GUIA-PRATICO.md).

> **Diagramas A–E** — fluxo do curso (trilha Expert).  
> **Diagramas F–J** — modelos de setup, Módulos H Turbo Híbrido, playbook de incidentes, cockpit de automação e mapa da apostila. Use-os para **decidir qual caminho montar** antes de começar.  
> **Diagramas K–N** — sequências operacionais e comparação NTAG × Smartcard.  
> **Playbooks 01–10** — cada playbook tem um diagrama **"Visão geral do processo"** embutido no arquivo. Use-os enquanto executa. → [`playbooks/`](../playbooks/)

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
| Laranja | `#c2410c` | Módulos H Turbo Híbrido (Apêndice G) |
| Esmeralda | `#047857` | DIY / Frankenstein Key (Apostila Cap 4) |
| Rosa | `#be185d` | Cockpit / automação avançada (Apostila Cap 9) |

* * *

## A) Roadmap geral — escolha seu caminho

Três trilhas, um destino: sistema de segurança pessoal completo e testado.

```mermaid
flowchart TD
    Start["Voce comeca aqui"] --> Escolha{"Qual trilha?"}

    Escolha --> Turbo["Turbo\n8-12h / R$50-265\nMaioria dos alunos"]
    Escolha --> Expert["Expert\n25-35h / R$725 mais\nMaxima seguranca"]
    Escolha --> Hibrido["Turbo Hibrido\nBase Turbo + modulo H\nAproveite o que ja tem"]

    Turbo --> Parte2["Parte 2\nNTAG + KeePass + VeraCrypt\nModulos 2B e 3.1"]
    Expert --> Parte1["Parte 1\nTails + Chave Mestra offline\nModulo 1"]
    Parte1 --> Parte2A["Parte 2A e 3.2\nSmartcard OpenPGP + SSH"]
    Parte2A --> Parte2
    Hibrido --> HMod["Modulo H escolhido\nAndroid, VM, TOTP\nApendice G"]
    HMod --> Parte2

    Parte2 --> CP2["CHECKPOINT 2\nCofre funcional"]
    CP2 --> Parte3["Parte 3\nBackup 3-2-1-1-0\nScripts + Runbook\nModulos 4-6"]
    Parte3 --> CP3["CHECKPOINT 3\nSistema completo e resiliente"]
    CP3 --> Parte4["Parte 4\nThreat Model + PQC\nManutencao anual"]

    classDef start fill:#1e3a8a,color:#fff
    classDef turbo fill:#10b981,color:#fff
    classDef expert fill:#3b82f6,color:#fff
    classDef hibrido fill:#c2410c,color:#fff
    classDef check fill:#eab308,color:#000,stroke:#854d0e,stroke-width:3px
    classDef neutro fill:#475569,color:#fff
    classDef decisao fill:#b45309,color:#fff

    class Start start
    class Turbo,Parte2 turbo
    class Expert,Parte1,Parte2A expert
    class Hibrido,HMod hibrido
    class CP2,CP3 check
    class Parte3,Parte4 neutro
    class Escolha decisao
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

## F) Modelos de setup — escolha o seu

Antes de começar, escolha o modelo que reflete seu **orçamento e objetivo**. Cada modelo é válido — não existe errado.

```mermaid
flowchart TD
    S{Qual o seu perfil?} 
    S -->|Quero cofre seguro\ncom custo minimo| M1
    S -->|Quero identidade PGP\nair-gap completo| M2
    S -->|Tenho hardware em casa\ne quero aproveitar| M3
    S -->|Quero construir\nO proprio token DIY| M4

    subgraph M1["Modelo 1 — Turbo basico  ~R$50-105"]
        direction LR
        M1A["3x NTAG keyfile"] --> M1B["KeePassXC + VeraCrypt"] --> M1C["HD externo backup"]
    end

    subgraph M2["Modelo 2 — Expert completo  ~R$725+"]
        direction LR
        M2A["Tails air-gap\nmaster PGP"] --> M2B["Smartcard OpenPGP\nsubkeys S E A"]
        M2A --> M2C["3x NTAG keyfile"]
        M2B & M2C --> M2D["KeePassXC + VeraCrypt"]
        M2D --> M2E["VM WireGuard + HD externo"]
        M2E --> M2F["Scripts ztc cron health"]
    end

    subgraph M3["Modelo 3 — Turbo Hibrido  ~R$50-155"]
        direction LR
        M3A["Base Turbo\nModelo 1"] --> M3B["+ Modulo H escolhido\nver Diagrama G"]
    end

    subgraph M4["Modelo 4 — DIY Frankenstein  ~R$39-200"]
        direction LR
        M4A["Kit 1 STM32 + SoloKeys\nFIDO2 R$39-79"]
        M4B["Kit 3 JCOP JavaCard\nOpenPGP DIY R$15-40"]
        M4C["Kit 5 STM32 + SE050\nFIDO2 + OpenPGP R$80-150"]
        M4A & M4B & M4C --> M4D["Combinar com NTAG\ne cofres do Modelo 1"]
    end

    classDef turbo fill:#0369a1,color:#fff
    classDef expert fill:#0f766e,color:#fff
    classDef hibrido fill:#c2410c,color:#fff
    classDef diy fill:#047857,color:#fff
    classDef decisao fill:#b45309,color:#fff

    class M1A,M1B,M1C turbo
    class M2A,M2B,M2C,M2D,M2E,M2F expert
    class M3A,M3B hibrido
    class M4A,M4B,M4C,M4D diy
    class S decisao
```

> Apostila com guia completo de cada modelo: **[APOSTILA-GUIA-PRATICO.md](./APOSTILA-GUIA-PRATICO.md)** · Cap 2 (tokens), Cap 4 (DIY), Cap 6 (manutenção).

* * *

## G) Módulos H Turbo Híbrido — o que tenho → o que faço

Cada H é independente. Ative só os que fazem sentido para o hardware que você **já possui**.

```mermaid
flowchart TD
    T{O que voce ja tem?}

    T -->|Impressora qualquer| H1["H1 — QR Code fingerprint\nsudo apt install qrencode\nImprimir + laminar"]
    T -->|Metal + jogo de punsao| H2["H2 — Placa de metal\nFingerprint gravado\nResiste fogo 900°C"]
    T -->|Android principal + NFC| H3a["H3a — KeePassDX + NTAG\nCofre no celular\nF-Droid gratuito"]
    T -->|Android antigo com Termux| H3b["H3b — Termux sshd\nServidor backup R$0\npkg install openssh"]
    T -->|Celular spare modo aviao| H3c["H3c — Air-gap leve\nOpenKeychain offline\nSem rede permanente"]
    T -->|iPhone| H4["H4 — KeePassium iOS\nCliente cofre\nSem VeraCrypt no iPhone"]
    T -->|PC com 4GB RAM livre| H5a["H5a — VM VirtualBox\nWireGuard local\napt install virtualbox"]
    T -->|TV Box Android| H5c["H5c — UserLAnd Debian\nServidor 24/7\nMenos de 10W R$7 mes"]
    T -->|Raspberry Pi 4 ou 5| H5d["H5d — Pi servidor\nSetup canonico\nDocumentacao ampla"]
    T -->|Mini PC N100 ou J4125| H5e["H5e — Mini PC\nDebian 13 nativo\nSem virtualizacao"]
    T -->|Android + Aegis F-Droid| H6["H6 — TOTP offline\nAegis Authenticator\n2FA sem cloud"]

    classDef h fill:#c2410c,color:#fff
    classDef hserver fill:#7c3aed,color:#fff
    classDef decisao fill:#b45309,color:#fff

    class H1,H2,H3a,H3b,H3c,H4,H6 h
    class H5a,H5c,H5d,H5e hserver
    class T decisao
```

> Conteúdo completo dos módulos H: **[Apêndice G no curso](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#apêndice-g--módulos-h-turbo-híbrido)** · comunicar na abertura de turma: [CHECKLIST-PRE-TURMA-EQUIPE.md §4](./CHECKLIST-PRE-TURMA-EQUIPE.md#4-módulos-h-disponíveis--apêndice-g-opcional).

* * *

## H) Playbook de incidentes — 5 cenários

O que aconteceu → qual cenário → runbook de 3 fases.

```mermaid
flowchart TD
    INC{O que aconteceu?}

    INC -->|Perdi ou danifiquei\num NTAG| I1
    INC -->|Smartcard parou\nou travou PIN| I2
    INC -->|Suspeita de firmware\ncomprometido| I3
    INC -->|Backup inacessivel\nVM ou HD morreu| I4
    INC -->|Roubo ou perda fisica\ndo dispositivo| I5

    subgraph I1["Cenario 1 — Perda de NTAG"]
        I1A["Usar NTAG reserva 2 ou 3\nKeePass ainda abre"] --> I1B["Clonar novo NTAG\ndo backup age\nCOMANDO 2B.2"] --> I1C["Repor no local fisico\nCofre ou off-site"]
    end

    subgraph I2["Cenario 2 — Falha do smartcard"]
        I2A["Cartao B ou Tails air-gap\npara operacoes urgentes"] --> I2B["Novo keytocard\nno cartao substituto"] --> I2C["Revogar cartao antigo\nse PIN permanentemente bloqueado"]
    end

    subgraph I3["Cenario 3 — Firmware comprometido"]
        I3A["Isolar dispositivo\nSo operar no Tails offline"] --> I3B["Reinstalar firmware\nautenticado via assinatura"] --> I3C["Novo keytocard\ne keyfile NTAG"]
    end

    subgraph I4["Cenario 4 — Backup inacessivel"]
        I4A["Acionar copia 2 ou 3\nda matriz 3-2-1-1-0"] --> I4B["Restore test imediato\nsha256sum verificar"] --> I4C["Reconstruir copia\nfaltante em 24h"]
    end

    subgraph I5["Cenario 5 — Perda fisica do dispositivo"]
        I5A["Fase 1 contencao 0-4h\nRevogar subkeys no Tails\nAlt+publicar revogacao"] --> I5B["Fase 2 diagnostico 4-24h\nInventariar o que foi perdido\nNotificar servicos criticos"] --> I5C["Fase 3 restabelecer\nNovo smartcard + NTAG\nRestaurar a partir de backup"]
    end

    F3(["Todos os cenarios\nterminam na Fase 3\nRunbook Modulo 6"])
    I1C & I2C & I3C & I4C & I5C --> F3

    classDef incident fill:#991b1b,color:#fff
    classDef fase fill:#7c3aed,color:#fff
    classDef ok fill:#15803d,color:#fff
    classDef decisao fill:#b45309,color:#fff

    class I1A,I2A,I3A,I4A,I5A incident
    class I1B,I2B,I3B,I4B,I5B fase
    class I1C,I2C,I3C,I4C,I5C fase
    class F3 ok
    class INC decisao
```

> Guia completo de cada cenário com comandos: **[Apostila Cap 8](./APOSTILA-GUIA-PRATICO.md#capítulo-8--lição-8-playbook-de-incidentes)** · Runbook no curso: **Módulo 6**.

* * *

## I) Arquitetura do cockpit de automação

Visão end-to-end: coleta de métricas → alertas → resposta automática → visualização.

```mermaid
flowchart LR
    subgraph col["Coleta — Textfile Collectors"]
        B["backup.sh\nstatus copia"]
        FW["firmware.sh\nversao + assinatura"]
        NT["ntag.sh\nUID presente"]
        SC["smartcard.sh\ngpg card-status"]
    end

    subgraph prom["Prometheus + Node Exporter"]
        PE["Metricas .prom\n/var/lib/node_exporter/"]
        PR["Regras YAML\nalert.rules.yml"]
        B & FW & NT & SC --> PE
        PE --> PR
    end

    subgraph alerta["Alertmanager"]
        AM["Webhook HTTP\nalert_webhook.sh"]
        PR --> AM
    end

    subgraph resposta["Resposta automatica"]
        RB["restore_backup.sh\nSLA 4h backup"]
        RF["reinstall_firmware.sh\nIsolamento firmware"]
        RT["enable_reserve_token.sh\nATivacao token reserva"]
        RA["restart_auth_service.sh\nRecuperacao SSH GPG"]
        AM --> RB & RF & RT & RA
    end

    subgraph viz["Visualizacao"]
        GR["Grafana\nJSON importavel\n4 zonas widescreen"]
        RM["Rainmeter\nWindows cockpit\nupdate_dashboard.ps1"]
        PE --> GR
        PE -.->|Windows| RM
    end

    classDef coleta fill:#0369a1,color:#fff
    classDef metricas fill:#4f46e5,color:#fff
    classDef alerta fill:#b45309,color:#fff
    classDef resposta fill:#991b1b,color:#fff
    classDef viz fill:#be185d,color:#fff

    class B,FW,NT,SC coleta
    class PE,PR metricas
    class AM alerta
    class RB,RF,RT,RA resposta
    class GR,RM viz
```

> Scripts completos (bash + PowerShell), Alertmanager YAML e Grafana JSON importável: **[Apostila Cap 9](./APOSTILA-GUIA-PRATICO.md#capítulo-9--lição-9-automação-do-cockpit)**.

* * *

## J) Mapa da Apostila — onde está cada tema

Use para navegar diretamente ao capítulo certo sem reler tudo.

```mermaid
flowchart TD
    AP["APOSTILA-GUIA-PRATICO.md"]

    subgraph P1["PARTE I — Fundamentos"]
        C1["Cap 1 — Campo de batalha\nOpenPGP vs FIDO2\nPor que este curso"]
        C2["Cap 2 — Escolha suas armas\nRanking Top 20 hardware keys\n4 que suportam OpenPGP\nProjetos chineses"]
        C3["Cap 3 — Construa o cofre\nKeePassXC 2FA\nNTAG como keyfile\nFluxo seguro passo a passo"]
    end

    subgraph P2["PARTE II — Setup avancado"]
        C4["Cap 4 — Frankenstein Key DIY\n5 Kits comparados\nMontagem + firmware\nOnde comprar BR e AliExpress"]
        C5["Cap 5 — Expanda os protocolos\nPKCS11 PIV OATH PQC\nServico a servico\nDIY vs comprar por uso"]
        C6["Cap 6 — Manutencao profissional\nINSIGHT CRITICO\nNTAG rotacao 6-12 meses\nSmartcard nao rota\nCronograma mes a mes"]
    end

    subgraph P3["PARTE III — Governanca Home Lab"]
        C7["Cap 7 — Governe como empresa\nPolitica de Seguranca 8 secoes\nRoles Admin DevOps Auditor Infra\nFluxo processos 6 fases"]
        C8["Cap 8 — Playbook de incidentes\n5 cenarios com comandos\nVer Diagrama H"]
        C9["Cap 9 — Automacao cockpit\nPrometheus Grafana Rainmeter\nScripts resposta automatica\nVer Diagrama I"]
    end

    C10["Cap 10 — Referencia rapida\n45 COMMANDs em 7 cenarios\nDeep links para ancoras do curso\nNavigacao por situacao"]

    AP --> P1 & P2 & P3 & C10
    C1 --> C2 --> C3
    C4 --> C5 --> C6
    C7 --> C8 --> C9

    classDef parte1 fill:#0f766e,color:#fff
    classDef parte2 fill:#0369a1,color:#fff
    classDef parte3 fill:#7c3aed,color:#fff
    classDef ref fill:#15803d,color:#fff
    classDef ap fill:#1e3a8a,color:#fff

    class C1,C2,C3 parte1
    class C4,C5,C6 parte2
    class C7,C8,C9 parte3
    class C10 ref
    class AP ap
```

> Acesse diretamente: **[APOSTILA-GUIA-PRATICO.md](./APOSTILA-GUIA-PRATICO.md)** — use o SUMÁRIO interno para pular ao capítulo.

* * *

## K) Abertura do cofre — fluxo completo (Sequence)

O fluxo mais importante do uso diário: NTAG presente → VeraCrypt monta → KeePassXC abre.

```mermaid
sequenceDiagram
    actor User as Usuário
    participant NFC as NTAG tag
    participant Script as ztc-open-cofre.sh
    participant Age as age decifração
    participant VC as VeraCrypt
    participant KP as KeePassXC

    Note over User,NFC: Fator de Posse — algo que você tem

    User->>NFC: Aproxima a tag NTAG
    activate NFC
    NFC-->>Script: UID confirma presença
    deactivate NFC

    activate Script
    Script->>Age: Decifra keyfile.age
    activate Age
    Age-->>Script: keyfile.bin decifrado
    deactivate Age

    Script->>VC: Monta vault.hc com senha + keyfile
    activate VC
    VC-->>Script: Volume montado com sucesso
    deactivate VC

    Script->>KP: Abre KeePassXC com keyfile
    activate KP
    KP-->>User: Cofre de senhas aberto ✅
    deactivate KP
    deactivate Script

    Note right of KP: Sistema pronto para uso diário
```

> [COMANDO 5.3](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-53-keepass--veracrypt-condicional-nfc-opcional) no curso · script [`ztc-open-cofre.sh`](../scripts/debian/ztc-open-cofre.sh) · [Módulo 3.1](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-31-keepassxc--veracrypt) (VeraCrypt) + [Módulo 2B](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-2b-ntag--keyfile-keepassxc) (NTAG keyfile).

* * *

## L) SSH via gpg-agent — autenticação com hardware (Sequence)

Como a subchave [A] no smartcard autentica o SSH sem expor a chave privada ao sistema.

```mermaid
sequenceDiagram
    actor User as Usuário
    participant SSH as SSH Client
    participant GPG as gpg-agent
    participant Card as Smartcard OpenPGP

    Note over User,Card: Autenticação com Chave Física — subchave A

    User->>SSH: ssh user@servidor.com
    activate SSH
    SSH->>GPG: Solicita assinatura SSH
    activate GPG
    GPG->>Card: Pedido de assinatura subchave A
    activate Card

    rect rgb(254, 249, 195)
        Card->>Card: Usuário digita PIN
    end

    Card-->>GPG: Assinatura gerada no hardware
    deactivate Card
    GPG-->>SSH: Chave autenticada
    deactivate GPG
    SSH-->>User: Conexão estabelecida ✅
    deactivate SSH

    Note right of SSH: Chave privada nunca saiu do smartcard
```

> [COMANDO 3.2.3](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-323-chave-pública-ssh-e-testes) no curso · a master key permanece no Tails — o smartcard carrega apenas as subkeys.

* * *

## M) Contingência — perda ou roubo de token (Sequence)

Runbook de campo: o que fazer nas primeiras horas após perder um token.

```mermaid
sequenceDiagram
    actor User as Usuário
    participant Res as NTAG Reserva 2 ou 3
    participant Age as age decifração
    participant VC as VeraCrypt
    participant Action as Ação pós-acesso

    Note over User,Res: Plano de Contingência — Perda ou Roubo

    User->>Res: Usa token reserva
    activate Res
    Res-->>Age: keyfile.age do backup
    deactivate Res

    activate Age
    Age->>User: Digite senha do age
    User-->>Age: Senha correta
    Age-->>VC: keyfile.bin decifrado
    deactivate Age

    activate VC
    VC->>User: Digite senha mestra VeraCrypt
    User-->>VC: Senha correta
    VC-->>User: Cofre montado ✅
    deactivate VC

    activate Action
    Action->>Action: Revogar token perdido se necessário
    Action->>Action: Repor NTAG reserva com novo clone
    Action->>Action: Registrar no inventário
    deactivate Action

    Note right of Action: Runbook Módulo 6 — Fases 1 a 3
```

> Runbook completo: Módulo 6 do curso · Diagrama H (5 cenários) · [Apostila Cap 8](./APOSTILA-GUIA-PRATICO.md#capítulo-8--lição-8-playbook-de-incidentes).

* * *

## N) NTAG vs Smartcard OpenPGP — não são a mesma coisa

O erro mais comum de iniciantes. Duas tecnologias NFC com papéis completamente diferentes.

```mermaid
flowchart LR
    Q{"Para que\nvai usar?"}

    Q -->|"Keyfile KeePassXC\ncofre de senhas"| NTAG
    Q -->|"Subkeys PGP\nautenticação SSH"| SC

    subgraph NTAG["Tag NTAG 213/215 — Módulo 2B"]
        N1["Memória passiva\nsem processador interno"]
        N2["Qualquer app NFC lê\nsem PIN obrigatório"]
        N3["Clonável: SIM — por design\nCompre 3 idênticos"]
        N4["R$5-15 por tag"]
        N5["Perde 1: use o reserva 2 ou 3"]
    end

    subgraph SC["Smartcard OpenPGP — Módulo 2A"]
        S1["Microprocessador criptográfico\noperações no hardware"]
        S2["PIN obrigatório\nUser PIN e Admin PIN"]
        S3["Clonável: NAO\nproteção por hardware"]
        S4["R$280-750\nNitrokey, YubiKey, JCOP"]
        S5["Perde 1: use o Cartão B\nou revogue e refaça no Tails"]
    end

    WARN(["NAO SAO INTERCAMBIAVEIS\nNTAG não faz keytocard OpenPGP\nSmartcard não substitui keyfile KeePass\nCurso explica quando usar cada um"])

    NTAG --> WARN
    SC --> WARN

    classDef ntag fill:#0369a1,color:#fff
    classDef sc fill:#7c3aed,color:#fff
    classDef warn fill:#991b1b,color:#fff
    classDef decisao fill:#b45309,color:#fff

    class N1,N2,N3,N4,N5 ntag
    class S1,S2,S3,S4,S5 sc
    class WARN warn
    class Q decisao
```

> Conceito crítico explicado no curso: Módulo 2A (smartcard), Módulo 2B (NTAG), [MANUAL-DE-USO.md §5](./MANUAL-DE-USO.md#5-conceito-chave-três-tokens-diferentes).

* * *

## Índice rápido → módulo no curso

| Diagrama | Quando usar | Ir para |
| --- | --- | --- |
| **A** | **Roadmap das 3 trilhas — começo** | Antes de qualquer módulo |
| **B** | Jornada Expert passo a passo + contingência | Partes 1–3; revisar antes do Módulo 6 |
| **C** | Arquitetura de peças conectadas | Antes da Parte 2; revisar antes da Parte 3 |
| **D** | Partes × CHECKPOINTs | Sempre que mudar de Parte |
| **E** | Módulos 4–6 interligados | Início da Parte 3 |
| **F** | Escolher o modelo de setup | Antes de comprar hardware |
| **G** | Módulos H Turbo Híbrido disponíveis | Apêndice G — turma + aluno avançado |
| **H** | Playbook de incidentes 5 cenários | Emergência; ensaio antes do Módulo 6 |
| **I** | Cockpit de automação (arquitetura) | Apostila Cap 9; Módulo 5 avançado |
| **J** | Mapa da Apostila | Ao usar a apostila pela 1ª vez |
| **K** | **Sequence: abertura do cofre** | Módulo 3.1 / 5.3 — fluxo diário |
| **L** | **Sequence: SSH via gpg-agent** | Módulo 3.2 — autenticação hardware |
| **M** | **Sequence: contingência / runbook** | Módulo 6 — perda de token |
| **N** | **NTAG vs Smartcard OpenPGP** | Antes do Módulo 2A ou 2B — erro nº 1 |
| **Playbooks 01–10** | Visão geral de cada procedimento | Dentro de cada arquivo [`playbooks/`](../playbooks/) — use enquanto executa |
| OpenPGP ↔ ZTC | Trilha integrada | [Manual de uso](./MANUAL-DE-USO.md) §3 |
| **Três Mundos (Debian/Tails/Whonix)** | Jornada + quando usar cada sistema | [Manual dos 3 mundos](./GUIA-DO-USUARIO-TRES-MUNDOS.md) · [Diagramas Whonix](../whonix/docs/DIAGRAMA-WHONIX.md) |

*Manual visual · [VIPs-com/Zero-Trust-Core](https://github.com/VIPs-com/Zero-Trust-Core)*
