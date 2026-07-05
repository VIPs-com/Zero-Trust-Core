# Zero Trust Core Expert

[![Versão](https://img.shields.io/github/v/tag/VIPs-com/Zero-Trust-Core?label=vers%C3%A3o&color=brightgreen)](https://github.com/VIPs-com/Zero-Trust-Core/releases/latest)
[![Licença: CC BY-SA 4.0](https://img.shields.io/badge/licen%C3%A7a-CC%20BY--SA%204.0-lightgrey)](https://creativecommons.org/licenses/by-sa/4.0/)
[![Último commit](https://img.shields.io/github/last-commit/VIPs-com/Zero-Trust-Core)](https://github.com/VIPs-com/Zero-Trust-Core/commits/main)
[![Issues abertos](https://img.shields.io/github/issues/VIPs-com/Zero-Trust-Core)](https://github.com/VIPs-com/Zero-Trust-Core/issues)

Curso open-source em português para montar um ecossistema pessoal de segurança em camadas: **KeePassXC**, **VeraCrypt**, **NFC**, **OpenPGP em air-gap** e **SSH**, com backup **3-2-1-1-0** e operação disciplinada — sem depender de hardware proprietário caro, com controle total e responsabilidade sua.

## Jornada do curso

```mermaid
flowchart LR
    A["📌 Onboarding\nTrilha + kits"] --> B["🔴 Parte 1\nAir-gap · Tails\nChave mestra offline"]
    B --> C["🟡 Parte 2\nNTAG · Smartcard\nKeePass · SSH"]
    C --> D["🔵 Parte 3\nBackup 3-2-1-1-0\nVM · Automação"]
    D --> E["⚫ Parte 4\nThreat model\nPQC · Manutenção"]

    style A fill:#F1EFE8,stroke:#888780,color:#444441
    style B fill:#FCEBEB,stroke:#A32D2D,color:#791F1F
    style C fill:#FAEEDA,stroke:#854F0B,color:#633806
    style D fill:#E6F1FB,stroke:#185FA5,color:#0C447C
    style E fill:#2C2C2A,stroke:#444441,color:#D3D1C7
```

> Diagrama completo (fluxos A–E), cores e PDF: **[docs/DIAGRAMAS-VISUAIS.md](docs/DIAGRAMAS-VISUAIS.md)**

## Primeira vez aqui?

Leia o **[INICIE AQUI](docs/INICIE-AQUI.md)** — 8 minutos, mapa visual das trilhas, o que comprar e como começar sem se sobrecarregar.

Depois, o **[Manual de uso](docs/MANUAL-DE-USO.md)** — estrutura do repositório, trilha integrada com [OpenPGP-GPG do Zero ao Expert](https://github.com/VIPs-com/OpenPGP-GPG-do-Zero-ao-Expert#trilha-integrada-zero-trust-core-expert), o que cada parte do curso permite fazer e roteiro da primeira hora.

**Montar o ambiente (software + hardware + kits em R$)?** → **[docs/INVENTARIO-SOFTWARE-HARDWARE.md](docs/INVENTARIO-SOFTWARE-HARDWARE.md)**

**Quero executar agora (zero teoria, copiar e colar)?** → **[playbooks/](playbooks/)** — 11 guias código-primeiro em 3 blocos: **[1-cofre](playbooks/1-cofre/)** (KeePass+VeraCrypt+NFC), **[2-identidade-pgp](playbooks/2-identidade-pgp/)** (Tails+Smartcard+SSH), **[3-backup-resiliencia](playbooks/3-backup-resiliencia/)** (HD+off-site+restore).

**Usa Tails como sistema diário?** → **[tails/](tails/🐧%20Zero-Trust-Core-Tails.md)** — guia dedicado com cofre LUKS, backup manual em USB cifrado, health check por sessão e diagrama "Três Mundos" (air-gap × online × Debian).

**Quer um ambiente online persistente e anônimo (avançado)?** → **[whonix/](whonix/🧅%20Zero-Trust-Core-Whonix.md)** — guia dedicado: o "escritório anônimo" (Gateway+Workstation, todo o tráfego via Tor, anti-vazamento de IP) que complementa o air-gap do Tails. **Capstone da Parte 4.**

**Perdido entre Debian, Tails e Whonix? Quer personalizar (OpSec)?** → **[docs/GUIA-DO-USUARIO-TRES-MUNDOS.md](docs/GUIA-DO-USUARIO-TRES-MUNDOS.md)** — a jornada em ordem (quando ligar cada mundo), como criar a mídia air-gap separada, e como mudar os padrões do curso (tamanho de keyfile, nomes) para o seu setup não ser idêntico.

**Backup off-site sem gastar à toa (VPS/energia)? Kit de mídias?** → **[docs/BACKUP-OFFSITE-E-KIT-SOBREVIVENCIA.md](docs/BACKUP-OFFSITE-E-KIT-SOBREVIVENCIA.md)** — onde hospedar (HD frio / Raspberry Pi / VPS com custo e energia comparados), `borg` append-only passo a passo, backup do Whonix (bare-metal × VM) e o Kit de Sobrevivência Digital.

**Ir além do curso (hardware alternativo, DIY, governança, automação)?** → **[docs/APOSTILA-GUIA-PRATICO.md](docs/APOSTILA-GUIA-PRATICO.md)** — guia prático em 9 capítulos + referência rápida por cenário (Capítulo 10)

**Instrutor — abertura de turma:** → **[docs/SLIDES-ABERTURA-TURMA.md](docs/SLIDES-ABERTURA-TURMA.md)** (VS Code, GitHub, Marp) · **[.marp.md](docs/SLIDES-ABERTURA-TURMA.marp.md)**

## Como estudar

Este repositório segue o mesmo modelo do curso [OpenPGP-GPG do Zero ao Expert](https://github.com/VIPs-com/OpenPGP-GPG-do-Zero-ao-Expert#trilha-integrada-zero-trust-core-expert): **um único arquivo Markdown** com todo o material didático.

Abra e estude:

**[🎓 Zero-Trust-Core-Expert - Versão 1.0.md](./🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md)** — no curso, use o **[índice clicável (§1)](./🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-índice-clicável-use-no-github--vs-code-preview)** para pular aos módulos.

Você pode clonar o repositório, baixar o ZIP ou copiar só esse `.md` — não é obrigatório usar Git para aprender.

**Testes de campo (instrutor):** [issue #2](https://github.com/VIPs-com/Zero-Trust-Core/issues/2)

## Para quem é

- Quem já conhece ou está fazendo **[OpenPGP-GPG do Zero ao Expert](https://github.com/VIPs-com/OpenPGP-GPG-do-Zero-ao-Expert/blob/main/%F0%9F%8E%93%20OpenPGP-GPG%20do%20Zero%20ao%20Expert%20-%20Vers%C3%A3o%201.0.md#modulo-0-ztc)** e quer integrar cofres locais, tokens físicos, backup off-site e automação.
- Quem concluiu ou está no **[Privacy-OS-Hub](https://github.com/VIPs-com/Privacy-OS-Hub)** (Tails + Haveno + Whonix) e quer **endurecer** cofres, backup off-site e identidade além da trilha Monero.
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

> **Aviso:** tags NFC simples (NTAG) não substituem um smartcard OpenPGP nem uma YubiKey. O curso explica quando usar cada um.

### Scripts: Turbo vs Expert

| Trilha | Pasta [`scripts/`](./scripts/) |
| --- | --- |
| **Turbo** (~R$ 50–265 · 8–12 h) | **Opcional** — cofre + NTAG com fluxo manual (COMANDOs 3.1.1 e 3.1.2). |
| **Expert** (~R$ 725–2.150 · 25–35 h) | **Parte do aprendizado** — instalar, rodar e **entender** `ztc-health.sh`, `ztc-rsync-offsite.sh` e `ztc-open-cofre.sh` nos Módulos **4.2** e **5**. |

Arquivos: [`ztc-health.sh`](./scripts/debian/ztc-health.sh), [`ztc-rsync-offsite.sh`](./scripts/debian/ztc-rsync-offsite.sh), [`ztc-open-cofre.sh`](./scripts/debian/ztc-open-cofre.sh), [`ztc.conf.example`](./scripts/debian/ztc.conf.example) · [`scripts/README.md`](./scripts/README.md)

## Metodologia

🔴 Obsoleto · 🟡 Funciona · 🟢 Padrão atual · 🔵 Expert · ⚫ Horizonte

**COMANDO** a comando, **checkpoints** entre partes, trilhas **Turbo** (2–3 semanas · ~8–12 h · kits ~R$ 50–265) e **Expert** (6–8 semanas · ~25–35 h · kits ~R$ 725–2.150).

## Status

✅ **Versão 1.0.3** — trilha Whonix autocontida (W00–W03 · `ztc-whonix-verify-image.sh`) · release [`v1.0.3`](https://github.com/VIPs-com/Zero-Trust-Core/releases/tag/v1.0.3). Baseline anterior: v1.0.2 (scorecard 9.2/10).

**Conteúdo da v1.0.3 (release [`v1.0.3`](https://github.com/VIPs-com/Zero-Trust-Core/releases/tag/v1.0.3)):**
- **Capstone Whonix + tooling de backup completo:** guia dedicado [`whonix/`](whonix/🧅%20Zero-Trust-Core-Whonix.md) (escritório anônimo via Tor · playbooks **W00–W03**), [manual dos 3 mundos](docs/GUIA-DO-USUARIO-TRES-MUNDOS.md) e [backup/off-site + kit de sobrevivência](docs/BACKUP-OFFSITE-E-KIT-SOBREVIVENCIA.md). Scripts Whonix: `ztc-whonix-install-virtualbox.sh`, `ztc-whonix-verify-image.sh`, `ztc-whonix-import-ova.sh`, `ztc-whonix-health.sh`. Outros scripts: `ztc-restore-test.sh` (a "0 erros" do 3-2-1-1-0 no Debian), `ztc-borg-offsite.sh` (off-site **imutável** append-only). Auditoria Red/Blue/Purple aplicada aos novos artefatos.
- **[Apêndice G](./🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#apêndice-g--módulos-h-turbo-híbrido)** — Módulos H Turbo Híbrido (H1 QR · H2 metal · H3 Android · H4 iPhone · H5 servidor · H6 TOTP). Ative conforme o hardware que você já tem — custo extra R$0–50 por módulo.
- **[docs/APOSTILA-GUIA-PRATICO.md](docs/APOSTILA-GUIA-PRATICO.md)** — guia complementar estilo livro (9 capítulos): ranking Top 20 hardware keys, Frankenstein Key DIY (5 kits), protocolos avançados, cronograma manutenção, governança home lab, playbook de incidentes (5 cenários), cockpit Prometheus/Grafana + PowerShell/Rainmeter.
- **[playbooks/](playbooks/) reorganizados em 3 blocos temáticos** — `1-cofre/` (KeePass+VeraCrypt+NFC), `2-identidade-pgp/` (Tails+Smartcard+SSH), `3-backup-resiliencia/` (HD+off-site+restore). Cada um com README próprio, fluxograma Mermaid e deep links para os COMANDOs.
- **Scripts por mundo:** `scripts/debian/` · `tails/scripts/` · `whonix/scripts/` — [`ztc-close-cofre.sh`](scripts/debian/ztc-close-cofre.sh), [`ztc-snapshot-vault.sh`](scripts/debian/ztc-snapshot-vault.sh) e demais.
- **Auditoria Red/Blue/Purple Team** — 10 ataques simulados nos scripts reais. Endurecimentos aplicados: chave SSH com `command=rrsync` na VM, `rsync --checksum`, `StrictHostKeyChecking`, `chmod 600` no conf, Reset Code do smartcard documentado. Scorecard **8.7 → 9.2/10**.
- **Distro canônica padronizada:** Debian 13 (Trixie) em todo o curso, scripts e docs.
- **Repositório irmão:** [OpenPGP-GPG do Zero ao Expert](https://github.com/VIPs-com/OpenPGP-GPG-do-Zero-ao-Expert) ganhou [`playbooks/`](https://github.com/VIPs-com/OpenPGP-GPG-do-Zero-ao-Expert/tree/main/playbooks) — **10 guias** código-primeiro (0–9 + capstone Whonix) com fluxogramas Mermaid.
- **Link recíproco:** [Privacy-OS-Hub](https://github.com/VIPs-com/Privacy-OS-Hub) aponta para este repositório como baseline **opcional** (repo separado).

## Ecossistema VIPs-com (repositórios relacionados)

Cada curso é **independente** — escolha a trilha pelo objetivo. Este (Zero-Trust-Core) é o **baseline** de cofre, PGP, backup e SSH.

| Repositório | Foco | Relação com este curso |
|-------------|------|------------------------|
| **[OpenPGP-GPG do Zero ao Expert](https://github.com/VIPs-com/OpenPGP-GPG-do-Zero-ao-Expert)** | PGP do zero · trilha integrada ZTC | Pré-requisito recomendado (Expert) |
| **[Privacy-OS-Hub](https://github.com/VIPs-com/Privacy-OS-Hub)** | Tails + Haveno + Whonix (Cold-Tails/Hot-Whonix, Monero) | **Complementa** após M1/M2 — custódia e trades; **não** substitui o ZTC |
| **Zero-Trust-Core** (este) | KeePassXC, VeraCrypt, NFC, backup 3-2-1-1-0, SSH | Baseline opcional |

> **Ordem sugerida (Monero + privacidade):** [Privacy-OS-Hub](https://github.com/VIPs-com/Privacy-OS-Hub) Módulo 1 → Módulo 2 → **este curso** (ZTC). O guia Whonix **deste** repo é capstone de *baseline*; o M2 do hub foca *cold-signing* e custódia XMR.

## Licença

Este projeto está licenciado sob **Creative Commons Attribution-ShareAlike 4.0 International** (**CC BY-SA 4.0**).

- Resumo humano: [creativecommons.org/licenses/by-sa/4.0](https://creativecommons.org/licenses/by-sa/4.0/)
- Texto legal completo: [creativecommons.org/licenses/by-sa/4.0/legalcode](https://creativecommons.org/licenses/by-sa/4.0/legalcode)
- Cópia no repositório: **[LICENSE](./LICENSE)** (Copyright © 2026 Projeto Colaborativo VIPs-com)

Você pode compartilhar e adaptar o material, inclusive comercialmente, desde que **credite a fonte** e **repasse a mesma licença** nas obras derivadas.

## Créditos

**VIPs-com** (Projeto Colaborativo)

**Pré-requisito recomendado (trilha Expert):** [OpenPGP-GPG do Zero ao Expert](https://github.com/VIPs-com/OpenPGP-GPG-do-Zero-ao-Expert#trilha-integrada-zero-trust-core-expert) — o README desse repositório aponta para este curso e para o [Manual de uso](./docs/MANUAL-DE-USO.md) na secção *Trilha integrada*.

**Complemento operacional (Monero):** [Privacy-OS-Hub](https://github.com/VIPs-com/Privacy-OS-Hub) — o README do hub aponta para este repositório como baseline opcional; os dois mantêm **repos separados** e links recíprocos.
