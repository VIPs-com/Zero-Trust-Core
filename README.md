# Zero Trust Core Expert

[![License: CC BY-SA 4.0](https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-sa/4.0/) [![Versão do curso](https://img.shields.io/badge/curso-v1.0.2-blue.svg)](https://github.com/VIPs-com/Zero-Trust-Core/releases/tag/v1.0.2)

Curso open-source em português para montar um ecossistema pessoal de segurança em camadas: **KeePassXC**, **VeraCrypt**, **NFC**, **OpenPGP em air-gap** e **SSH**, com backup **3-2-1-1-0** e operação disciplinada — sem depender de hardware proprietário caro, com controle total e responsabilidade sua.

## Primeira vez aqui?

Leia o **[Manual de uso](docs/MANUAL-DE-USO.md)** — estrutura do repositório, trilha integrada com [OpenPGP-GPG do Zero ao Expert](https://github.com/VIPs-com/OpenPGP-GPG-do-Zero-ao-Expert), o que cada parte do curso permite fazer e roteiro da primeira hora.

**Quer só os fluxogramas coloridos?** → **[docs/DIAGRAMAS-VISUAIS.md](docs/DIAGRAMAS-VISUAIS.md)** (imprimir ou PDF).

**Montar o ambiente (software + hardware)?** → **[docs/INVENTARIO-SOFTWARE-HARDWARE.md](docs/INVENTARIO-SOFTWARE-HARDWARE.md)** (lista por plataforma; **kits em R$**; Apêndice F do curso).

**Instrutor — abertura de turma:** → **[docs/SLIDES-ABERTURA-TURMA.md](docs/SLIDES-ABERTURA-TURMA.md)** (como projetar: VS Code, GitHub, Marp) · **[.marp.md](docs/SLIDES-ABERTURA-TURMA.marp.md)** para slide show.

## Como estudar

Este repositório segue o mesmo modelo do curso [OpenPGP-GPG do Zero ao Expert](https://github.com/VIPs-com/OpenPGP-GPG-do-Zero-ao-Expert): **um único arquivo Markdown** com todo o material didático.

Abra e estude:

**[🎓 Zero-Trust-Core-Expert - Versão 1.0.md](./🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md)**

Você pode clonar o repositório, baixar o ZIP ou copiar só esse `.md` — não é obrigatório usar Git para aprender.

**Scripts:** pasta [`scripts/`](./scripts/) — ver nota **Turbo vs Expert** abaixo.

**Auditoria v1.0.2:** [`docs/AUDITORIA-v1.0.1.md`](./docs/AUDITORIA-v1.0.1.md) · **Equipe (pré-turma):** [`docs/CHECKLIST-PRE-TURMA-EQUIPE.md`](./docs/CHECKLIST-PRE-TURMA-EQUIPE.md) · [issue #2](https://github.com/VIPs-com/Zero-Trust-Core/issues/2)

## Para quem é

- Quem já conhece ou está fazendo **[OpenPGP-GPG do Zero ao Expert](https://github.com/VIPs-com/OpenPGP-GPG-do-Zero-ao-Expert)** e quer integrar cofres locais, tokens físicos, backup off-site e automação.
- Entusiastas de privacidade, desenvolvedores e administradores que buscam **soberania digital** com custo baixo e rigor operacional.

## O que você vai construir

Uma “fortaleza artesanal” em cinco camadas: cofre de senhas, fator físico (NTAG ou smartcard OpenPGP), identidade PGP com chave mestra offline, SSH via `gpg-agent` e resiliência com backups testados.

```
  [ Início · trilha Turbo ou Expert ]
              │
              ▼
  ┌───────────────────────┐
  │ Tails (air-gap)       │  ← master PGP offline
  │ master + subkeys      │
  └───────────┬───────────┘
              ▼
  ┌───────────────────────┐     ┌───────────────────────┐
  │ 2A Smartcard OpenPGP  │     │ 2B NTAG → keyfile     │
  │ PGP + SSH no token    │     │ KeePass (clonável)    │
  └───────────┬───────────┘     └───────────┬───────────┘
              └─────────────┬─────────────┘
                            ▼
              ┌───────────────────────┐
              │ KeePassXC + VeraCrypt │  ← cofre diário
              └───────────┬───────────┘
                            ▼
              ┌───────────────────────┐
              │ Backup 3-2-1-1-0      │  ← VM, HD, restore
              │ + scripts / health    │
              └───────────┬───────────┘
                            ▼
              ┌───────────────────────┐
              │ Uso diário + SSH      │
              └───────────┬───────────┘
                            ▼
              ┌───────────────────────┐
              │ Contingência          │  ← perda do cartão
              └───────────────────────┘
```

**Quer o diagrama completo e colorido (fluxos A–E)?** → **[docs/DIAGRAMAS-VISUAIS.md](docs/DIAGRAMAS-VISUAIS.md)** (imprimir ou PDF).

> **Aviso:** tags NFC simples (NTAG) não substituem um smartcard OpenPGP nem uma YubiKey. O curso explica quando usar cada um.

### Scripts: Turbo vs Expert

| Trilha | Pasta `scripts/` |
| --- | --- |
| **Turbo** | **Opcional** — dá para concluir cofre + NTAG com fluxo manual (COMANDOs 3.1 e 3.1.2). |
| **Expert** | **Parte do aprendizado** — instalar, rodar e **entender** `ztc-health.sh`, `ztc-rsync-offsite.sh` e `ztc-open-cofre.sh` nos Módulos **4.2** e **5** (não é “extra” decorativo). |

Arquivos: [`ztc-health.sh`](./scripts/ztc-health.sh), [`ztc-rsync-offsite.sh`](./scripts/ztc-rsync-offsite.sh), [`ztc-open-cofre.sh`](./scripts/ztc-open-cofre.sh), [`ztc.conf.example`](./scripts/ztc.conf.example) · guia em [`scripts/README.md`](./scripts/README.md).

## Metodologia

🔴 Obsoleto · 🟡 Funciona · 🟢 Padrão atual · 🔵 Expert · ⚫ Horizonte  

**COMANDO** a comando, **checkpoints** entre partes, trilhas **Turbo** e **Expert**.

## Status

✅ **Versão 1.0.2** — Curso completo + correções pós-auditoria (backup keyfile `age`, VeraCrypt CLI, mount NFC). Pasta [`scripts/`](./scripts/) pública. Tags: `v1.0.1`, `v1.0.2` · link recíproco no [OpenPGP-GPG do Zero ao Expert](https://github.com/VIPs-com/OpenPGP-GPG-do-Zero-ao-Expert).

## Licença

Este projeto está licenciado sob **Creative Commons Attribution-ShareAlike 4.0 International** (**CC BY-SA 4.0**).

- Resumo humano: [creativecommons.org/licenses/by-sa/4.0](https://creativecommons.org/licenses/by-sa/4.0/)  
- Texto legal completo: [creativecommons.org/licenses/by-sa/4.0/legalcode](https://creativecommons.org/licenses/by-sa/4.0/legalcode)  
- Cópia no repositório: **[LICENSE](./LICENSE)** (Copyright © 2026 Projeto Colaborativo VIPs-com)

Você pode compartilhar e adaptar o material, inclusive comercialmente, desde que **credite a fonte** e **repasse a mesma licença** nas obras derivadas.

## Créditos

**VIPs-com** (Projeto Colaborativo)

**Pré-requisito recomendado (trilha Expert):** [OpenPGP-GPG do Zero ao Expert](https://github.com/VIPs-com/OpenPGP-GPG-do-Zero-ao-Expert) — o README desse repositório aponta para este curso e para o [Manual de uso](./docs/MANUAL-DE-USO.md) na secção *Trilha integrada*.
