# 📦 Inventário — software e hardware

**Zero Trust Core Expert v1.0.3** · Jul/2026 (baseline v1.0.2 · maio/2026)

Lista **completa e organizada** do que o aluno encontra no repositório e do que precisa montar no ambiente — por plataforma, por papel no curso e por trilha (**Turbo** / **Expert**).

**Curso (COMANDOs):** [🎓 Zero-Trust-Core-Expert - Versão 1.0.md](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md)  
**Fluxos visuais:** [DIAGRAMAS-VISUAIS.md](./DIAGRAMAS-VISUAIS.md) · **Hardware BR (preços):** [Apêndice C](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#apêndice-c--hardware-recomendado-brasil--2026) · **Multiplataforma:** [Apêndice D](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#apêndice-d--guia-multiplataforma)  
**Ranking Top 20 · DIY · Governança · Cockpit:** [APOSTILA-GUIA-PRATICO.md](./APOSTILA-GUIA-PRATICO.md)

* * *

## Legenda de inclusão no curso

| Símbolo | Significado |
| --- | --- |
| 🟢 | **Obrigatório** na trilha indicada — há COMANDO ou checkpoint |
| 🟡 | **Recomendado** — facilita a turma; alternativa aceitável documentada |
| 🔵 | **Opcional / lab** — útil mas não bloqueia checkpoints |
| ⚫ | **Horizonte** — citado como futuro ou **não** faz parte da v1.0.3 |

* * *

## Mapa do repositório (o que o aluno encontra aqui)

| Arquivo / recurso | Para quem | Quando usar |
| --- | --- | --- |
| [`🎓 Zero-Trust-Core-Expert - Versão 1.0.md`](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md) | **Aluno** | Estudo; COMANDO a COMANDO; apêndices A–F |
| [`docs/DIAGRAMAS-VISUAIS.md`](./DIAGRAMAS-VISUAIS.md) | Aluno / instrutor | Impressão ou PDF dos fluxos A–N |
| [`docs/INVENTARIO-SOFTWARE-HARDWARE.md`](./INVENTARIO-SOFTWARE-HARDWARE.md) | **Aluno** | Montar PC, **kits em R$**, conferir versões |
| [`docs/MANUAL-DE-USO.md`](./MANUAL-DE-USO.md) | Aluno novo | Primeira hora no GitHub / ZIP |
| [`docs/APOSTILA-GUIA-PRATICO.md`](./APOSTILA-GUIA-PRATICO.md) | **Aluno avançado** | Hardware alternativo, DIY, governança, cockpit — 9 capítulos + referência rápida |
| [`scripts/debian/ztc-health.sh`](../scripts/debian/ztc-health.sh) | Aluno (Expert) | [Módulo 5](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-5-automação-e-health-check) — health-check |
| [`scripts/debian/ztc-rsync-offsite.sh`](../scripts/debian/ztc-rsync-offsite.sh) | Aluno (Expert) | [Módulo 4.2](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-42-vm-off-site--wireguard--rsync) — backup VM |
| [`scripts/debian/ztc-open-cofre.sh`](../scripts/debian/ztc-open-cofre.sh) | Aluno (Expert) | [COMANDO 5.3](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-53-keepass--veracrypt-condicional-nfc-opcional) — após Checkpoint 2 |
| [`whonix/scripts/`](../whonix/scripts/) | Aluno (Expert capstone) | W00–W03 — VirtualBox, verify `.ova`, health Workstation |
| [`docs/SLIDES-ABERTURA-TURMA.md`](./SLIDES-ABERTURA-TURMA.md) | **Instrutor** | Primeira aula (4 slides) |
| [Issue #2](https://github.com/VIPs-com/Zero-Trust-Core/issues/2) | Instrutor | Evidência hardware NFC + Tails |

* * *

## Baseline de versões (revalidar antes da turma)

| Componente | Versão no curso (jul/2026) | Onde revalidar |
| --- | --- | --- |
| **Tails** | 7.8+ | [tails.net/latest](https://tails.net/latest/) |
| **KeePassXC** | 2.7.12+ | [keepassxc.org](https://keepassxc.org/) |
| **VeraCrypt** | 1.26.24 | [veracrypt.fr](https://www.veracrypt.fr/) |
| **GnuPG** | 2.4.4+ (host) | `apt` / [gnupg.org](https://www.gnupg.org/) |
| **Gpg4win** (Windows) | 5.0.x | [gpg4win.org](https://www.gpg4win.org/) |

> No **Tails 7.6+** o gerenciador padrão é **GNOME Secrets** (`.kdbx` compatível). O curso usa **KeePassXC no host diário**; no Tails o foco é **GnuPG** para a master.

* * *

## 🔬 Dispositivos testados (compatibilidade confirmada)

> 🔵 **Contribua:** execute os testes de campo e registre no [issue #2](https://github.com/VIPs-com/Zero-Trust-Core/issues/2). Esta tabela é atualizada com evidência real de cada turma.

| # | Categoria | Dispositivo / versão | Status | SO / ambiente | COMANDO / módulo | Observação |
| :---: | --- | --- | :---: | --- | --- | --- |
| 1 | **Host OS** | Debian 13 (Trixie) | ✅ | — | Todos | Distro canônica do curso |
| 2 | **Tails** | Tails 7.8 | ✅ | — | [0.5](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-05-pré-vôo-do-tails-no-host-com-internet) · [1.x](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-1-sua-primeira-chave-no-air-gap-tails) | Revalidar em [tails.net/latest](https://tails.net/latest/) antes de cada turma |
| 3 | **KeePassXC** | 2.7.12+ | ✅ | Debian 13 | [2B](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-2b-ntag--keyfile-keepassxc) · [3.1](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-31-keepassxc--veracrypt) | `apt install keepassxc` |
| 4 | **VeraCrypt** | 1.26.24 | ✅ | Debian 13 | [3.1.1](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-311-criar-volume-veracrypt)–[3.1.3](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-313-política-de-sincronização) | `dpkg -i` oficial obrigatório; flag `-t` validada |
| 5 | **GnuPG** | 2.4.4+ | ✅ | Debian 13 | 0.x · 1.x · [3.2](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-32-ssh-via-gpg-agent-subchave-a) | `gpg --version` |
| 6 | **Leitor NFC USB** | ACS ACR122U | ⏳ | Debian 13 | `nfc-list` · [5.3](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-53-keepass--veracrypt-condicional-nfc-opcional) | Referência do curso — aguarda [issue #2](https://github.com/VIPs-com/Zero-Trust-Core/issues/2) |
| 7 | **Leitor NFC USB** | PN532 genérico USB | ⏳ | Debian 13 | `nfc-list` | Compatível com `libnfc` — aguarda evidência |
| 8 | **Tag NFC** | NTAG215 (diversos) | ⏳ | Android NFC + `nfc-list` | [2B.3](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-2b3-gravar-o-mesmo-keyfile-em-3-ntags) | Tamanho ideal para keyfile — aguarda [issue #2](https://github.com/VIPs-com/Zero-Trust-Core/issues/2) |
| 9 | **Tag NFC** | NTAG213 (diversos) | ⏳ | Android NFC + `nfc-list` | [2B.3](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-2b3-gravar-o-mesmo-keyfile-em-3-ntags) | 144 bytes; suficiente para keyfile de 44 bytes |
| 10 | **Smartcard OpenPGP** | Nitrokey 3A NFC | ⏳ | Debian 13 + pcscd | [2A.1](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-2a1-preparar-leitor-e-cartão)–[2A.3](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-2a3-pins-user-e-admin) | Recomendado Kit C/D |
| 11 | **Smartcard OpenPGP** | YubiKey 5 NFC | ⏳ | Debian 13 + pcscd | [2A.1](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-2a1-preparar-leitor-e-cartão)–[2A.3](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-2a3-pins-user-e-admin) | Interface OpenPGP (não FIDO2) |
| 12 | **Smartcard OpenPGP** | JavaCard / JCOP genérico | ⏳ | Debian 13 + pcscd | [2A.1](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-2a1-preparar-leitor-e-cartão)–[2A.3](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-2a3-pins-user-e-admin) | Mais barato; auditoria limitada |
| 13 | **Windows + WSL2** | Windows 11 23H2 + Gpg4win 5.x | 🟡 | WSL2 Ubuntu | [3.2](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-32-ssh-via-gpg-agent-subchave-a) (parcial) | [Apêndice D.1](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#apêndice-d1--wsl2--gpg-agent-passo-a-passo) — NFC frágil; preferir Linux |
| 14 | **macOS** | Sonoma 14+ + GPG Suite | 🟡 | macOS | [3.2](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-32-ssh-via-gpg-agent-subchave-a) (parcial) | [Apêndice D](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#apêndice-d--guia-multiplataforma) — sem `nfc-list` nativo |
| 15 | **Whonix** | 18.x LXQt + VirtualBox 7.x | ⏳ | Debian 13 host | [W00–W03](../whonix/playbooks/README.md) · `ztc-whonix-*` | Capstone v1.0.3 — aguarda evidência hardware |

**Legenda de status desta tabela:**
- ✅ Testado e documentado pela equipe (evidência no repositório ou commit de validação)
- ⏳ Pendente — aguarda evidência física (contribua via [issue #2](https://github.com/VIPs-com/Zero-Trust-Core/issues/2))
- 🟡 Compatível esperado com ressalvas documentadas

* * *

## 🖥️ Software por plataforma

### 🔹 Linux (Debian 13 / Ubuntu — PC de uso diário)

| Software | Curso | Módulo / uso |
| --- | :---: | --- |
| **GnuPG** 2.4.x + `gpg-agent` | 🟢 Expert | 0.6, 1.x, 3.2 SSH |
| **pcscd**, **scdaemon**, **libccid** | 🟢 Expert | Smartcard OpenPGP (2A) |
| **KeePassXC** 2.7.12+ | 🟢 Turbo + Expert | 2B, 3.1, 5.3 |
| **VeraCrypt** 1.26.24 (`-t` CLI) | 🟢 Turbo + Expert | 3.1, 5.3 |
| **OpenSSH** + `SSH_AUTH_SOCK` do GPG | 🟢 Expert | 3.2 |
| **age** | 🟢 Expert | 2B.2 keyfile; backup master Tails |
| **libnfc** + `nfc-list` | 🟡 | 5.1, 5.3 se `ZTC_NFC_UID` definido |
| **WireGuard** | 🟡 Expert | 4.2 VM off-site |
| **borgbackup** | 🔵 Expert | 4.2 off-site **imutável** (append-only) — `ztc-borg-offsite.sh` |
| **VirtualBox / KVM** | 🔵 | Virtualização para **Whonix** — instalação verificada: [W00](../whonix/playbooks/W00-instalar-configurar-virtualbox.md) |
| **rsync**, **OpenSSH** (cliente) | 🟢 Expert | 4.2.3 |
| **sha256sum**, manifestos assinados | 🟢 Expert | 4.x integridade |
| Scripts `ztc-*.sh` | 🔵 Expert | 5.x (bash, `cron` opcional) |
| **Sequoia PGP (`sq`)** | ⚫ | Horizonte PQC (Módulo 8) — **não** substitui GnuPG na v1.0.3 |
| **GnuPG 2.5 + ML-KEM** | ⚫ | Experimental — fora da baseline da turma |
| **rclone crypt** (S3) | 🔵 | Alternativa segundo off-site (4.2) |
| **Tailscale** | 🔵 | Alternativa ao WireGuard (4.2) |

**Pacote típico (lab Debian 13):**

```sh
sudo apt install -y gnupg2 pcscd scdaemon libccid openssh-client \
  keepassxc age rsync wireguard libnfc-bin borgbackup
# VeraCrypt: baixar .deb em https://www.veracrypt.fr/en/Downloads.html → sudo dpkg -i veracrypt-*.deb
```

---

### 🔹 Tails (air-gap — Parte 1)

| Software | Curso | Notas |
| --- | :---: | --- |
| **Tails** 7.8+ | 🟢 Expert | Boot USB; **sem** persistência na primeira master |
| **GnuPG** (incluído no Tails) | 🟢 Expert | [COMANDO 1.1–1.6](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-1-sua-primeira-chave-no-air-gap-tails) |
| **GNOME Secrets** | 🟡 | Padrão Tails 7.6+; opcional se quiser `.kdbx` no Tails |
| **KeePassXC** no Tails | 🔵 | [Software adicional](https://tails.net/doc/persistent_storage/additional_software/index.en.html) — curso não exige |
| **age**, **wget**, **curl** | 🟢 | Instalação COMANDO 1.x (`apt` no Tails com persistência ou sessão) |

---

### 🔹 Windows 11 / WSL2

| Software | Curso | Notas |
| --- | :---: | --- |
| **KeePassXC** (build Windows) | 🟢 Turbo | Cofre + keyfile em arquivo local |
| **VeraCrypt** (build Windows) | 🟢 Turbo | Produção no Windows; WSL = lab |
| **Gpg4win** 5.0.x (Kleopatra + `gpg-agent`) | 🟡 Expert | Smartcard + SSH com leitor CCID USB |
| **WSL2** + Ubuntu + `pcscd` | 🟡 | Apêndice D.1 — **um** agente GPG apenas |
| **OpenSSH** (Windows ou só WSL) | 🟡 | Não misturar com PuTTY/Pageant no mesmo cartão |
| **PuTTY / Pageant** | 🔵 | Evitar conflito com `gpg-agent` do WSL |
| **usbipd-win** | 🔵 | Leitor CCID no WSL (avançado) |
| **NFC + VeraCrypt no WSL** | 🔴 | Frágil — prefira Linux nativo ou GUI Windows |

---

### 🔹 macOS

| Software | Curso | Notas |
| --- | :---: | --- |
| **KeePassXC** | 🟢 | Apêndice D |
| **VeraCrypt** | 🟢 | Apêndice D |
| **GPG Suite** ou Homebrew `gnupg` | 🟡 Expert | Smartcard via leitor CCID |
| **OpenSSH** + `gpg-agent` | 🟡 | Mesma lógica do Linux, com ressalvas do SO |

---

### 🔹 Android

| Software | Curso | Notas |
| --- | :---: | --- |
| **[NFC Tools](https://www.wakdev.com/en/apps/nfc-tools.html)** | 🟢 Turbo | Gravar NTAG / ler UID (2B.3) |
| **OpenKeychain** (F-Droid / APK offline) | 🟡 | Backup móvel PGP; sem substituir smartcard no PC |
| **KeePassDX** / **KeePass2Android** | 🟡 | Alternativa a KeePassXC desktop — sincronize só `.kdbx` cifrado |
| **Termux** + sshd/rsync | 🔵 H3b/H5b | Servidor SSH de backup em celular antigo; ver Apêndice G |
| **Aegis Authenticator** (F-Droid) | 🟢 H6 | TOTP offline — open source, auditado, sem cloud |

---

### 🔹 iOS

| Software | Curso | Notas |
| --- | :---: | --- |
| **KeePassium** ou compatível `.kdbx` | 🟡 | Cofre móvel; VeraCrypt **não** no iPhone |
| **OpenPGP em smartcard** | 🔴 | Suporte limitado — **não** prometa paridade Expert |
| **PGP Everywhere** / apps PGP | 🔵 | Não auditados neste curso — use por sua conta |
| **Cryptomator** | 🔵 | Nuvem client-side; **não** substitui VeraCrypt local do curso |
| **Apps NFC** | 🔵 | Depende do modelo; NTAG keyfile = ritual no **PC** |

> Onboarding do curso: iPhone como dispositivo **principal** → planejar **Android ou PC Linux** para trilha Expert.

---

### 🔹 Servidores caseiros — Apêndice G Módulo H5

Para quem quer substituir ou complementar o VPS cloud do Módulo 4.2 com hardware próprio.

| Opção | Custo extra | Consumo 24/7 | Software base | Ideal para |
| --- | ---: | :---: | --- | --- |
| **VM no PC** (H5a) | R$0 | ~PC ligado | VirtualBox + Debian 13 (Trixie) | Backup quando PC está on |
| **Android Termux** (H5b) | R$0 | ~4 W | Termux + sshd + rsync | Celular antigo que já existe |
| **TV Box Android** (H5c) | R$80–200 | <10 W | UserLAnd + Debian | 24/7 barato |
| **Raspberry Pi 4/5** (H5d) | R$200–400 | ~6 W | Raspberry Pi OS (Debian-based) | Setup canônico, documentação ampla |
| **Mini PC N100/J4125** (H5e) | R$300–500 | 12 W | Debian 13 (Trixie) nativo | Mais versátil, sem virtualização |

> Todos os cenários usam o mesmo fluxo WireGuard + rsync do Módulo 4.2.
> Inserir o IP do servidor em `ZTC_REMOTE` no `ztc.conf`.

* * *

## 🔧 Hardware e periféricos

### Papéis (não misturar)

| Tipo | Exemplos | Função no curso | Exportável? |
| --- | --- | --- | :---: |
| **NTAG** 213/215 | Tags baratas | Keyfile KeePass (2B) | Sim (clonável) |
| **Smartcard OpenPGP** | Nitrokey 3, YubiKey OpenPGP, JavaCard | Subkeys [S][E][A] (2A) | Não (`keytocard`) |
| **Leitor NFC USB** | ACR122U, genéricos PN532 | `nfc-list`, 5.3 | — |
| **Leitor CCID** | Integrado ZBook, USB Omnikey | `gpg --card-status` | — |

### 🔹 Internos (máquina principal)

| Item | Curso | Trilha |
| --- | :---: | --- |
| PC / notebook confiável (Linux preferido para Expert) | 🟢 | Todas |
| Portas **USB** funcionais (dados, não só carga) | 🟢 | Tokens, Tails, HD |
| Slot smartcard **contato** (ex. ZBook) | 🔵 | 2A — **não** substitui NTAG NFC |

### 🔹 Externos (mídia e tokens)

| Item | Curso | Módulo / uso |
| --- | :---: | --- |
| **Pendrive** 32 GB+ (Tails) | 🟢 Expert | 0.5, 1.1 |
| **2–3× NTAG** idênticos | 🟢 Turbo | 2B.3 (#1 bolso, #2 cofre, #3 off-site) |
| **Smartcard** + reserva **B** | 🟢 Expert | 2A, 6.1 simulação |
| **Leitor NFC USB** | 🟡 Turbo/Expert | 5.3, instrutor [issue #2](https://github.com/VIPs-com/Zero-Trust-Core/issues/2) |
| **HD externo** USB 3 | 🟢 Expert | 4.x backup frio |
| **Celular antigo** Android (sem SIM, avião) | 🔵 | 0.9 alternativa fraca ao Tails |
| **Papel** (revogação, fingerprints) | 🟢 Expert | 1.x, 4.x, runbook |
| **Placa metal / QR** (fingerprint) | 🟡 | Diagrama backup imutável |
| **DVD-R / Blu-ray** | 🔵 | Mídia imutável opcional — mesmo princípio do papel |
| **microSD** em adaptador USB | 🔵 | Cópia offline opcional |
| **Cofre físico** / local off-site | 🟡 | NTAG #3, HD, pendrive |
| **VPS** 1 GB (VM) | 🟡 Expert | 4.2 WireGuard + rsync |

**Referência de compra (Brasil):** [Apêndice C no curso](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#apêndice-c--hardware-recomendado-brasil--2026) · **kits com valores em R$:** [§ Kit mínimo de compra](#-kit-mínimo-de-compra-brasil--referência-2026).

* * *

## 🛒 Kit mínimo de compra (Brasil · referência 2026)

> **Aviso:** valores **indicativos** (mercado BR, importação e câmbio variam). Confira sempre antes de comprar. **Software do curso = R$ 0** (open-source). A tabela cobre só **hardware e serviços**.

### O que você já pode ter (custo zero)

| Item | Custo |
| --- | --- |
| PC ou notebook que já usa | R$ 0 |
| Smartphone Android antigo (gravar NTAG) | R$ 0 (reutilizado) |
| GnuPG, KeePassXC, VeraCrypt, Tails, `age`, scripts `ztc-*` | R$ 0 |

---

### Kit A — Trilha **Turbo** (mínimo absoluto)

Para KeePass + keyfile NTAG + VeraCrypt **sem** Tails, smartcard nem VM.

| # | Item | Qtd | Faixa (R$) | Observação |
| --- | --- | ---: | --- | --- |
| 1 | Tags **NTAG213/215** (pacote) | 1 pacote (≥3 tags) | 25 – 55 | Use 3 iguais; sobra do pacote para reserva |
| 2 | **Pendrive** 16–32 GB (opcional) | 1 | 25 – 50 | Backup `.age` do keyfile em mídia separada |
| | **Subtotal hardware** | | **~50 – 105** | |
| 3 | Leitor **NFC USB** ACR122U (opcional) | 1 | 80 – 160 | Só se o PC não tiver NFC e não usar Android para gravar |

**Com Android para gravar NTAG:** pode **pular** o leitor (item 3) → kit fica **~R$ 50–105**.

---

### Kit B — Trilha **Turbo** (confortável)

Turbo + leitor no PC + automação Módulo 5.3 no Linux.

| # | Item | Qtd | Faixa (R$) | Observação |
| --- | --- | ---: | --- | --- |
| 1 | Kit A (NTAG + pendrive opcional) | — | 50 – 105 | Base |
| 2 | Leitor NFC USB **ACR122U** (ou PN532 compatível `libnfc`) | 1 | 80 – 160 | Necessário para `nfc-list` / `ztc-open-cofre.sh` no PC |
| | **Subtotal** | | **~130 – 265** | |

---

### Kit C — Trilha **Expert** (essencial)

Turbo confortável + identidade PGP air-gap + backup frio (sem VM ainda).

| # | Item | Qtd | Faixa (R$) | Observação |
| --- | --- | ---: | --- | --- |
| 1 | Kit B | — | 130 – 265 | Cofre físico NFC |
| 2 | **Pendrive** 32 GB (dedicado Tails) | 1 | 35 – 65 | Só para Tails; não misturar com outros arquivos |
| 3 | **Smartcard OpenPGP** (1 unidade diária) | 1 | 280 – 750 | Nitrokey Start/3A, YubiKey 5 **OpenPGP**, etc. — evite clone sem marca |
| 4 | **Smartcard reserva B** (simulação 6.1) | 1 | 0 – 750 | Segundo token **ou** backup `.asc` cifrado no Tails (sem custo extra se planejar no COMANDO 1.x) |
| 5 | **HD externo** USB 3 (1 TB+) | 1 | 280 – 480 | Backup frio 3-2-1-1-0 |
| 6 | **Leitor CCID USB** (se o PC não tiver slot) | 0–1 | 0 – 200 | ZBook/slot integrado = R$ 0; senão Omnikey/ACS |
| | **Subtotal** (1 token + HD, leitor CCID incluso) | | **~725 – 1.770** | |
| | **Subtotal** (2 tokens novos + HD) | | **~1.005 – 2.520** | |

> 💡 **Alternativa mais barata ao par de YubiKeys:** 1× smartcard OpenPGP + 3× NTAG + Tails costuma ficar **bem abaixo** de duas chaves proprietárias premium — alinhado à proposta do curso.

---

### Kit D — Trilha **Expert** (completo)

Expert essencial + off-site (VM) + itens de contingência física.

| # | Item | Qtd | Faixa (R$) | Observação |
| --- | --- | ---: | --- | --- |
| 1 | Kit C (1 token + HD) | — | 725 – 1.770 | Base Expert |
| 2 | **VPS** 1 vCPU / 1 GB RAM | 1 | 15 – 45 / **mês** | VM off-site; WireGuard + rsync (Módulo 4.2) |
| 3 | **Papel + impressão** runbook / revogação | 1 lote | 5 – 30 | Módulo 6 — runbook no bolso do cartão #2 |
| 4 | **Placa metal** ou gravação QR (opcional) | 0–1 | 40 – 150 | Fingerprint / backup imutável |
| 5 | **Cofre físico** ou envelope lacrado off-site | 0–1 | 0 – 200+ | NTAG #3 + mídia; pode ser “casa de familiar” sem custo |
| | **Investimento inicial** (sem VPS mensal) | | **~770 – 2.150** | |
| | **Custo recorrente** | | **~15 – 45 / mês** | VPS (cancele após o curso se for só lab) |

---

### Comparativo rápido (uma linha)

| Kit | Trilha | Investimento inicial (ordem de grandeza) |
| --- | --- | --- |
| **A** | Turbo mínimo | **~R$ 50 – 105** |
| **B** | Turbo + NFC no PC | **~R$ 130 – 265** |
| **C** | Expert (PGP + backup) | **~R$ 725 – 1.770** (1 token) |
| **D** | Expert + VM + contingência | **~R$ 770 – 2.150** + VPS/mês |

---

### Onde comprar (Brasil)

| Tipo | Sugestão |
| --- | --- |
| NTAG, leitor ACR122U | Marketplaces nacionais (ML, Shopee, lojas Arduino/NFC) — leia avaliações |
| Nitrokey / tokens EU | Importação oficial ou revendedor autorizado |
| Pendrive / HD | Marcas conhecidas; evite o mais barato sem marca para Tails |
| VPS | Qualquer provedor BR/EU com IPv4; use só para **blobs opacos** |

**Evitar:** “YubiKey” genérica sem firmware auditável; NTAG **já gravado** por terceiro; um único cartão NTAG sem backup `age`.

---

### Depois de comprar (antes da aula 1)

1. Conferir [baseline de versões](#baseline-de-versões-revalidar-antes-da-turma) (Tails, KeePassXC, VeraCrypt).  
2. Gravar Tails no pendrive ([COMANDO 0.5](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-05-pré-vôo-do-tails-no-host-com-internet) / [1.1](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-11-gravar-e-iniciar-o-tails)).  
3. Testar `gpg --card-status` com smartcard **antes** do `keytocard`.  
4. Testar `nfc-list` ou NFC Tools com as 3 tags.  
5. Instrutor: [CHECKLIST-PRE-TURMA-EQUIPE.md](./CHECKLIST-PRE-TURMA-EQUIPE.md) + [issue #2](https://github.com/VIPs-com/Zero-Trust-Core/issues/2).

* * *

## 📊 Backup, integridade e contingência

| Prática | No curso? | Onde |
| --- | :---: | --- |
| **3-2-1-1-0** (matriz de ativos) | 🟢 | Módulo 4 |
| Cópias em **2 mídias** (HD + VM + físico) | 🟢 | 4.1–4.2 |
| **1 off-site** (VM só blobs opacos) | 🟢 | 4.2 |
| **1 offline / air-gap** (Tails, pendrive cofre) | 🟢 | 1.x, 2B.2 |
| **0 erros** — `sha256` + manifesto assinado [S] | 🟢 | 4.x |
| **Revogação** em papel + segunda mídia | 🟢 | 1.x, Checkpoint 1 |
| **Cartão reserva** (NTAG #2/#3 ou smartcard B) | 🟢 | 6.x runbook |
| **Simulação de mesa** obrigatória | 🟢 | [COMANDO 6.1](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-61-simulação-de-mesa-obrigatória) |
| **Break-glass** VM (sem depender do NTAG diário) | 🟢 | 4.2 |
| Hidden volume VeraCrypt | 🔵 | Não ensinado passo a passo na v1.0.3 |

* * *

## ✅ Checklist por trilha

### 🟢 Trilha Turbo (~8–12 h)

**Software:** KeePassXC, VeraCrypt, NFC Tools (Android) ou leitor no PC, opcional `age` se fizer 2B.2.

**Hardware:** PC, 3× NTAG, pendrive opcional, HD opcional.

**Não exige:** Tails, smartcard, WireGuard, `ztc-rsync`, SSH gpg-agent.

---

### 🔵 Trilha Expert (completa)

**Software (mínimo):** tudo da tabela Linux + Tails + WireGuard + `age` + scripts `ztc-*` + OpenKeychain (backup).

**Hardware (mínimo):** Turbo + pendrive Tails + smartcard (+ reserva) + HD externo + VPS lab + leitor CCID/NFC conforme módulos.

**Checkpoints que forçam o inventário:** CP1 (Tails/revogação), CP2 (NTAG+VeraCrypt+SSH), CP3 (backup+VM+6.1).

* * *

## 📋 Avaliação: sua lista × o curso v1.0.3

| Item (lista consolidada) | Status no curso | Observação |
| --- | :---: | --- |
| GnuPG, KeePassXC, VeraCrypt, OpenSSH | 🟢 Incluso | Baseline documentada |
| pcscd / smartcard | 🟢 Incluso | Módulo 2A |
| Tails 7.8+ | 🟢 Incluso | Baseline 7.8; revalidar por turma |
| OpenKeychain, NFC Tools | 🟢/🟡 Incluso | Android |
| Gpg4win, WSL2 | 🟡 Incluso | Apêndice D + D.1 |
| WireGuard, age, rsync | 🟢/🟡 Incluso | Parte 3–4 |
| `ztc-open-cofre.sh` | 🟢 Incluso | v1.0.2+ |
| `ztc-whonix-install-virtualbox.sh` | 🔵 Capstone | v1.0.3 · [W00](../whonix/playbooks/W00-instalar-configurar-virtualbox.md) |
| `ztc-whonix-verify-image.sh` | 🔵 Capstone | v1.0.3 · PGP `derivative.asc` |
| `ztc-whonix-import-ova.sh` | 🔵 Capstone | v1.0.3 · [W01](../whonix/playbooks/W01-instalar-whonix.md) |
| `ztc-whonix-health.sh` | 🔵 Capstone | v1.0.3 · Workstation |
| macOS (GPG Suite) | 🟡 Incluso | Apêndice D |
| NTAG + leitor ACR122U + Nitrokey | 🟢 Incluso | Apêndice C |
| HD, pendrive, VPS, celular antigo | 🟢/🔵 Incluso | |
| Papel / metal / DVD / microSD / cofre | 🟡/🔵 Incluso | Imutável = conceito; DVD não tem COMANDO dedicado |
| Sequoia PGP | ⚫ Não obrigatório | Horizonte Módulo 8 |
| GnuPG 2.5 ML-KEM | ⚫ Não obrigatório | PQC experimental |
| PuTTY, Termux | 🔵 Opcional | Mencionado como alternativa/lab |
| KeePassium, Cryptomator, PGP Everywhere | 🔵 iOS opcional | Expectativa limitada documentada |
| Hidden volume VeraCrypt | 🔵 Não ensinado | Compatível com VeraCrypt, fora dos COMANDOs |

**Conclusão:** a lista que você montou está **alinhada** ao curso; o que faltava no índice era **um único inventário navegável** — este arquivo — e referência explícita a **macOS**, **age**, **libnfc** e **scripts**, que já estavam nos COMANDOs mas dispersos.

* * *

## Links rápidos

| Tópico | Link |
| --- | --- |
| Curso canônico | [🎓 Zero-Trust-Core-Expert](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md) |
| Release v1.0.5 (atual) | https://github.com/VIPs-com/Zero-Trust-Core/releases/tag/v1.0.5 |
| Release v1.0.3 (Whonix editorial) | https://github.com/VIPs-com/Zero-Trust-Core/releases/tag/v1.0.3 |
| Release v1.0.2 | https://github.com/VIPs-com/Zero-Trust-Core/releases/tag/v1.0.2 |
| OpenPGP (pré-requisito Expert) | https://github.com/VIPs-com/OpenPGP-GPG-do-Zero-ao-Expert#trilha-integrada-zero-trust-core-expert |

---

*Inventário aluno · VIPs-com · CC BY-SA 4.0*
