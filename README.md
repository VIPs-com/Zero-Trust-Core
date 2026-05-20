# Zero Trust Core Expert

Curso open-source em português para montar um ecossistema pessoal de segurança em camadas: **KeePassXC**, **VeraCrypt**, **NFC**, **OpenPGP em air-gap** e **SSH**, com backup **3-2-1-1-0** e operação disciplinada — sem depender de hardware proprietário caro, com controle total e responsabilidade sua.

## Primeira vez aqui?

Leia o **[Manual de uso](docs/MANUAL-DE-USO.md)** — estrutura do repositório, trilha integrada com [OpenPGP-GPG do Zero ao Expert](https://github.com/VIPs-com/OpenPGP-GPG-do-Zero-ao-Expert), o que cada parte do curso permite fazer e roteiro da primeira hora.

**Quer só os fluxogramas coloridos?** → **[docs/DIAGRAMAS-VISUAIS.md](docs/DIAGRAMAS-VISUAIS.md)** (imprimir ou PDF via preview / [mermaid.live](https://mermaid.live)).

## Como estudar

Este repositório segue o mesmo modelo do curso [OpenPGP-GPG do Zero ao Expert](https://github.com/VIPs-com/OpenPGP-GPG-do-Zero-ao-Expert): **um único arquivo Markdown** com todo o material didático.

Abra e estude:

**[🎓 Zero-Trust-Core-Expert - Versão 1.0.md](./🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md)**

Você pode clonar o repositório, baixar o ZIP ou copiar só esse `.md` — não é obrigatório usar Git para aprender.

**Scripts (opcional):** pasta [`scripts/`](./scripts/) — `ztc-health.sh`, `ztc-rsync-offsite.sh` e `ztc.conf.example` (Módulos 4.2 e 5 do curso).

## Para quem é

- Quem já conhece ou está fazendo **[OpenPGP-GPG do Zero ao Expert](https://github.com/VIPs-com/OpenPGP-GPG-do-Zero-ao-Expert)** e quer integrar cofres locais, tokens físicos, backup off-site e automação.
- Entusiastas de privacidade, desenvolvedores e administradores que buscam **soberania digital** com custo baixo e rigor operacional.

## O que você vai construir

Uma “fortaleza artesanal” em cinco camadas: cofre de senhas, fator físico (NTAG ou smartcard OpenPGP), identidade PGP com chave mestra offline, SSH via `gpg-agent` e resiliência com backups testados.

> **Aviso:** tags NFC simples (NTAG) não substituem um smartcard OpenPGP nem uma YubiKey. O curso explica quando usar cada um.

## Metodologia

🔴 Obsoleto · 🟡 Funciona · 🟢 Padrão atual · 🔵 Expert · ⚫ Horizonte  

**COMANDO** a comando, **checkpoints** entre partes, trilhas **Turbo** e **Expert**.

## Status

✅ **Versão 1.0.1+** — Curso completo + pasta [`scripts/`](./scripts/) pública. Tags: `v1.0.1` · link recíproco ativo no [OpenPGP-GPG do Zero ao Expert](https://github.com/VIPs-com/OpenPGP-GPG-do-Zero-ao-Expert).

## Licença

[Creative Commons BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) — veja [LICENSE](./LICENSE).

## Créditos

**VIPs-com** (Projeto Colaborativo)

**Pré-requisito recomendado (trilha Expert):** [OpenPGP-GPG do Zero ao Expert](https://github.com/VIPs-com/OpenPGP-GPG-do-Zero-ao-Expert) — o README desse repositório aponta para este curso e para o [Manual de uso](./docs/MANUAL-DE-USO.md) na secção *Trilha integrada*.
