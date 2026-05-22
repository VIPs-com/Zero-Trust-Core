# 📖 Apostila Prática — Zero Trust Core Expert

**Versão:** 1.0.2 · **VIPs-com** · [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)  
**Formato:** Capítulo + Lição — do zero ao avançado  
**Complementa:** [🎓 Curso principal](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md) · [Manual de Uso](./MANUAL-DE-USO.md)

> *Esta apostila não substitui o curso — ela o aprofunda.*  
> Use o **SUMÁRIO** abaixo para ir direto ao que você precisa.  
> Use o **Capítulo 10** para navegar por CENÁRIO (ex.: "perdi meu NTAG — o que faço?").

---

## SUMÁRIO

**[Prefácio — Carta ao Aluno](#prefácio--carta-ao-aluno)**

### PARTE I — FUNDAMENTOS: DO ZERO AO COFRE
- [Capítulo 1 — LIÇÃO #1: Entenda o campo de batalha](#capítulo-1--lição-1-entenda-o-campo-de-batalha)
- [Capítulo 2 — LIÇÃO #2: Escolha suas armas (hardware)](#capítulo-2--lição-2-escolha-suas-armas-hardware)
- [Capítulo 3 — LIÇÃO #3: Construa seu cofre digital](#capítulo-3--lição-3-construa-seu-cofre-digital)

### PARTE II — SETUP AVANÇADO
- [Capítulo 4 — LIÇÃO #4: Forje sua própria chave (Frankenstein Key)](#capítulo-4--lição-4-forje-sua-própria-chave-frankenstein-key)
- [Capítulo 5 — LIÇÃO #5: Expanda os protocolos](#capítulo-5--lição-5-expanda-os-protocolos)
- [Capítulo 6 — LIÇÃO #6: Manutenção profissional](#capítulo-6--lição-6-manutenção-profissional)

### PARTE III — GOVERNANÇA HOME LAB
- [Capítulo 7 — LIÇÃO #7: Governe como uma empresa](#capítulo-7--lição-7-governe-como-uma-empresa)
- [Capítulo 8 — LIÇÃO #8: Playbook de incidentes](#capítulo-8--lição-8-playbook-de-incidentes)
- [Capítulo 9 — LIÇÃO #9: Automação do cockpit](#capítulo-9--lição-9-automação-do-cockpit)

### REFERÊNCIA E NAVEGAÇÃO
- [Capítulo 10 — Referência Rápida: vá direto ao COMANDO](#capítulo-10--referência-rápida-vá-direto-ao-comando)
- [Glossário da Apostila](#glossário-da-apostila)
- [Posfácio](#posfácio)

---

## Prefácio — Carta ao Aluno

Você está segurando — virtualmente — algo raro: um guia que trata sua segurança pessoal com a mesma seriedade que uma empresa de infra trata a dela.

Este curso não te pede para confiar em nenhuma nuvem, nenhuma empresa, nenhum serviço de terceiros. Ele te ensina a **ser a empresa**. A gerar suas próprias chaves. A testar seus próprios backups. A ter um runbook de contingência antes de precisar dele.

Esta apostila existe para duas situações:

1. **Você quer ir além do curso** — hardware alternativo, DIY, governança corporativa pessoal, automação.
2. **Você quer ir direto ao ponto** — "como revogo minha chave?", "qual token comprar?", "como montar o segundo fator do KeePass?" — sem reler o curso inteiro.

Use os Capítulos 1–9 para aprofundar. Use o Capítulo 10 para navegar por cenário.

Boa jornada, artesão.

---

# PARTE I — FUNDAMENTOS: DO ZERO AO COFRE

---

## Capítulo 1

### LIÇÃO #1: ENTENDA O CAMPO DE BATALHA

> *"Não importa qual arma você usa — importa entender por que você a usa."*

#### OpenPGP vs FIDO2/WebAuthn — dois mundos, dois propósitos

Muitos alunos chegam ao curso perguntando: "por que usar OpenPGP se o mundo foi para FIDO2?" A resposta está no propósito de cada tecnologia.

| Aspecto | **OpenPGP** | **FIDO2/WebAuthn** |
| --- | --- | --- |
| **Para quê** | Criptografia de arquivos, assinaturas digitais, identidade offline | Autenticação sem senha em serviços online |
| **Complexidade** | Alta — exige configuração manual | Baixa — nativo em navegadores e sistemas |
| **Onde funciona** | GnuPG, Thunderbird, SSH, VeraCrypt | Google, GitHub, Microsoft, Apple |
| **Segurança** | Você controla tudo — offline, sem terceiros | Protege contra phishing, MFA universal |
| **Futuro** | Nicho (pesquisa, governos, entusiastas) | Expansão com passkeys + biometria |

#### Por que este curso usa OpenPGP

OpenPGP é a única tecnologia que permite:
- Gerar chaves em ambiente completamente offline (Tails)
- Assinar e cifrar arquivos sem depender de serviços externos
- Usar a mesma chave para SSH, e-mail e identidade digital
- Manter a master key física e offline para sempre

FIDO2 é indispensável para logins externos — mas não substitui OpenPGP para **soberania digital local**.

#### Linha do tempo: ascensão e queda do OpenPGP em tokens

| Período | O que aconteceu |
| --- | --- |
| **1997–2010** | OpenPGP domina criptografia em e-mails, smartcards e tokens corporativos |
| **2014–2018** | FIDO U2F surge com suporte em Chrome e Firefox |
| **2019–2023** | FIDO2/WebAuthn vira padrão global — navegadores, Windows, iOS, Android |
| **2024–2026** | OpenPGP = nicho técnico; passkeys = mainstream |

#### Estratégia híbrida — o melhor dos dois mundos

```
Segredos internos (home lab, SSH, arquivos)  →  OpenPGP
Logins externos (GitHub, Google, serviços)   →  FIDO2/WebAuthn
Camada híbrida (infra corporativa local)     →  Ambos
```

> 📎 **No curso:** OpenPGP → [Módulo 1](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-1-sua-primeira-chave-no-air-gap-tails) · SSH via gpg-agent → [Módulo 3.2](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-32-ssh-via-gpg-agent-subchave-a) · FIDO2 = Apêndice C (hardware externo)

---

## Capítulo 2

### LIÇÃO #2: ESCOLHA SUAS ARMAS (HARDWARE)

> *"A chave certa é a que você vai usar — não a mais cara."*

#### 🏆 Ranking técnico — Top chaves de segurança (2026)

| Posição | Modelo | País | OpenPGP | FIDO2 | OTP | Preço med. |
| :---: | --- | --- | :---: | :---: | :---: | --- |
| 1 | **YubiKey 5 Series** | Suécia/EUA | ✅ | ✅ | ✅ | US$50–70 |
| 2 | **Nitrokey 3C NFC** | Alemanha 🟢 | ✅ | ✅ | ✅ | US$60–70 |
| 3 | **SoloKeys V2** | EUA/EU | ❌ | ✅ | ✅* | US$40–50 |
| 4 | **OnlyKey** | EUA | ✅ | ✅ | ✅ | US$50–60 |
| 5 | **Feitian ePass FIDO2** | China | ❌ | ✅ | ❌ | US$25–35 |
| 6 | **Feitian MultiPass** | China | ❌ | ✅ | ✅ | US$35–45 |
| 7 | **Thetis Pro-A** | EUA | ❌ | ✅ | ❌ | US$26–30 |
| 8 | **Secalot USB Token** | Alemanha | ✅ | ✅ | ✅ | US$45 |
| 9 | **Google Titan** | EUA | ❌ | ✅ | ❌ | US$40–50 |
| 10 | **Winkeo FIDO2** | França | ❌ | ✅ | ❌ | US$25 |

> *SoloKeys suporta OTP via firmware alternativo.
> 🟢 = open source, firmware auditável.

#### Qual comprar para este curso?

| Cenário do aluno | Recomendação |
| --- | --- |
| **Trilha Expert (OpenPGP obrigatório)** | Nitrokey 3C NFC (open source) ou YubiKey 5 NFC |
| **Trilha Turbo (só cofre + NTAG)** | NTAG213/215 (~R$3–8 cada) + qualquer leitor NFC |
| **Orçamento máximo** | YubiKey 5C NFC (US$55) — maior ecossistema |
| **Orçamento mínimo com OpenPGP** | Nitrokey 3C NFC — menor preço, open source |
| **FIDO2 barato para contas externas** | Thetis Pro-A (~US$28) ou Feitian ePass (~US$30) |

#### ⚠️ NTAG ≠ Smartcard OpenPGP ≠ YubiKey

Esta distinção é o 2º Mandamento do curso e precisa ser internalizada:

| Objeto | O que é | Para quê | Clonável? |
| --- | --- | --- | :---: |
| **NTAG213/215** | Cartão NFC passivo barato | Keyfile KeePass (Módulo 2B) | ✅ Sim |
| **Smartcard OpenPGP** | Chip criptográfico certificado | Subkeys [S][E][A] `keytocard` | ❌ Não |
| **YubiKey 5 / Nitrokey 3** | Smartcard + FIDO2 + OTP + OpenPGP | Todos os usos acima | ❌ Não |

> 📎 **No curso:** NTAG → [Módulo 2B](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-2b-ntag--keyfile-keepassxc) · Smartcard → [Módulo 2A](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-2a-openpgp-smartcard-keytocard) · Hardware BR → [Apêndice C](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#apêndice-c--hardware-recomendado-brasil--2026)

---

## Capítulo 3

### LIÇÃO #3: CONSTRUA SEU COFRE DIGITAL

> *"Um cofre sem segundo fator é uma porta com uma fechadura."*

#### KeePassXC com segundo fator — 3 estratégias

| Estratégia | Como | Vantagem | Desvantagem |
| --- | --- | --- | --- |
| **Software (simples)** | TOTP dentro do KeePassXC (nativo) | Tudo centralizado | Quem roubar o cofre leva o 2FA junto |
| **Externo (equilibrado)** | Aegis (Android) separado do cofre | Separação de responsabilidades | Depende do celular |
| **Físico (robusto)** | YubiKey/Nitrokey gera OTP para abrir o KeePass | Resistente a roubo digital | Precisa do hardware sempre |

#### Fluxo recomendado (híbrido)

```
Cofre KeePass → protegido por: senha mestra + keyfile (NTAG)
Entradas de serviços → TOTP gerado internamente ou por Aegis
Acesso ao próprio cofre → senha forte + NTAG físico (2B.3)
Backup do cofre → rsync para VM off-site (4.2.3) + HD externo (4.2)
```

#### Checklist de implementação

1. ✅ Ativar keyfile no KeePassXC → [COMANDO 2B.1](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-2b1-gerar-keyfile-no-keepassxc)
2. ✅ Gravar keyfile em 3 NTAGs → [COMANDO 2B.3](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-2b3-gravar-o-mesmo-keyfile-em-3-ntags)
3. ✅ Backup cifrado do keyfile → [COMANDO 2B.2](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-2b2-backup-cifrado-do-keyfile-age--obrigatório-antes-dos-ntags)
4. ✅ Cofre dentro do VeraCrypt → [COMANDO 3.1.1](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-311-criar-volume-veracrypt)
5. ✅ TOTP para serviços → Aegis (Android, F-Droid) ou KeePassXC nativo
6. ✅ Backup off-site dos blobs → [COMANDO 4.2.3](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-423-rsync-só-blobs-com-ou-sem-nfc)

---

# PARTE II — SETUP AVANÇADO

---

## Capítulo 4

### LIÇÃO #4: FORJE SUA PRÓPRIA CHAVE (FRANKENSTEIN KEY)

> *"A chave mais segura é a que você entende completamente."*

> ⚠️ **Aviso:** chaves DIY não têm certificação CC EAL6+ nem aprovação FIDO Alliance. Para uso pessoal e home lab são excelentes; para serviços que exigem certificação, use YubiKey ou Nitrokey.

#### Hardware base

| Componente | Opções | Custo | Para quê |
| --- | --- | --- | --- |
| **Microcontrolador** | Raspberry Pi Pico (RP2040), STM32 Blue Pill | ~R$20–40 | Processa o firmware |
| **Secure Element** | ATECC608A (Microchip) | ~R$15 | Criptografia ECC segura |
| **Secure Element premium** | NXP SE050 | ~R$40 | Certificação CC EAL6+ |
| **Interface** | USB-C, botão físico, LED | ~R$5 | Confirmação de presença |

> 💡 **Por que usar Secure Element?** O microcontrolador sozinho não protege as chaves privadas em memória. O chip dedicado (ATECC608A ou SE050) armazena as chaves de forma que não podem ser lidas — mesmo com acesso físico.

#### Firmware open source — do mais popular ao mais de nicho

| Projeto | GitHub | Protocolos | Status |
| --- | --- | --- | --- |
| **SoloKeys (Solo V2)** | `solokeys/solo` | FIDO2, U2F | ⭐ Mais popular, auditado |
| **Nitrokey Firmware** | `Nitrokey/nitrokey-fido2-firmware` | FIDO2, U2F, PIV, OpenPGP | ⭐⭐ Open source, Europa |
| **OnlyKey Firmware** | `trustcrypto/OnlyKey-Firmware` | FIDO2, U2F, OTP, OpenPGP | ⭐⭐⭐ Flexível, mais complexo |
| **libfido2** | `Yubico/libfido2` | Biblioteca FIDO2 | 🔧 Não é firmware — valide sua chave DIY com isso |
| **OpenPGP Card** | `OpenPGP/openpgp-card` | OpenPGP | 🔵 Nicho acadêmico/gov |

#### Roteiro de implementação em fases

**Fase 1 — Base funcional (SoloKeys + Pico/STM32)**
```sh
# No Linux: instalar dependências
sudo apt install gcc-arm-none-eabi libnewlib-arm-none-eabi cmake
git clone https://github.com/solokeys/solo

# Compilar e gravar no Pico ou STM32 (seguir README do projeto)
# Validar com libfido2:
sudo apt install libfido2-dev fido2-tools
fido2-token -L          # lista dispositivos FIDO2 conectados
fido2-token -I /dev/hidrawX  # info do token
```

**Fase 2 — Adicionar OpenPGP/PIV (firmware Nitrokey)**
- Nitrokey firmware suporta OpenPGP + PIV sobre o mesmo hardware
- Permite `keytocard` como o Módulo 2A do curso

**Fase 3 — PKCS#11 e integração com navegadores**
- Com PKCS#11, sua chave DIY pode assinar documentos e autenticar em sites
- Biblioteca: `opensc` + `pkcs11-provider`

**Fase 4 — PQC experimental**
- Kyber (KEM) e Dilithium (assinatura) já têm implementações para STM32 e RP2040
- Ainda experimental — horizonte ⚫ em 2026

#### Comparativo DIY vs Comerciais

| Aspecto | DIY Frankenstein | YubiKey 5 / Nitrokey 3 |
| --- | --- | --- |
| Custo | US$15–30 (hardware) | US$50–70 |
| Certificação | ❌ Sem CC EAL6+ | ✅ Certificado |
| Flexibilidade | ✅ Total (você escolhe o firmware) | ❌ Limitada ao fabricante |
| Confiabilidade | Depende da sua montagem | ✅ Auditada industrialmente |
| OpenPGP | ✅ Se usar firmware Nitrokey/OnlyKey | ✅ Nativo |
| Compatibilidade | 🟡 Alguns serviços rejeitam não-certificados | ✅ Universal |

> 📎 **Referência:** vídeo DIY key [youtu.be/4IV4vPv1dhI](https://youtu.be/4IV4vPv1dhI)

---

## Capítulo 5

### LIÇÃO #5: EXPANDA OS PROTOCOLOS

> *"Cada protocolo resolve um problema diferente — conhecê-los é saber quando não precisar deles."*

#### O mapa de protocolos

| Protocolo | Para quê | Status |
| --- | --- | --- |
| **OpenPGP** | Criptografia de arquivos, assinaturas, SSH via gpg-agent | 🟢 Este curso |
| **FIDO2/WebAuthn** | Login sem senha em serviços web | 🟢 Externo ao curso |
| **U2F** | Segundo fator em serviços legados | 🟢 Compatível com FIDO2 |
| **PIV** | Smartcard corporativo (cartão de identidade digital) | 🔵 Expert avançado |
| **PKCS#11** | Interface padrão para tokens em browsers/apps | 🔵 Expert avançado |
| **OATH (HOTP/TOTP)** | Senhas descartáveis de 6 dígitos | 🟢 Aegis + KeePassXC |
| **FIDO HID** | Comunicação USB da chave com o browser | 🔵 Só se fazer DIY |
| **PQC híbrido** | Resistência a ataques quânticos | ⚫ Horizonte 2027+ |

#### PKCS#11 — quando você precisa disso

PKCS#11 é a interface que permite usar um token criptográfico em:
- Navegadores (Firefox suporta nativo via `security devices`)
- Assinatura de PDF em LibreOffice
- Autenticação mútua TLS em servidores

```sh
# Instalar OpenSC (implementa PKCS#11 para smartcards)
sudo apt install opensc

# Listar tokens disponíveis
pkcs11-tool --list-slots

# Integrar Firefox: about:preferences → Privacy & Security → Security Devices → Load
# Arquivo: /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so
```

#### PIV — smartcard emulação

PIV (Personal Identity Verification) é um padrão americano para cartões de identidade digital. YubiKey e Nitrokey suportam PIV além de OpenPGP — são protocolos paralelos no mesmo hardware.

```sh
# Interagir com o slot PIV da YubiKey/Nitrokey
sudo apt install yubikey-manager  # ou yubico-piv-tool
ykman piv info
```

#### Fluxo prático em 4 camadas (home lab completo)

```
Camada 1 — Identidade offline:    OpenPGP (master no Tails) ← Este curso
Camada 2 — Identidade online:     FIDO2/WebAuthn (YubiKey/SoloKeys)
Camada 3 — Aplicações corporativas: PIV + PKCS#11 (Firefox, PDF)
Camada 4 — Futuro quântico:       PQC híbrido ⚫ (quando estável)
```

---

## Capítulo 6

### LIÇÃO #6: MANUTENÇÃO PROFISSIONAL

> *"Disciplina é a diferença entre 'funcionou na hora' e 'funciona sempre'."*

#### Frequência de manutenção por tipo de hardware

| Hardware | O que fazer | Frequência |
| --- | --- | --- |
| **Master GPG offline** (Tails) | Renovar expiração das subkeys | A cada 3 anos (ou expiração) |
| **Smartcard oficial** (YubiKey/Nitrokey) | Atualizar firmware se disponível | 1×/ano |
| **Chave DIY** (SoloKeys/Nitrokey firmware) | Atualizar firmware | A cada 6–12 meses |
| **NTAG NFC** (keyfile KeePass) | Verificar leitura + clonar cópia nova | A cada 6–12 meses |
| **Cofres KeePassXC + VeraCrypt** | Verificar abertura + backup do `.kdbx` | Mensal (junto com CHECKPOINT 3) |
| **Backups off-site** | Teste de restore (`sha256sum -c`) | Mensal ([COMANDO 4.3](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-43-teste-de-restauração-ritual-mensal)) |

> 💡 **NTAG NFC não é um chip seguro** — pode desgastar após ~100.000 escritas e pode ser clonado. Por isso o curso exige 3 cópias e backup `age` do keyfile. Um smartcard oficial não precisa dessa rotação.

#### Calendário mínimo de manutenção (versão light)

```
MENSAL (1º dia ou 1º domingo):
  □ ztc-health.sh --check-conf (COMANDO 5.0)
  □ Teste de restauração de um blob (COMANDO 4.3)
  □ Verificar que cron ainda roda (journalctl -u cron)

TRIMESTRAL:
  □ Abrir KeePass com NTAG + confirmar senha mestra
  □ ssh -T git@github.com (confirmar subchave [A] ativa)

ANUAL (1 hora — COMANDO 9.1):
  □ gpg --version + --card-status
  □ Verificar expiração das subkeys (COMANDO 9.2)
  □ Atualizar firmware de tokens DIY
  □ Trocar NTAG se tiver >1 ano de uso intenso
  □ Revisar threat model (COMANDO 7.1)
  □ Revalidar Tails em tails.net/latest
```

---

# PARTE III — GOVERNANÇA HOME LAB

---

## Capítulo 7

### LIÇÃO #7: GOVERNE COMO UMA EMPRESA

> *"Empresas sérias separam quem gera a chave, quem usa e quem audita. Você pode fazer o mesmo."*

#### Papéis e responsabilidades (modelo corporativo pessoal)

| Papel | Quem é você | Responsabilidades |
| --- | --- | --- |
| **Admin / Root** | Você no Tails | Gera master PGP, faz `keytocard`, muda PINs Admin |
| **Usuário / DevOps** | Você no PC diário | Usa subkeys [S][E][A], abre cofre, faz backup |
| **Auditor / SysAdmin** | Você revisando | Roda `ztc-health.sh`, verifica logs, valida backups |
| **Infra** | Seus scripts | `ztc-rsync-offsite.sh`, cron, VM WireGuard |

> 💡 Na prática você é todos os papéis — mas separá-los mentalmente ajuda a manter disciplina. Quando você está no "papel Admin" (Tails offline), age diferente de quando está no papel "Usuário" (PC com internet).

#### Fluxo de processos de governança

```
[Geração de Chave]  →  Tails offline + air-gap (papel Admin)
        ↓
[Distribuição]      →  keytocard → smartcard (Expert)
                        keyfile → 3 NTAGs (Turbo)
        ↓
[Uso Diário]        →  subkeys no PC | NTAG abre cofre
        ↓
[Backup]            →  HD externo + VM off-site (blobs cifrados)
        ↓
[Auditoria]         →  ztc-health.sh + restore mensal
        ↓
[Contingência]      →  Runbook Fases 1–3 + simulação 6.1
```

#### Métricas do cockpit pessoal

Inspirado nos dashboards corporativos — adapte à sua realidade:

| Métrica | Como medir | Frequência |
| --- | --- | --- |
| **Backup recente** | Data do último manifesto `.sha256` | Diária (cron) |
| **Smartcard OK** | `gpg --card-status` sem erro | Semanal |
| **NTAG acessível** | `nfc-list` detecta UID | Ao usar o cofre |
| **SSH funcional** | `ssh -T git@github.com` retorna OK | Semanal |
| **Cofre intacto** | `sha256sum vault.hc` bate com manifesto | Mensal |
| **Subkeys válidas** | `gpg -K` sem `[expired]` | Trimestral |

---

## Capítulo 8

### LIÇÃO #8: PLAYBOOK DE INCIDENTES

> *"Um incidente sem playbook é improviso. Improviso com chave PGP é desastre."*

#### Os 5 passos universais

| # | Passo | Ação | Tempo alvo |
| :---: | --- | --- | --- |
| 1 | **Detectar** | Identificar o problema. O que parou? O que está errado? | 0–5 min |
| 2 | **Isolar** | Desconectar o dispositivo afetado. Não usar até entender. | 0–2 min |
| 3 | **Restaurar** | Usar backup/reserva para retomar operação. | 5–20 min |
| 4 | **Validar** | Testar funcionalidade. Confirmar que está OK. | 2–5 min |
| 5 | **Registrar** | Anotar no log. Atualizar manifesto ou runbook. | 2–5 min |

**Tempo total de resposta esperado: 30 minutos.**

#### Árvore de decisão por tipo de incidente

**🔴 Perda de NTAG #1**
```
→ Usar NTAG #2 ou #3 (cópia idêntica do 2B.3)
→ Abrir KeePass normalmente
→ Gravar NTAG reserva com backup: age -d keepass-keyfile.ztc.age
→ Atualizar ZTC_NFC_UID se trocou o UID
→ Registrar evento
```

**🔴 Falha de Smartcard (cartão não responde)**
```
→ Usar segundo cartão de backup (COMANDO 2A.4)
→ gpg --card-status no segundo cartão
→ Se segundo cartão OK: continuar normalmente
→ Se segundo cartão falhou: ir para Tails + fazer novo keytocard
→ Registrar evento + checar estoque de cartões reserva
```

**🔴 Firmware Comprometido (chave DIY ou atualização falhou)**
```
→ Desconectar a chave (não usar)
→ Reinstalar firmware limpo do repositório oficial
→ Testar funcionamento com fido2-token -L
→ Se dados perdidos: restaurar backup de chaves no Tails
→ Registrar evento
```

**🔴 Backup Inacessível (VM off-site down ou HD externo falhou)**
```
→ Verificar se é falha temporária (VM reiniciar? HD reconectar?)
→ Se permanente: restaurar de outra mídia (3-2-1-1-0 garante cópia alternativa)
→ Criar cópia redundante imediata na mídia funcional
→ Testar restore: sha256sum -c + age -d
→ Registrar evento + rever cadência de backup
```

> 📎 **No curso:** Contingência → [Módulo 6](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-6-plano-de-contingência) · Simulação obrigatória → [COMANDO 6.1](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-61-simulação-de-mesa-obrigatória)

---

## Capítulo 9

### LIÇÃO #9: AUTOMAÇÃO DO COCKPIT

> *"O que não é monitorado, não é gerenciado."*

#### Stack de automação pessoal (home lab corporativo)

```
[Prometheus / InfluxDB]
    Coleta métricas: backup recente, smartcard status, NFC, SSH
        ↓
[Alertmanager]
    Define regras: se backup > 48h → alerta
        ↓ webhook
[Script Bash de Resposta]
    ztc-health.sh → email/notificação → ação automática
        ↓
[Cockpit Visual]
    Dashboard: status atual, alertas ativos, último restore
```

#### Script de health check para cron (expandido)

```sh
#!/bin/sh
# Extensão do ztc-health.sh para home lab monitoring
# Salvar em ~/bin/ztc-cockpit-check.sh

. ~/ztc-backup/ztc.conf 2>/dev/null || { echo "FAIL: ztc.conf ausente"; exit 1; }

echo "=== ZTC Cockpit Check - $(date -Is) ==="

# 1. Backup recente (< 48h)?
LAST=$(ls -t "${ZTC_MANIFEST_DIR:-$HOME/ztc-backup/manifest/}"*.sha256 2>/dev/null | head -1)
if [ -z "$LAST" ]; then
    echo "[WARN] Nenhum manifesto encontrado"
elif [ "$(find "$LAST" -mtime +2 2>/dev/null)" ]; then
    echo "[WARN] Backup mais antigo que 48h: $LAST"
else
    echo "[OK]   Backup recente: $(basename $LAST)"
fi

# 2. Smartcard OK?
if gpg --card-status >/dev/null 2>&1; then
    echo "[OK]   Smartcard detectado"
else
    echo "[WARN] Smartcard ausente ou CCID indisponível"
fi

# 3. SSH funcional?
if ssh -T git@github.com 2>&1 | grep -qF "successfully authenticated"; then
    echo "[OK]   SSH GitHub OK"
else
    echo "[WARN] SSH GitHub falhou — subchave [A] ativa?"
fi

# 4. Volume VeraCrypt existe?
if [ -f "${ZTC_VAULT_HC:-}" ]; then
    echo "[OK]   Vault existe: $ZTC_VAULT_HC"
else
    echo "[WARN] Vault não encontrado: ${ZTC_VAULT_HC:-não configurado}"
fi

echo "=== Fim do check ==="
```

#### Prometheus + InfluxDB para métricas avançadas

Para quem tem home lab com mais de um dispositivo:

```sh
# Instalar Prometheus (Ubuntu/Debian)
sudo apt install prometheus

# Instalar InfluxDB para métricas de longo prazo
wget https://dl.influxdata.com/influxdb/releases/influxdb2_2.7_amd64.deb
sudo dpkg -i influxdb2_2.7_amd64.deb

# Criar um exporter customizado que lê a saída do ztc-health.sh
# e expõe as métricas na porta 9100 para o Prometheus coletar
```

> 💡 Para a maioria dos alunos, o **cron + ztc-health.sh** ([COMANDO 5.2](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-5-automação-e-health-check)) já é suficiente. Prometheus/InfluxDB faz sentido se você tem múltiplos hosts ou quer dashboards históricos.

---

# REFERÊNCIA E NAVEGAÇÃO

---

## Capítulo 10 — Referência Rápida: Vá Direto ao COMANDO

> Encontre o que você precisa pelo **cenário**, não pela ordem do curso.

### 🗺️ Por cenário de uso

**"Quero começar agora — setup inicial completo"**

| Ordem | COMANDO | O que faz |
| --- | --- | --- |
| 1 | [0.1 Terminal e pastas](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-01-terminal-e-pasta-de-trabalho) | Estrutura de diretórios |
| 2 | [0.2–0.3 GnuPG](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-0-preparação-do-ambiente) | Instalar GnuPG e ferramentas |
| 3 | [0.5 Pré-vôo Tails](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-05-pré-vôo-do-tails-no-host-com-internet) | Baixar e verificar o Tails |
| 4 | [1.1 Gravar Tails](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-1-sua-primeira-chave-no-air-gap-tails) | Gravar USB bootável |
| 5 | [1.2 Gerar master+subkeys](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-12-gerar-master--subkeys-offline) | Master PGP no Tails offline |
| 6 | [1.3 Revogação](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-1-sua-primeira-chave-no-air-gap-tails) | Certificado de revogação |
| 7 | [2B.1 Keyfile KeePass](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-2b-ntag--keyfile-keepassxc) | Gerar keyfile |
| 8 | [2B.2 Backup age](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-2b2-backup-cifrado-do-keyfile-age--obrigatório-antes-dos-ntags) | **Obrigatório antes dos NTAGs** |
| 9 | [3.1.1 VeraCrypt](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-311-criar-volume-veracrypt) | Criar volume cifrado |

---

**"Preciso revogar minha chave PGP"**

```
EMERGÊNCIA → Tails offline → gpg --import revogacao.asc
```

| | COMANDO | O que faz |
| --- | --- | --- |
| 1 | [1.3 Gerar revogação](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-1-sua-primeira-chave-no-air-gap-tails) | Criar certificado (no dia da geração) |
| 2 | [6.2 Ensaio lab](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-62-ensaio-de-revogação-em-lab) | Praticar com chave descartável |
| FAQ | [`gpg --verify` falha em revogação?](./FAQ-TROUBLESHOOTING.md) | Usar `--import`, não `--verify` |
| FAQ | [`--gen-revoke` não existe?](./FAQ-TROUBLESHOOTING.md) | Usar `--generate-revocation` |

> ⚠️ Nunca revogue uma chave de produção em lab. Use chave descartável no COMANDO 6.2.

---

**"Perdi meu NTAG / smartcard"**

| Situação | Ação imediata | COMANDO |
| --- | --- | --- |
| **NTAG perdido** | Usar NTAG #2 ou #3 | [2B.3](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-2b-ntag--keyfile-keepassxc) |
| **Todos os NTAGs perdidos** | Restaurar keyfile de `keepass-keyfile.ztc.age` | [2B.2](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-2b2-backup-cifrado-do-keyfile-age--obrigatório-antes-dos-ntags) |
| **Smartcard perdido** | Usar segundo cartão (backup) | [2A.4](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-2a-openpgp-smartcard-keytocard) |
| **Smartcard + backup perdidos** | Tails → novo keytocard do backup master | [Módulo 1](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-1-sua-primeira-chave-no-air-gap-tails) + [2A.2](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-2a-openpgp-smartcard-keytocard) |

---

**"Quero configurar backup off-site"**

| Ordem | COMANDO | O que faz |
| --- | --- | --- |
| 1 | [4.2.1 WireGuard VM](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-42-vm-off-site--wireguard--rsync) | Túnel seguro para VM |
| 2 | [4.2.2 Usuário backup VM](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-42-vm-off-site--wireguard--rsync) | Usuário dedicado na VM |
| 3 | [4.2.3 rsync blobs](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-423-rsync-só-blobs-com-ou-sem-nfc) | Enviar só arquivos cifrados |
| 4 | [5.0 ztc.conf](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-50-validar-ztcconf-antes-dos-scripts) | Validar configuração |
| 5 | [5.2 Cron](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-5-automação-e-health-check) | Automatizar rsync semanal |
| Alt | [G H5a VM local](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#apêndice-g--módulos-h-turbo-híbrido) | VM no próprio PC em vez de VPS |

---

**"Quero SSH via minha chave PGP"**

| Ordem | COMANDO | O que faz |
| --- | --- | --- |
| 1 | [3.2.1 Keygrip](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-32-ssh-via-gpg-agent-subchave-a) | ID da subchave [A] |
| 2 | [3.2.2 sshcontrol](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-32-ssh-via-gpg-agent-subchave-a) | Registrar no agente |
| 3 | [3.2.3 Teste GitHub](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-32-ssh-via-gpg-agent-subchave-a) | `ssh -T git@github.com` |
| WSL2 | [Apêndice D.1](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#apêndice-d--guia-multiplataforma) | SSH via gpg-agent no Windows |

---

**"Quero fazer manutenção anual"**

| Ordem | COMANDO | O que faz |
| --- | --- | --- |
| 1 | [5.0 check-conf](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-50-validar-ztcconf-antes-dos-scripts) | Validar configuração dos scripts |
| 2 | [9.1 Auditoria anual](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-9-manutenção-de-longo-prazo) | Checklist completo em 1h |
| 3 | [9.2 Renovar subkeys](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-9-manutenção-de-longo-prazo) | Tails offline → novo `expire` → `keytocard` |
| 4 | [7.1 Threat model](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-7-threat-modeling-e-opsec) | Rever se seu modelo de ameaça mudou |

---

**"Quero abrir o cofre com NFC automaticamente"**

| Ordem | COMANDO | O que faz |
| --- | --- | --- |
| 1 | [5.0 ztc.conf](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-50-validar-ztcconf-antes-dos-scripts) | Configurar `ZTC_NFC_UID` |
| 2 | [5.3 ztc-open-cofre.sh](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-53-keepass--veracrypt-condicional-nfc-opcional) | Script NFC → VeraCrypt → KeePass |
| FAQ | [NTAG ausente falha?](./FAQ-TROUBLESHOOTING.md) | `ZTC_NFC_UID=""` desabilita NFC guard |

---

### 📋 Índice completo de todos os COMMANDs

| COMANDO | Descrição curta | Módulo |
| --- | --- | --- |
| [0.1](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-0-preparação-do-ambiente) | Terminal e pasta de trabalho | Mód. 0 |
| [0.2–0.3](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-0-preparação-do-ambiente) | GnuPG e ferramentas | Mód. 0 |
| [0.4](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-0-preparação-do-ambiente) | Serviço de cartão (pcscd) | Mód. 0 |
| [0.5](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-05-pré-vôo-do-tails-no-host-com-internet) | Pré-vôo Tails (download + verify) | Mód. 0 |
| [0.6](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-0-preparação-do-ambiente) | Identidade de laboratório | Mód. 0 |
| [0.7–0.8](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-0-preparação-do-ambiente) | Baseline `gpg.conf` + `gpg-agent.conf` | Mód. 0 |
| [0.9](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-0-preparação-do-ambiente) | Celular antigo offline (opcional) | Mód. 0 |
| [1.1](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-1-sua-primeira-chave-no-air-gap-tails) | Gravar e iniciar o Tails | Mód. 1 |
| [1.2](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-12-gerar-master--subkeys-offline) | Gerar master + subkeys **offline** | Mód. 1 |
| [1.3](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-1-sua-primeira-chave-no-air-gap-tails) | Certificado de revogação | Mód. 1 |
| [1.4](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-1-sua-primeira-chave-no-air-gap-tails) | Backup da master (mídia offline) | Mód. 1 |
| [1.5](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-1-sua-primeira-chave-no-air-gap-tails) | Exportar subkeys para o PC | Mód. 1 |
| [1.6](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-1-sua-primeira-chave-no-air-gap-tails) | Checklist shutdown Tails | Mód. 1 |
| [2A.1](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-2a-openpgp-smartcard-keytocard) | Preparar leitor e cartão | Mód. 2A |
| [2A.2](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-2a-openpgp-smartcard-keytocard) | `keytocard` — mover subkeys | Mód. 2A |
| [2A.3](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-2a-openpgp-smartcard-keytocard) | PINs User e Admin | Mód. 2A |
| [2A.4](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-2a-openpgp-smartcard-keytocard) | Segundo cartão (backup físico) | Mód. 2A |
| [2B.1](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-2b-ntag--keyfile-keepassxc) | Gerar keyfile no KeePassXC | Mód. 2B |
| [2B.2](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-2b2-backup-cifrado-do-keyfile-age--obrigatório-antes-dos-ntags) | Backup cifrado do keyfile (`age`) ⚠️ | Mód. 2B |
| [2B.3](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-2b-ntag--keyfile-keepassxc) | Gravar keyfile em 3 NTAGs | Mód. 2B |
| [2B.4](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-2b-ntag--keyfile-keepassxc) | Abrir cofre com senha + keyfile | Mód. 2B |
| [3.1.1](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-311-criar-volume-veracrypt) | Criar volume VeraCrypt | Mód. 3.1 |
| [3.1.2](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-31-keepassxc--veracrypt) | Montar e guardar `.kdbx` | Mód. 3.1 |
| [3.1.3](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-31-keepassxc--veracrypt) | Política de sincronização | Mód. 3.1 |
| [3.2.1](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-32-ssh-via-gpg-agent-subchave-a) | Keygrip da subchave [A] | Mód. 3.2 |
| [3.2.2](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-32-ssh-via-gpg-agent-subchave-a) | `sshcontrol` + gpg-agent | Mód. 3.2 |
| [3.2.3](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-32-ssh-via-gpg-agent-subchave-a) | Chave pública SSH + teste GitHub | Mód. 3.2 |
| [4.1](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-4-backup-3-2-1-1-0-por-ativo) | Inventário e hashes locais | Mód. 4 |
| [4.2](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-4-backup-3-2-1-1-0-por-ativo) | Backup frio no HD externo | Mód. 4 |
| [4.3](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-43-teste-de-restauração-ritual-mensal) | Teste de restauração (ritual mensal) | Mód. 4 |
| [4.2.1](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-42-vm-off-site--wireguard--rsync) | WireGuard na VM (lado servidor) | Mód. 4.2 |
| [4.2.2](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-42-vm-off-site--wireguard--rsync) | Usuário e diretório de backup na VM | Mód. 4.2 |
| [4.2.3](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-42-vm-off-site--wireguard--rsync) | `rsync` só blobs (com ou sem NFC) | Mód. 4.2 |
| [5.0](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-50-validar-ztcconf-antes-dos-scripts) | Validar `ztc.conf` antes dos scripts | Mód. 5 |
| [5.1](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-5-automação-e-health-check) | Script `ztc-health.sh` | Mód. 5 |
| [5.2](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-5-automação-e-health-check) | Cron (backup + health automáticos) | Mód. 5 |
| [5.3](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-53-keepass--veracrypt-condicional-nfc-opcional) | `ztc-open-cofre.sh` — NFC → cofre | Mód. 5 |
| [6.1](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-61-simulação-de-mesa-obrigatória) | Simulação de mesa (obrigatória) | Mód. 6 |
| [6.2](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-62-ensaio-de-revogação-em-lab) | Ensaio de revogação em lab | Mód. 6 |
| [7.1](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-7-threat-modeling-e-opsec) | Seu threat model em uma página | Mód. 7 |
| [8.1](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-8-preparação-pós-quântica-horizonte) | Checklist PQC (sem pânico) | Mód. 8 |
| [9.1](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-9-manutenção-de-longo-prazo) | Auditoria anual (1 hora) | Mód. 9 |
| [9.2](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-9-manutenção-de-longo-prazo) | Expiração e renovação de subkeys | Mód. 9 |

---

## Glossário da Apostila

| Termo | Definição |
| --- | --- |
| **ATECC608A** | Chip seguro da Microchip; armazena chaves ECC de forma não-exportável |
| **CC EAL6+** | Certificação Common Criteria nível 6+ — exigida por serviços corporativos e governos |
| **Cockpit** | Dashboard de monitoramento para seu home lab (métricas, alertas, status) |
| **DIY (Frankenstein Key)** | Chave de segurança montada com hardware barato e firmware open source |
| **FIDO2/WebAuthn** | Padrão de autenticação sem senha para serviços web; antiphishing nativo |
| **FIDO HID** | Protocolo de comunicação USB entre a chave física e o navegador |
| **InfluxDB** | Banco de dados de séries temporais — armazena métricas do cockpit |
| **JCOP Smartcard** | JavaCard com suporte a OpenPGP; alternativa aos tokens comerciais |
| **libfido2** | Biblioteca Yubico para implementar e validar chaves FIDO2 em Linux |
| **NXP SE050** | Chip seguro com certificação CC EAL6+ — uso profissional |
| **OATH (HOTP/TOTP)** | Padrão para senhas descartáveis de 6 dígitos baseadas em tempo ou contador |
| **OpenSC** | Implementação open source de PKCS#11 para smartcards |
| **PIV** | Personal Identity Verification — padrão de smartcard corporativo americano |
| **PKCS#11** | Interface padrão para tokens criptográficos em browsers e aplicativos |
| **Prometheus** | Sistema de monitoramento e alertas; coleta métricas de serviços |
| **RP2040** | Microcontrolador do Raspberry Pi Pico — base comum para chaves DIY |
| **Secure Element** | Chip dedicado que armazena chaves privadas de forma não-exportável |
| **SoloKeys** | Projeto open source de chave FIDO2 DIY — mais popular da categoria |
| **STM32** | Família de microcontroladores ARM; muito usados em projetos de segurança DIY |
| **U2F** | Predecessor do FIDO2; segundo fator físico para serviços web |
| **Webhook** | Chamada HTTP automática disparada por um evento (ex.: alerta do Alertmanager) |

---

## Posfácio

Você terminou a apostila. Ou pulou direto para o que precisava — e isso também é exatamente o propósito.

O Zero Trust Core Expert não é um curso sobre paranoia. É sobre **transformar segurança em rotina** — tão automática quanto fechar a porta ao sair.

Os Capítulos 7–9 desta apostila mostram que o mesmo rigor que empresas sérias aplicam à infraestrutura pode — e deve — ser aplicado à sua identidade digital pessoal. Não porque você é um alvo especial. Mas porque **você é o único responsável pelas suas chaves**.

A master fica offline.  
O resto é subkey e disciplina.  
E se a disciplina existir, a volta de qualquer incidente é mecânica.

**Boa operação.**

---

*Apostila complementar ao curso [Zero Trust Core Expert](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md)*  
*VIPs-com · maio/2026 · [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)*
