# 📖 Apostila Prática — Zero Trust Core Expert

**Versão:** 1.0.3-draft · **VIPs-com** · [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)  
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
| **1997–2005** | OpenPGP (RFC 2440) lançado. Smartcards corporativos adotam suporte. Uso forte em academias, governos e software livre |
| **2006–2015** | YubiKey, Nitrokey, Secalot adicionam OpenPGP. Consolidado em tokens premium |
| **2016–2019** | FIDO U2F ganha suporte em Chrome e Firefox. Empresas adotam U2F para login seguro |
| **2020–2023** | FIDO2/WebAuthn vira padrão global — Windows, macOS, Android, iOS suportam nativamente |
| **2024–2026** | OpenPGP = nicho técnico (pesquisa, governo, entusiastas); passkeys = mainstream |

#### Estratégia híbrida — o melhor dos dois mundos

```
Segredos internos (home lab, SSH, arquivos)  →  OpenPGP
Logins externos (GitHub, Google, serviços)   →  FIDO2/WebAuthn
Camada híbrida (infra corporativa local)     →  Ambos
```

> 📎 **No curso:** OpenPGP → [Módulo 1](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-1-sua-primeira-chave-no-air-gap-tails) · SSH via gpg-agent → [Módulo 3.2](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-32-ssh-via-gpg-agent-subchave-a)

---

## Capítulo 2

### LIÇÃO #2: ESCOLHA SUAS ARMAS (HARDWARE)

> *"A chave certa é a que você vai usar — não a mais cara."*

#### 🏆 Top 20 — Ranking técnico de chaves de segurança (2026)

| Pos | Modelo / Fabricante | País | OpenPGP | FIDO2 | OTP | Interfaces | Preço |
| :---: | --- | --- | :---: | :---: | :---: | --- | --- |
| 1 | **YubiKey 5 Series** | Suécia/EUA | ✅ | ✅ | ✅ | USB-A/C, NFC | US$50–70 |
| 2 | **Nitrokey 3C NFC** 🟢 | Alemanha | ✅ | ✅ | ✅ | USB-C, NFC | US$60–70 |
| 3 | **SoloKeys V2** 🟢 | EUA/EU | ❌ | ✅ | ✅* | USB-C, NFC | US$40–50 |
| 4 | **OnlyKey** | EUA | ✅ | ✅ | ✅ | USB-A/C, display | US$50–60 |
| 5 | **Feitian ePass FIDO2** | China | ❌ | ✅ | ❌ | USB-A/C, NFC | US$25–35 |
| 6 | **Feitian MultiPass** | China | ❌ | ✅ | ✅ | USB-C, NFC, BT | US$35–45 |
| 7 | **Thetis Pro-A** | EUA | ❌ | ✅ | ❌ | USB-A, NFC | US$26–30 |
| 8 | **Winkeo FIDO2** | França | ❌ | ✅ | ❌ | USB-A/C | US$25 |
| 9 | **Google Titan** | EUA | ❌ | ✅ | ❌ | USB-C, NFC, BT | US$40–50 |
| 10 | **Secalot USB Token** 🟢 | Alemanha | ✅ | ✅ | ✅ | USB-A | US$45 |
| 11 | **ChipNet FIDO2** | China | ❌ | ✅ | ❌ | USB-A/C | US$30 |
| 12 | **RSA SecurID** | EUA | ❌ | Proprietário | ✅ | USB, App | US$50–80 |
| 13 | **Key-ID FIDO2** | China | ❌ | ✅ | ✅ | USB-C, NFC | US$30–40 |
| 14 | **TrustKey G310H** | Coreia | ❌ | ✅ | ❌ | USB-C | US$35 |
| 15 | **HyperFIDO Mini** | China | ❌ | ✅ | ❌ | USB-A | US$20–25 |
| 16 | **SecuX FIDO2 Key** | Taiwan | ❌ | ✅ | ✅ | USB-C | US$40 |
| 17 | **Ledger Nano X** *(modo FIDO)* | França | ❌ | ✅ | ✅ | USB-C, BT | US$80 |
| 18 | **Trezor Model T** *(modo FIDO)* | Tchéquia | ❌ | ✅ | ✅ | USB-C | US$70–80 |
| 19 | **AuthenTrend ATKey.Pro** | Taiwan | ❌ | ✅ | ❌ | USB-C, NFC, biometria | US$50 |
| 20 | **Kensington VeriMark Guard** | EUA | ❌ | ✅ | ❌ | USB-A/C, biometria | US$45–55 |

> *SoloKeys suporta OTP via firmware alternativo. 🟢 = open source, firmware auditável.  
> **Chaves com OpenPGP nativo:** apenas posições 1, 2, 4, 10 — quatro opções modernas.

#### Destaque: os 4 com OpenPGP

1. **YubiKey 5 Series** — maior ecossistema, suporte oficial, RSA até 4096 + Ed25519
2. **Nitrokey 3C NFC** — open source, firmware auditável, melhor preço com OpenPGP
3. **OnlyKey** — display físico, PIN local, modos offline; mais complexo de configurar
4. **Secalot USB Token** — nicho europeu; robusto, menor comunidade

#### Qual comprar para este curso?

| Cenário | Recomendação |
| --- | --- |
| **Trilha Expert (OpenPGP obrigatório)** | Nitrokey 3C NFC (open source) ou YubiKey 5 NFC |
| **Trilha Turbo (só cofre + NTAG)** | NTAG213/215 (~R$3–8 cada) — leitor NFC já vem no celular |
| **Orçamento máximo** | YubiKey 5C NFC (US$55) — maior ecossistema e suporte |
| **Orçamento mínimo com OpenPGP** | Nitrokey 3C NFC — menor preço, open source |
| **FIDO2 barato para contas externas** | Thetis Pro-A (~US$28) ou Feitian ePass (~US$30) |
| **Home lab avançado (múltiplos usos)** | YubiKey 5C NFC + NTAG pack (5 unidades) |

#### Opções chinesas — o que vale a pena

Existem projetos prontos no AliExpress/eBay que funcionam sem montagem:

| Projeto pronto | Protocolos | Uso ideal | Aviso |
| --- | --- | --- | --- |
| **STM32 Blue Pill clone** | FIDO2/U2F (firmware SoloKeys) | Login web DIY | Firmware precisa ser gravado |
| **JCOP Smartcard genérico** | OpenPGP, PIV, PKCS#11 | SSH, assinatura | ~US$15–20 no AliExpress |
| **NTAG NFC (213/215/216)** | Keyfile físico | Cofres KeePass/VeraCrypt | Não é chip seguro — clonável |
| **Feitian clone FIDO2/U2F** | FIDO2, U2F, OTP | Login web pronto | Funciona, sem certificação |
| **ATECC608A breakout** | ECC | Chip seguro DIY | Precisa integrar com Pico/STM32 |
| **NXP SE050 dev board** | FIDO2, PIV, PQC | Lab avançado | ~US$15–20, mais complexo |

#### ⚠️ NTAG ≠ Smartcard OpenPGP ≠ YubiKey

Esta distinção é o 2º Mandamento do curso:

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
| **Externo (equilibrado)** | Aegis (Android, F-Droid) separado do cofre | Separação de responsabilidades | Depende do celular |
| **Físico (robusto)** | YubiKey/Nitrokey gera OTP para abrir o KeePass | Resistente a roubo digital | Precisa do hardware sempre |

#### Fluxo recomendado (híbrido)

```
Cofre KeePass → protegido por: senha mestra + keyfile (NTAG)
Entradas de serviços → TOTP gerado internamente ou por Aegis
Acesso ao próprio cofre → senha forte + NTAG físico (2B.3)
Backup do cofre → rsync para VM off-site (4.2.3) + HD externo (4.2)
```

> 💡 **Dica de ouro:** nunca armazene o TOTP do próprio cofre KeePass dentro do cofre KeePass. Isso destrói a separação de fatores. Use Aegis ou YubiKey para proteger o cofre; use o KeePass para guardar os TOTPs de outros serviços.

#### Checklist de implementação

1. ✅ Ativar keyfile no KeePassXC → [COMANDO 2B.1](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-2b1-gerar-keyfile-no-keepassxc)
2. ✅ **Backup cifrado do keyfile ANTES de gravar NTAGs** → [COMANDO 2B.2](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-2b2-backup-cifrado-do-keyfile-age--obrigatório-antes-dos-ntags)
3. ✅ Gravar keyfile em 3 NTAGs idênticos → [COMANDO 2B.3](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-2b3-gravar-o-mesmo-keyfile-em-3-ntags)
4. ✅ Cofre dentro do VeraCrypt → [COMANDO 3.1.1](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-311-criar-volume-veracrypt)
5. ✅ TOTP para serviços → Aegis (Android, F-Droid) ou KeePassXC nativo
6. ✅ Backup off-site dos blobs → [COMANDO 4.2.3](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-423-rsync-só-blobs-com-ou-sem-nfc)

---

# PARTE II — SETUP AVANÇADO

---

## Capítulo 4

### LIÇÃO #4: FORJE SUA PRÓPRIA CHAVE (FRANKENSTEIN KEY)

> *"A chave mais segura é a que você entende completamente."*

> ⚠️ **Aviso de segurança:** chaves DIY não têm certificação CC EAL6+ nem aprovação FIDO Alliance. Para uso pessoal e home lab são excelentes. Para serviços corporativos que exigem certificação (bancos, governo, empresa), use YubiKey ou Nitrokey.

#### Por que montar uma chave DIY?

- **Custo:** US$10–30 vs US$50–70 de uma YubiKey
- **Aprendizado:** entender cada camada do protocolo FIDO2
- **Flexibilidade:** escolher quais protocolos ativar (FIDO2 + OpenPGP + OTP + PQC)
- **Independência:** sem depender de um único fabricante

#### Kits prontos — escolha o seu ponto de entrada

| Kit | Componentes | Protocolos | Custo aprox. | Complexidade | Uso ideal |
| :---: | --- | --- | --- | :---: | --- |
| **Kit 1** | STM32 Blue Pill + SoloKeys | FIDO2, U2F | US$5–10 | ⭐ Fácil | Login web |
| **Kit 2** | Raspberry Pi Pico + ATECC608A | FIDO2, U2F, OTP | US$7–12 | ⭐⭐ Médio | DIY robusto |
| **Kit 3** | JCOP Smartcard genérico | OpenPGP, PIV, PKCS#11 | US$15–20 | ⭐⭐ Médio | SSH + assinatura |
| **Kit 4** | NTAG213/215 (pack 5x) | Keyfile físico | US$5–10 | ⭐ Muito fácil | Cofres locais |
| **Kit 5** | STM32 + NXP SE050 | FIDO2, PIV, OpenPGP, PQC | US$20–30 | ⭐⭐⭐ Avançado | Lab híbrido |

**Caminho sugerido:**
```
Kit 1 → login web seguro (Fase 1)
  + Kit 3 → SSH e assinatura OpenPGP (Fase 2)
    + Kit 4 → cofres com NTAG (Fase 3)
      → Kit 5 → lab avançado com PQC (Fase 4)
```

#### Hardware base — componentes

| Componente | Opções | Custo | Para quê |
| --- | --- | --- | --- |
| **Microcontrolador** | Raspberry Pi Pico (RP2040), STM32 Blue Pill | ~R$20–40 | Processa o firmware FIDO2 |
| **Secure Element** | ATECC608A (Microchip) | ~R$15 | Criptografia ECC não-exportável |
| **Secure Element premium** | NXP SE050 (CC EAL6+) | ~R$40 | PQC e protocolos avançados |
| **Botão físico** | Push button qualquer | ~R$1 | Confirmação de presença (anti-CSRF) |
| **LED** | RGB ou simples | ~R$2 | Status: verde=OK, vermelho=erro |
| **Resistores 220Ω** | Pack | ~R$1 | Proteção do LED |

> 💡 **Por que usar Secure Element?** Sem o chip dedicado (ATECC608A ou SE050), as chaves privadas ficam na memória RAM do microcontrolador — acessíveis com ataque físico. O Secure Element as armazena de forma que não podem ser lidas mesmo com acesso físico.

#### Firmware open source

| Projeto | Repositório GitHub | Protocolos | Qualificação |
| --- | --- | --- | --- |
| **SoloKeys (Solo V2)** | `github.com/solokeys/solo` | FIDO2, U2F | ⭐ Mais popular, auditado |
| **Nitrokey Firmware** | `github.com/Nitrokey/nitrokey-fido2-firmware` | FIDO2, U2F, PIV, OpenPGP | ⭐⭐ Open source, Europa |
| **OnlyKey Firmware** | `github.com/trustcrypto/OnlyKey-Firmware` | FIDO2, U2F, OTP, OpenPGP | ⭐⭐⭐ Flexível, mais complexo |
| **OpenPGP Card** | `github.com/OpenPGP/openpgp-card` | OpenPGP | 🔵 Nicho acadêmico/gov |
| **libfido2** | `github.com/Yubico/libfido2` | Biblioteca FIDO2 | 🔧 Valide sua chave DIY com isso |

> ⚠️ **Sempre compile o firmware direto dos repositórios oficiais.** Nunca use binários de terceiros — eles podem ter backdoors. O `libfido2` é seu validador: se a chave DIY passar em `fido2-token -L`, está funcionando corretamente.

#### Roteiro de implementação em 4 fases

```
[Fase 1] Pico/STM32 + SoloKeys ──→ FIDO2/U2F (login web, GitHub, Google)
[Fase 2] Nitrokey firmware ───────→ OpenPGP/PIV (SSH, assinatura Git)
[Fase 3] KeePassXC + VeraCrypt ───→ OTP + NTAG keyfile (cofres locais)
[Fase 4] STM32 + SE050 + PQC ────→ Pós-quântico experimental
```

**Fase 1 — Base funcional (SoloKeys + Pico/STM32)**
```sh
# Instalar dependências (Ubuntu/Debian)
sudo apt install gcc-arm-none-eabi libnewlib-arm-none-eabi cmake
sudo apt install libfido2-dev fido2-tools

# Clonar e compilar
git clone https://github.com/solokeys/solo
cd solo && make

# Gravar no Raspberry Pi Pico
picotool load firmware.uf2

# Gravar no STM32 Blue Pill (requer ST-Link)
st-flash write firmware.bin 0x8000000

# Validar
fido2-token -L           # lista dispositivos FIDO2 conectados
fido2-token -I /dev/hidrawX  # info do token
# Testar login em github.com → Settings → Security keys
```

**Fase 2 — Adicionar OpenPGP/PIV (firmware Nitrokey)**
```sh
# Firmware Nitrokey suporta OpenPGP + PIV no mesmo hardware
git clone https://github.com/Nitrokey/nitrokey-fido2-firmware
# Seguir README para compilar para STM32
# Depois: gpg --card-status deve reconhecer o dispositivo
```

**Fase 3 — Integrar NTAG como keyfile (já coberto no curso)**
- NTAG213/215 + KeePassXC → [Módulo 2B](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-2b-ntag--keyfile-keepassxc)

**Fase 4 — PQC experimental**
- Kyber (KEM) e Dilithium (assinatura) têm implementações para STM32 e RP2040
- Horizonte ⚫ — não use em produção em 2026

#### Guia de montagem física (checklist)

**Materiais necessários:**
- Ferro de solda (mínimo 25W)
- Estanho eletrônico (60/40 ou sem chumbo)
- Multímetro (para testar continuidade)
- Protoboard para testes
- Fio jumper
- Lupa (opcional, mas útil para soldagem fina)

**Passo a passo:**

1. **Preparar a placa** — fixar na protoboard; soldar header pins no Pico/STM32
2. **Adicionar botão** — conectar entre GPIO e GND (botão de confirmação de login)
3. **Adicionar LED** — GPIO → resistor 220Ω → LED → GND; configurar firmware: verde=pronto, vermelho=erro, azul=processando
4. **Soldar Secure Element (se Kit 2 ou 5)** — ATECC608A ou SE050 via I²C (pinos SDA/SCL)
5. **USB** — Pico já tem micro-USB integrado; STM32 pode precisar de adaptador USB-A/C
6. **Testar antes de fechar** — `fido2-token -L` deve listar o dispositivo

> ⚠️ **Segurança na montagem:** não conecte a chave em PCs que não são seus durante a programação. O firmware não está assinado — um PC comprometido pode substituí-lo.

#### Onde comprar — Brasil e importação

**Brasil (entrega rápida):**
| Componente | Loja | Preço aprox. |
| --- | --- | --- |
| Raspberry Pi Pico (RP2040) | RoboCore (robocore.net) | R$39–79 |
| Raspberry Pi Pico | MakerHero (makerhero.com) | R$39–79 |
| NTAG213/215 (pack 5) | Mercado Livre | R$15–40 |
| STM32 Blue Pill clone | Mercado Livre / importado | R$15–30 |

**Importação (AliExpress — 2–4 semanas):**
| Componente | Preço aprox. |
| --- | --- |
| STM32 Blue Pill clone | US$3–8 |
| ATECC608A breakout board | US$3–5 |
| NXP SE050 dev board | US$15–20 |
| JCOP Smartcard genérico | US$15–20 |
| Feitian FIDO2/U2F clone | US$10–20 |
| Kit NTAG (pack 10) | US$5–10 |

> 💡 **Compra sugerida para começar:** Pico (~R$50) + NTAG pack (~R$20) + JCOP Smartcard (~R$80 importado) = menos de R$200 para Fases 1+2+3 funcionando.

#### Comparativo DIY vs Comerciais

| Aspecto | DIY Frankenstein | YubiKey 5 / Nitrokey 3 |
| --- | --- | --- |
| Custo | US$15–30 (hardware) | US$50–70 |
| Certificação | ❌ Sem CC EAL6+ | ✅ Certificado |
| Flexibilidade | ✅ Total (você escolhe firmware) | ❌ Limitada ao fabricante |
| Confiabilidade | Depende da sua montagem | ✅ Auditada industrialmente |
| OpenPGP | ✅ Com firmware Nitrokey/OnlyKey | ✅ Nativo |
| Compatibilidade | 🟡 Alguns serviços rejeitam | ✅ Universal |

> 📎 **Referência em vídeo:** [youtu.be/4IV4vPv1dhI](https://youtu.be/4IV4vPv1dhI)

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
| **PIV** | Smartcard corporativo (identidade digital) | 🔵 Expert avançado |
| **PKCS#11** | Interface padrão para tokens em browsers/apps | 🔵 Expert avançado |
| **OATH (HOTP/TOTP)** | Senhas descartáveis de 6 dígitos | 🟢 Aegis + KeePassXC |
| **FIDO HID** | Comunicação USB da chave com o browser | 🔵 Só se fazer DIY |
| **PQC híbrido** | Resistência a ataques quânticos | ⚫ Horizonte 2027+ |

#### Guia por serviço — qual método DIY usar onde

| Serviço / Uso | Método DIY | Como chega perto da YubiKey | Limitação |
| --- | --- | --- | --- |
| **Login web** (Google, GitHub, MS) | STM32/Pico + SoloKeys | ✅ Igual — funciona em todos os browsers | Sem certificação oficial |
| **SSH em servidores** | JCOP Smartcard + gpg-agent | ✅ Igual em funcionalidade | Sem auditoria oficial |
| **Cofres locais** (KeePassXC, VeraCrypt) | NTAG NFC como keyfile | ⚠️ Similar — NTAG pode ser clonado | Não substitui chip seguro |
| **Assinatura de arquivos** (Git, docs) | OpenPGP Card em smartcard | ✅ Igual — aceito em academias e gov | Menos popular hoje |
| **OTP** (bancos, serviços antigos) | OnlyKey firmware ou KeePassOTP | ✅ Igual — YubiKey também gera OTP | Se no KeePass perde separação |
| **PQC futuro** | STM32 + SE050 experimental | 🚀 Mais avançado — YubiKey ainda não tem | Experimental, instável |

#### PKCS#11 — quando você precisa

PKCS#11 é a interface que permite usar um token criptográfico em:
- Navegadores (Firefox suporta nativo via `security devices`)
- Assinatura de PDF em LibreOffice
- Autenticação mútua TLS em servidores

```sh
# Instalar OpenSC (implementa PKCS#11 para smartcards)
sudo apt install opensc

# Listar tokens disponíveis
pkcs11-tool --list-slots

# Integrar Firefox:
# about:preferences → Privacy & Security → Security Devices → Load
# Arquivo: /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so
```

#### PIV — smartcard emulação corporativa

PIV (Personal Identity Verification) é padrão americano para cartões de identidade digital. YubiKey e Nitrokey suportam PIV além de OpenPGP — protocolos paralelos no mesmo hardware.

```sh
# Interagir com o slot PIV da YubiKey/Nitrokey
sudo apt install yubikey-manager
ykman piv info

# Para JCOP Smartcard com applet PIV
pkcs11-tool --module /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so --list-objects
```

#### Fluxo prático em 4 camadas (home lab completo)

```
Camada 1 — Identidade offline:       OpenPGP (master no Tails) ← Este curso
Camada 2 — Identidade online:        FIDO2/WebAuthn (YubiKey/SoloKeys)
Camada 3 — Aplicações corporativas:  PIV + PKCS#11 (Firefox, PDF, TLS mútuo)
Camada 4 — Futuro quântico:          PQC híbrido ⚫ (quando estável em 2027+)
```

---

## Capítulo 6

### LIÇÃO #6: MANUTENÇÃO PROFISSIONAL

> *"Disciplina é a diferença entre 'funcionou na hora' e 'funciona sempre'."*

#### 🚨 INSIGHT CRÍTICO: NTAG vs Smartcard — frequência de manutenção é diferente

> **Esta é a diferença que 90% dos alunos não percebe imediatamente:**

| Hardware | Precisa de rotação periódica? | Por quê |
| --- | --- | :--- |
| **NTAG NFC** (keyfile KeePass) | ✅ **SIM** — a cada 6–12 meses | NFC não é chip seguro. Pode desgastar (~100.000 escritas) e **pode ser clonado** se alguém tiver acesso físico |
| **JCOP Smartcard genérico** | ❌ Não — gera chave, usa por anos | Chip criptográfico — chaves não são exportáveis mesmo com acesso físico |
| **YubiKey / Nitrokey** | ❌ Não (só firmware) | Certificado. Chaves permanecem mesmo com acesso físico |
| **STM32/Pico + SoloKeys** | ⚠️ Firmware — a cada 6–12 meses | Não é NTAG — o firmware sim deve ser atualizado |

> 💡 **Resumo:** se você usa NTAG como keyfile do KeePass, precisa trocar a cada 6–12 meses + manter 3 cópias + backup `age`. Se você usa smartcard oficial (JCOP, YubiKey, Nitrokey), a manutenção é mínima — igual ao GPG: gera uma vez, usa por anos.

#### Frequência de manutenção por tipo de hardware

| Hardware | O que fazer | Frequência |
| --- | --- | --- |
| **Master GPG offline** (Tails) | Renovar expiração das subkeys | A cada 3 anos (ou expiração) |
| **Smartcard oficial** (YubiKey/Nitrokey) | Atualizar firmware se disponível | 1×/ano |
| **Chave DIY** (SoloKeys/Nitrokey firmware) | Atualizar firmware | A cada 6–12 meses |
| **NTAG NFC** (keyfile KeePass) | Verificar leitura + clonar cópia nova | A cada 6–12 meses |
| **Cofres KeePassXC + VeraCrypt** | Verificar abertura + backup do `.kdbx` | Mensal |
| **Backups off-site** | Teste de restore (`sha256sum -c`) | Mensal ([COMANDO 4.3](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-43-teste-de-restauração-ritual-mensal)) |

#### Calendário mínimo de manutenção (versão light — HomePro)

```
MENSAL (1º dia ou 1º domingo):
  □ ztc-health.sh --check-conf (COMANDO 5.0)
  □ Teste de restauração de um blob (COMANDO 4.3)
  □ Verificar que cron ainda roda: journalctl | grep cron

TRIMESTRAL:
  □ Testar login web com chave física (FIDO2/SoloKeys)
  □ Testar SSH com smartcard: ssh -T git@github.com
  □ Abrir KeePass com NTAG + confirmar senha mestra
  □ Validar assinaturas Git recentes

SEMESTRAL:
  □ Revisar redundância de backups (HD externo + VM off-site)
  □ Trocar NTAG NFC se em uso intenso (rotação)
  □ Verificar expiração das subkeys PGP: gpg -K

ANUAL (1 hora — COMANDO 9.1):
  □ gpg --version + --card-status
  □ Atualizar firmware: YubiKey Manager ou SoloKeys CLI
  □ Trocar NTAG se tiver >1 ano de uso
  □ Revisar documentação interna (senhas mestres, versões, datas)
  □ Revisar threat model (COMANDO 7.1)
  □ Revalidar Tails em tails.net/latest
```

#### Cronograma de implementação mês a mês (DIY do zero)

Para quem está montando o ecossistema completo pela primeira vez:

| Mês | Fase | Componente | Meta |
| :---: | --- | --- | --- |
| 1 | Login Web (FIDO2/U2F) | STM32/Feitian clone | Login sem senha em Google, GitHub, Microsoft |
| 2 | SSH e Assinaturas (OpenPGP/PIV) | JCOP Smartcard | SSH com smartcard + commits Git assinados |
| 3 | Cofres Locais (KeePassXC + VeraCrypt) | NTAG NFC pack | Cofres só abrem com fator físico + senha |
| 4 | OTP (HOTP/TOTP) | Feitian clone + Aegis | 2FA para bancos e serviços antigos |
| 5 | PQC Experimental | STM32 + SE050 | Laboratório de segurança pós-quântica |

---

# PARTE III — GOVERNANÇA HOME LAB

---

## Capítulo 7

### LIÇÃO #7: GOVERNE COMO UMA EMPRESA

> *"Empresas sérias separam quem gera a chave, quem usa e quem audita. Você pode fazer o mesmo."*

#### Papéis e responsabilidades (modelo corporativo pessoal)

| Papel | Quem é você | Responsabilidades |
| --- | --- | --- |
| **Admin / Root** | Você no Tails | Gera master PGP, faz `keytocard`, muda PINs Admin, cria NTAGs |
| **Usuário / DevOps** | Você no PC diário | Usa subkeys [S][E][A], abre cofre, faz commits, backup |
| **Auditor / SysAdmin** | Você revisando | Roda `ztc-health.sh`, verifica logs, valida backups, health checks |
| **Infra** | Seus scripts | `ztc-rsync-offsite.sh`, cron, VM WireGuard, monitoramento |

> 💡 Na prática você é todos os papéis — mas separá-los mentalmente mantém disciplina. Quando você está "no papel Admin" (Tails offline), age diferente de quando está "no papel Usuário" (PC com internet).

#### Fluxo de processos — ciclo de vida completo

```
[Admin/Root] → Geração de chave (Tails offline, air-gap)
       ↓
[Infra] → Armazenamento físico + backup (HD externo + VM cifrada)
       ↓
[Usuário/DevOps] → Uso diário (login web, SSH, cofres, Git)
       ↓
[Auditor/Compliance] → Auditoria periódica (health check, backups, expiração)
       ↓
[Admin + Auditor] → Revisão/rotação (firmware, NTAG, subkeys)
       ↓
[Todos] → Resposta a incidentes (runbook Fases 1–3)
```

#### 📑 Política de Segurança do Home Lab (versão HomePro)

> Este documento pode ser impresso, salvo no cofre e compartilhado com uma pessoa de confiança para situações de emergência.

---

**§1. Objetivo**

Garantir a segurança, integridade e disponibilidade dos sistemas e chaves digitais do Home Lab, seguindo práticas de ambientes corporativos adaptadas para uso pessoal.

**§2. Escopo**

Aplica-se a todos os componentes do ecossistema:
- STM32/Feitian clones (FIDO2/U2F)
- JCOP Smartcards (OpenPGP/PIV)
- NTAG NFC (keyfiles físicos)
- Cofres KeePassXC/VeraCrypt
- Firmware SoloKeys/JCOP/Feitian
- Backups locais e externos

**§3. Regras de acesso**
- Autenticação obrigatória: todo acesso usa senha + fator físico (chave ou NTAG)
- SSH: somente via smartcard com `gpg-agent`
- Login web: somente via FIDO2/U2F
- Cofres: senha + NTAG obrigatórios

**§4. Manutenção e auditoria**
- Trimestral: health check (login, SSH, cofres, Git)
- Semestral: rotação de NTAGs e revisão de backups
- Anual: atualização de firmware + auditoria completa

**§5. Backups — regra 3-2-1**
- 3 cópias de cada cofre/chave
- 2 mídias diferentes (HD externo + VM off-site)
- 1 cópia fora de casa (off-site)

**§6. Segurança física**
- Smartcards e NTAGs guardados em estojo anti-RFID
- Chaves USB não ficam conectadas permanentemente
- Case protetor para placas DIY (STM32/Pico)

**§7. Documentação interna**
- Manual interno com: senhas mestres, localização de backups, versões de firmware, datas de rotação de NTAGs
- Revisão anual obrigatória

**§8. Incidentes**
- Perda de NTAG: usar reserva imediatamente + gerar novo
- Falha de smartcard: restaurar chave de backup em novo cartão
- Firmware comprometido: reinstalar versão limpa + auditar acessos

---

#### Métricas do cockpit pessoal

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

#### 🚨 Checklist de Resposta Rápida — os 5 passos (meta: 30 minutos)

| # | Passo | Ação concreta | Tempo alvo |
| :---: | --- | --- | --- |
| 1 | **Detectar** | Identificar o problema. O que parou? Verificar sintomas | 0–5 min |
| 2 | **Isolar** | Desconectar dispositivo afetado. Não usar até entender | 0–2 min |
| 3 | **Restaurar** | Usar backup/reserva para retomar operação | 5–20 min |
| 4 | **Validar** | Testar funcionalidade. Confirmar que está OK | 2–5 min |
| 5 | **Registrar** | Anotar no log. Atualizar manifesto ou runbook | 2–5 min |

**Responsável: Admin · Auditoria: Auditor · Revisão: Mensal**

#### Fluxo de decisão — 5 tipos de incidente

```
Problema Detectado
        ↓
   É incidente?
        ↓
   ┌────┴────┬────────────┬──────────────┬──────────────┐
   ↓         ↓            ↓              ↓              ↓
Perda      Falha      Firmware      Backup         Incidente
de NTAG    Smartcard  Comprometido  Inacessível    Físico
   ↓         ↓            ↓              ↓              ↓
Usar       Restaurar   Reinstalar    Usar cópia     Revogar
NTAG       Backup      Firmware      redundante     chaves
Reserva    Chave       Limpo         3-2-1          afetadas
   ↓         ↓            ↓              ↓              ↓
        INCIDENTE RESOLVIDO → OK
```

#### 🔴 Cenário 1 — Perda de NTAG NFC

```
Sintoma: não consegue abrir cofre KeePassXC/VeraCrypt

→ Usar NTAG #2 ou #3 (cópia idêntica do COMANDO 2B.3)
→ Abrir KeePass normalmente com NTAG reserva
→ Se todos os NTAGs perdidos: restaurar keyfile
     age -d ~/ztc-backup/keepass-keyfile.ztc.age
→ Gravar novo NTAG: nfc-tools → gravar keyfile
→ Atualizar ZTC_NFC_UID no ztc.conf se mudou
→ Registrar evento no log
```

> ⚠️ **Nunca fique sem pelo menos 2 NTAGs ativos.** O terceiro é reserva de emergência.

#### 🔴 Cenário 2 — Falha de Smartcard (cartão não responde)

```
Sintoma: PIN não aceita, gpg --card-status falha

→ Usar segundo cartão de backup (COMANDO 2A.4)
→ gpg --card-status no segundo cartão
→ Se segundo cartão OK: continuar normalmente
→ Se segundo cartão falhou também:
     Boot no Tails → restaurar backup master → novo keytocard
→ Registrar substituição + checar estoque de cartões reserva
```

#### 🔴 Cenário 3 — Firmware Comprometido (chave DIY ou atualização falhou)

```
Sintoma: comportamento estranho, login falha, firmware suspeito

→ Desconectar a chave imediatamente (não usar)
→ Reinstalar firmware oficial limpo:
     git clone https://github.com/solokeys/solo
     make && picotool load firmware.uf2
→ Validar: fido2-token -L (deve aparecer o dispositivo)
→ Testar login em GitHub/Google
→ Registrar versão instalada e data
```

#### 🔴 Cenário 4 — Backup Inacessível (VM down ou HD falhou)

```
Sintoma: rsync falha, VM não responde, HD não monta

→ Verificar se é falha temporária:
     ping 10.66.66.1    # WireGuard peer
     wg show            # túnel ativo?
→ Se permanente: restaurar de outra mídia (3-2-1-1-0 garante cópia)
→ Testar restore na cópia funcional:
     sha256sum -c manifesto.sha256
     age -d arquivo.age  # confirma integridade
→ Criar nova cópia redundante na mídia funcional
→ Registrar + rever cadência de backup
```

#### 🔴 Cenário 5 — Incidente Físico (perda ou roubo do dispositivo)

```
Sintoma: chave física, HD ou notebook desapareceu

→ Avaliar o que foi perdido:
     - Só a chave FIDO2: revogar no serviço afetado (Settings → Security Keys)
     - Smartcard: chaves NÃO exportáveis — risco é acesso físico com PIN
     - HD com cofre: vault.hc criptografado → baixo risco se senha forte
     - Notebook com subkeys: revogar subchaves afetadas via Tails

→ Se smartcard ou notebook com subkeys:
     Boot no Tails → usar master offline → revogar/renovar subchaves

→ Substituir por hardware de backup
→ Atualizar inventário físico
→ Registrar incidente + medidas tomadas
→ Rever threat model (COMANDO 7.1)
```

#### Tabela de simulação do cockpit (teste mensal)

| Incidente simulado | Ação para simular | Comportamento esperado | Tempo alvo |
| --- | --- | --- | --- |
| Backup falhou | Remover `/mnt/backup/last.ok` | Alerta "BackupFalhou" dispara | < 5 min |
| Firmware comprometido | Alterar hash em `/etc/firmware.sha256` | Alerta "FirmwareComprometido" | < 5 min |
| NTAG perdido | Desconectar leitor USB NFC | Alerta "NTAGPerdido" | < 5 min |
| Smartcard falhou | Parar serviço `pcscd` | Alerta "SmartcardFalhou" | < 5 min |

> 📎 **No curso:** Contingência → [Módulo 6](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-6-plano-de-contingência) · Simulação obrigatória → [COMANDO 6.1](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-61-simulação-de-mesa-obrigatória)

---

## Capítulo 9

### LIÇÃO #9: AUTOMAÇÃO DO COCKPIT

> *"O que não é monitorado, não é gerenciado."*

#### Visão geral — o cockpit "Home Lab Corporativo"

O cockpit é um painel visual que mostra em tempo real:
- **Governança:** status dos 4 papéis (Admin, Usuário, Auditor, Infra)
- **Segurança:** ciclo de processos (Gerar → Backup → Uso → Auditoria → Revisão → Resposta)
- **Resposta rápida:** 5 botões iluminados (Detectar, Isolar, Restaurar, Validar, Registrar)
- **Playbook:** alertas ativos (NTAG, Smartcard, Firmware, Backup) + Timer SLA + "Incidente Resolvido OK"

Layout widescreen (2560×1080 ideal):
```
┌─────────────────┬──────────────────────┬─────────────────┐
│ 🟦 Governança   │ 🟨 Segurança         │ 🟥 Resp. Rápida │
│ Gauges:         │ Ciclo de processos:  │ 1. DETECTAR     │
│ Admin | Usuário │ Gerar→Backup→Uso     │ 2. ISOLAR       │
│ Auditor | Infra │ Auditoria→Revisão    │ 3. RESTAURAR    │
├─────────────────┴──────────────────────┤ 4. VALIDAR      │
│ 🟩 Playbook                            │ 5. REGISTRAR    │
│ NTAG | Smartcard | Firmware | Backup   │                 │
│ Timer: 00:27:45 · Incidente Resolvido OK               │
└────────────────────────────────────────────────────────┘
```

#### Stack de automação (arquitetura)

```
[Prometheus / InfluxDB]
    Coleta métricas: backup, smartcard status, NFC, SSH, firmware
        ↓ Alerta
[Alertmanager]
    Define regras: se backup > 48h → dispara webhook
        ↓ Webhook HTTP
[Script de Resposta — Bash (Linux) ou PowerShell (Windows)]
    Executa: restore_backup.sh | reinstall_firmware.sh | enable_reserve_token.sh | restart_auth_service.sh
        ↓
[Cockpit Visual — Grafana (web) ou Rainmeter (Windows)]
    Dashboard: status atual, alertas, último restore, timer SLA
```

#### Opção A — Linux: scripts Bash + Prometheus + Grafana

**Estrutura de diretórios:**
```
/usr/local/bin/homelab_metrics/
├── backup.sh          # verifica backup recente
├── firmware.sh        # verifica hash do firmware
├── ntag.sh            # verifica presença do NTAG
├── smartcard.sh       # verifica smartcard
├── sla.sh             # calcula tempo de resposta
└── alert_webhook.sh   # recebe alertas e executa ações

/usr/local/bin/homelab_response/
├── restore_backup.sh        # restaura backup
├── reinstall_firmware.sh    # reinstala firmware limpo
├── enable_reserve_token.sh  # ativa NTAG reserva
└── restart_auth_service.sh  # reinicia autenticação

/var/lib/node_exporter/textfile_collector/
├── backup.prom
├── firmware.prom
├── ntag.prom
└── smartcard.prom
```

**Scripts de monitoramento (textfile collector):**

```bash
#!/bin/bash
# /usr/local/bin/homelab_metrics/backup.sh
# Verifica se backup foi feito nas últimas 48h

BACKUP_FILE="/mnt/backup/last.ok"
METRIC_FILE="/var/lib/node_exporter/textfile_collector/backup.prom"

cat << 'EOF' > "$METRIC_FILE"
# HELP backup_status Status do backup (1=OK, 0=FAIL, 2=WARN)
# TYPE backup_status gauge
EOF

if [ ! -f "$BACKUP_FILE" ]; then
    echo 'backup_status{host="homelab"} 0' >> "$METRIC_FILE"
elif find "$BACKUP_FILE" -mtime +2 | grep -q .; then
    echo 'backup_status{host="homelab"} 2' >> "$METRIC_FILE"
else
    echo 'backup_status{host="homelab"} 1' >> "$METRIC_FILE"
fi
```

```bash
#!/bin/bash
# /usr/local/bin/homelab_metrics/smartcard.sh
# Verifica smartcard OpenPGP

METRIC_FILE="/var/lib/node_exporter/textfile_collector/smartcard.prom"
cat << 'EOF' > "$METRIC_FILE"
# HELP backup_status Status do smartcard (1=OK, 0=FAIL)
# TYPE backup_status gauge
EOF

if gpg --card-status >/dev/null 2>&1; then
    echo 'smartcard_status{host="homelab"} 1' >> "$METRIC_FILE"
else
    echo 'smartcard_status{host="homelab"} 0' >> "$METRIC_FILE"
fi
```

```bash
#!/bin/bash
# /usr/local/bin/homelab_metrics/ntag.sh
# Verifica NTAG NFC

METRIC_FILE="/var/lib/node_exporter/textfile_collector/ntag.prom"
. ~/ztc-backup/ztc.conf 2>/dev/null

if [ -n "${ZTC_NFC_UID:-}" ] && nfc-list 2>/dev/null | grep -qF "$ZTC_NFC_UID"; then
    echo 'ntag_status{host="homelab"} 1' >> "$METRIC_FILE"
else
    echo 'ntag_status{host="homelab"} 0' >> "$METRIC_FILE"
fi
```

```bash
#!/bin/bash
# /usr/local/bin/homelab_metrics/firmware.sh
# Verifica hash do firmware DIY

FIRMWARE_HASH_FILE="/etc/firmware.sha256"
METRIC_FILE="/var/lib/node_exporter/textfile_collector/firmware.prom"

if sha256sum -c "$FIRMWARE_HASH_FILE" >/dev/null 2>&1; then
    echo 'firmware_status{host="homelab"} 1' >> "$METRIC_FILE"
else
    echo 'firmware_status{host="homelab"} 0' >> "$METRIC_FILE"
fi
```

**Ativar Textfile Collector no Prometheus:**
```sh
# /etc/default/prometheus-node-exporter
ARGS="--collector.textfile.directory=/var/lib/node_exporter/textfile_collector/"

# Cron para atualizar métricas a cada 5 minutos
*/5 * * * * root /usr/local/bin/homelab_metrics/backup.sh
*/5 * * * * root /usr/local/bin/homelab_metrics/smartcard.sh
*/5 * * * * root /usr/local/bin/homelab_metrics/ntag.sh
*/5 * * * * root /usr/local/bin/homelab_metrics/firmware.sh
```

**Alertmanager — regras de alerta:**
```yaml
# /etc/prometheus/alerts.yml
groups:
  - name: homelab
    rules:
      - alert: BackupFalhou
        expr: backup_status{host="homelab"} == 0
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Backup não encontrado"

      - alert: SmartcardFalhou
        expr: smartcard_status{host="homelab"} == 0
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "Smartcard não detectado"

      - alert: NTAGPerdido
        expr: ntag_status{host="homelab"} == 0
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "NTAG NFC não detectado"

      - alert: FirmwareComprometido
        expr: firmware_status{host="homelab"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Hash do firmware não confere"
```

**Alertmanager webhook — servidor de resposta automática:**
```yaml
# /etc/alertmanager/alertmanager.yml
route:
  receiver: homelab-webhook
receivers:
  - name: homelab-webhook
    webhook_configs:
      - url: http://localhost:9095/alert
```

```bash
#!/bin/bash
# /usr/local/bin/homelab_response/alert_webhook.sh
# Servidor webhook simples (rodar com: nc -lkp 9095 -e this_script)

read -r ALERT_JSON

ALERT_NAME=$(echo "$ALERT_JSON" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['alerts'][0]['labels']['alertname'])" 2>/dev/null)

case "$ALERT_NAME" in
    BackupFalhou)        /usr/local/bin/homelab_response/restore_backup.sh ;;
    FirmwareComprometido) /usr/local/bin/homelab_response/reinstall_firmware.sh ;;
    NTAGPerdido)         /usr/local/bin/homelab_response/enable_reserve_token.sh ;;
    SmartcardFalhou)     /usr/local/bin/homelab_response/restart_auth_service.sh ;;
esac

echo "$(date -Is) - Alerta $ALERT_NAME processado" >> /var/log/incident.log
```

```bash
#!/bin/bash
# /usr/local/bin/homelab_response/restore_backup.sh
rsync -av "$ZTC_REMOTE" ~/ztc-backup/restore/ 2>> /var/log/incident.log
echo "$(date -Is) - Backup restaurado" >> /var/log/incident.log
```

```bash
#!/bin/bash
# /usr/local/bin/homelab_response/reinstall_firmware.sh
echo "$(date -Is) - AÇÃO MANUAL NECESSÁRIA: reinstalar firmware em $(hostname)" >> /var/log/incident.log
# Envia notificação (ex: via mail ou telegram bot)
```

```bash
#!/bin/bash
# /usr/local/bin/homelab_response/enable_reserve_token.sh
# Ativar NTAG reserva — registra que deve ser físicamente substituído
echo "$(date -Is) - NTAG reserva ativado — substituir NTAG principal" >> /var/log/incident.log
```

```bash
#!/bin/bash
# /usr/local/bin/homelab_response/restart_auth_service.sh
systemctl restart pcscd 2>/dev/null
echo "$(date -Is) - pcscd reiniciado" >> /var/log/incident.log
```

#### Grafana — dashboard JSON (importar diretamente)

```json
{
  "dashboard": {
    "id": null,
    "title": "Home Lab Corporativo Cockpit",
    "tags": ["homelab", "security"],
    "panels": [
      {"type": "gauge", "title": "Admin", "gridPos": {"x": 0, "y": 0, "w": 3, "h": 4},
       "targets": [{"expr": "backup_status{host='homelab'}"}],
       "fieldConfig": {"defaults": {"thresholds": {"steps": [
         {"color": "red", "value": 0}, {"color": "yellow", "value": 2}, {"color": "green", "value": 1}
       ]}}}},
      {"type": "gauge", "title": "Backup", "gridPos": {"x": 3, "y": 0, "w": 3, "h": 4},
       "targets": [{"expr": "backup_status{host='homelab'}"}]},
      {"type": "gauge", "title": "Smartcard", "gridPos": {"x": 6, "y": 0, "w": 3, "h": 4},
       "targets": [{"expr": "smartcard_status{host='homelab'}"}]},
      {"type": "gauge", "title": "NTAG", "gridPos": {"x": 9, "y": 0, "w": 3, "h": 4},
       "targets": [{"expr": "ntag_status{host='homelab'}"}]},
      {"type": "gauge", "title": "Firmware", "gridPos": {"x": 12, "y": 0, "w": 3, "h": 4},
       "targets": [{"expr": "firmware_status{host='homelab'}"}]},
      {"type": "stat", "title": "1. DETECTAR", "gridPos": {"x": 15, "y": 0, "w": 2, "h": 2},
       "targets": [{"expr": "backup_status + smartcard_status + ntag_status + firmware_status"}]},
      {"type": "stat", "title": "2. ISOLAR", "gridPos": {"x": 17, "y": 0, "w": 2, "h": 2},
       "targets": [{"expr": "1"}]},
      {"type": "stat", "title": "3. RESTAURAR", "gridPos": {"x": 15, "y": 2, "w": 2, "h": 2},
       "targets": [{"expr": "1"}]},
      {"type": "stat", "title": "4. VALIDAR", "gridPos": {"x": 17, "y": 2, "w": 2, "h": 2},
       "targets": [{"expr": "1"}]},
      {"type": "alertlist", "title": "Playbook de Incidentes", "gridPos": {"x": 0, "y": 4, "w": 15, "h": 4}},
      {"type": "stat", "title": "Timer SLA", "gridPos": {"x": 15, "y": 4, "w": 2, "h": 2},
       "targets": [{"expr": "time() - backup_status_timestamp"}]},
      {"type": "stat", "title": "Incidente Resolvido", "gridPos": {"x": 17, "y": 4, "w": 2, "h": 2},
       "targets": [{"expr": "backup_status * smartcard_status * ntag_status * firmware_status"}]}
    ]
  },
  "overwrite": true
}
```

**Como importar:**
1. Abrir Grafana → Dashboards → Import
2. Colar o JSON acima
3. Ajustar os `expr` para suas métricas reais
4. Configurar thresholds (verde=1, amarelo=2, vermelho=0)

#### Opção B — Windows: PowerShell + Rainmeter

Para alunos com PC principal Windows que não têm Linux rodando:

**Estrutura de diretórios:**
```
C:\HomeLabCockpit\
├── scripts\
│   ├── monitor_backup.ps1
│   ├── monitor_firmware.ps1
│   ├── monitor_ntag.ps1
│   ├── monitor_smartcard.ps1
│   └── update_dashboard.ps1
├── logs\
│   ├── backup.log
│   ├── firmware.log
│   ├── ntag.log
│   ├── smartcard.log
│   └── dashboard.log
└── dashboard.ini       ← configuração Rainmeter
```

**Script principal (update_dashboard.ps1):**
```powershell
# Caminhos dos logs
$logs = @{
    "Backup"    = "C:\HomeLabCockpit\logs\backup.log"
    "Firmware"  = "C:\HomeLabCockpit\logs\firmware.log"
    "NTAG"      = "C:\HomeLabCockpit\logs\ntag.log"
    "Smartcard" = "C:\HomeLabCockpit\logs\smartcard.log"
}

# Lê última linha do log e retorna cor
function Get-Status($logPath) {
    if (Test-Path $logPath) {
        $content = Get-Content $logPath -Tail 1
        if ($content -match "OK")   { return "green"  }
        elseif ($content -match "WARN") { return "yellow" }
        else { return "red" }
    }
    return "gray"
}

# Atualiza dashboard
foreach ($key in $logs.Keys) {
    $status = Get-Status $logs[$key]
    Add-Content "C:\HomeLabCockpit\logs\dashboard.log" "$key=$status"
}
```

**Scripts de resposta rápida (PowerShell):**
```powershell
# Detectar
ping 8.8.8.8 | Out-File "C:\HomeLabCockpit\logs\detect.log"

# Isolar (desconectar adaptador de rede)
Disable-NetAdapter -Name "Ethernet" -Confirm:$false

# Restaurar (rsync via WSL ou robocopy)
robocopy "D:\Backup" "C:\Sistema" /MIR | Out-File "C:\HomeLabCockpit\logs\restore.log"

# Registrar
Add-Content "C:\HomeLabCockpit\logs\dashboard.log" "$(Get-Date) - Incidente Resolvido → OK"
```

**Automação com agendador:**
```powershell
# Agendar update a cada 5 minutos
schtasks /create /tn "UpdateCockpit" /tr "powershell.exe C:\HomeLabCockpit\scripts\update_dashboard.ps1" /sc minute /mo 5
```

**Rainmeter dashboard.ini (gauges):**
```ini
[Variables]
BackupStatus=green
FirmwareStatus=yellow
NTAGStatus=red
SmartcardStatus=green

[MeterBackup]
Meter=Roundline
LineColor=#BackupStatus#
LineStart=0
LineEnd=360
Radius=50
X=10
Y=10

[MeterFirmware]
Meter=Roundline
LineColor=#FirmwareStatus#
Radius=50
X=120
Y=10
```

#### Playbook de Teste do Cockpit — 5 fases (mensal)

**Fase 1 — Preparação**
1. Verificar serviços: `systemctl status prometheus node_exporter alertmanager`
2. Confirmar scripts em `/usr/local/bin/homelab_metrics/` com `chmod +x *.sh`
3. Validar que arquivos `.prom` estão sendo atualizados em `/var/lib/node_exporter/textfile_collector/`

**Fase 2 — Simulação de incidentes**
*(ver tabela na seção do Capítulo 8)*

**Fase 3 — Resposta automática**
1. Alertmanager envia webhook para `alert_webhook.sh`
2. Script executa ação correspondente
3. Cada script atualiza o `.prom` e registra no log

**Fase 4 — Validação**
1. Verificar se gauges voltaram para verde no Grafana
2. Confirmar que painel mostra "Incidente Resolvido → OK"
3. Checar tempo de resposta no SLA Timer
4. Revisar logs: `tail -f /var/log/incident.log`

**Fase 5 — Auditoria e registro**
1. Exportar histórico de alertas do Prometheus
2. Gerar relatório de incidentes (Grafana CSV export)
3. Atualizar runbook com tempos médios + melhorias

---

# REFERÊNCIA E NAVEGAÇÃO

---

## Capítulo 10 — Referência Rápida: Vá Direto ao COMANDO

> Encontre o que você precisa pelo **cenário**, não pela ordem do curso.

### 🗺️ Por cenário de uso

---

**"Quero começar agora — setup inicial completo"**

| Ordem | COMANDO | O que faz |
| --- | --- | --- |
| 1 | [0.1 Terminal e pastas](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-0-preparação-do-ambiente) | Estrutura de diretórios |
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
EMERGÊNCIA → Tails offline → gpg --import revogacao.asc → gpg --send-keys
```

| | COMANDO | O que faz |
| --- | --- | --- |
| 1 | [1.3 Gerar revogação](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-1-sua-primeira-chave-no-air-gap-tails) | Criar certificado (no dia da geração) |
| 2 | [6.2 Ensaio lab](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-62-ensaio-de-revogação-em-lab) | Praticar com chave descartável |
| FAQ | [`gpg --verify` falha em revogação?](./FAQ-TROUBLESHOOTING.md) | Usar `--import`, não `--verify` |
| FAQ | [`--gen-revoke` não existe?](./FAQ-TROUBLESHOOTING.md) | Usar `--generate-revocation` |

> ⚠️ Nunca revogue uma chave de produção em lab. Use chave descartável no [COMANDO 6.2](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-62-ensaio-de-revogação-em-lab).

---

**"Perdi meu NTAG / smartcard"**

| Situação | Ação imediata | COMANDO |
| --- | --- | --- |
| **NTAG #1 perdido** | Usar NTAG #2 ou #3 | [2B.3](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-2b-ntag--keyfile-keepassxc) |
| **Todos os NTAGs perdidos** | Restaurar keyfile de `keepass-keyfile.ztc.age` | [2B.2](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-2b2-backup-cifrado-do-keyfile-age--obrigatório-antes-dos-ntags) |
| **Smartcard perdido** | Usar segundo cartão (backup) | [2A.4](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-2a-openpgp-smartcard-keytocard) |
| **Smartcard + backup perdidos** | Tails → novo keytocard do backup master | [Módulo 1](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-1-sua-primeira-chave-no-air-gap-tails) + [2A.2](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-2a-openpgp-smartcard-keytocard) |
| **Dispositivo físico roubado** | Ver Cenário 5 do Capítulo 8 | [6.1 Simulação](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-61-simulação-de-mesa-obrigatória) |

---

**"Quero configurar backup off-site"**

| Ordem | COMANDO | O que faz |
| --- | --- | --- |
| 1 | [4.2.1 WireGuard VM](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-42-vm-off-site--wireguard--rsync) | Túnel seguro para VM |
| 2 | [4.2.2 Usuário backup VM](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-42-vm-off-site--wireguard--rsync) | Usuário dedicado na VM |
| 3 | [4.2.3 rsync blobs](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-423-rsync-só-blobs-com-ou-sem-nfc) | Enviar só arquivos cifrados |
| 4 | [5.0 ztc.conf](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-50-validar-ztcconf-antes-dos-scripts) | Validar configuração |
| 5 | [5.2 Cron](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-5-automação-e-health-check) | Automatizar rsync semanal |
| Alt | [G H5a VM local](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#apêndice-g--módulos-h-turbo-híbrido) | VM no PC em vez de VPS |

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
| 4 | [7.1 Threat model](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-módulo-7-threat-modeling-e-opsec) | Rever modelo de ameaça |

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
| **Alertmanager** | Componente do Prometheus que gerencia alertas e dispara webhooks |
| **CC EAL6+** | Certificação Common Criteria nível 6+ — exigida por serviços corporativos e governos |
| **Cockpit** | Dashboard de monitoramento para seu home lab (métricas, alertas, status) |
| **DIY (Frankenstein Key)** | Chave de segurança montada com hardware barato e firmware open source |
| **FIDO2/WebAuthn** | Padrão de autenticação sem senha para serviços web; antiphishing nativo |
| **FIDO HID** | Protocolo de comunicação USB entre a chave física e o navegador |
| **Grafana** | Plataforma de dashboards web — visualiza métricas do Prometheus/InfluxDB |
| **InfluxDB** | Banco de dados de séries temporais — armazena métricas do cockpit |
| **JCOP Smartcard** | JavaCard com suporte a OpenPGP; alternativa aos tokens comerciais |
| **libfido2** | Biblioteca Yubico para implementar e validar chaves FIDO2 em Linux |
| **Node Exporter** | Agente Prometheus que expõe métricas do sistema Linux |
| **NXP SE050** | Chip seguro com certificação CC EAL6+ — uso profissional |
| **OATH (HOTP/TOTP)** | Padrão para senhas descartáveis de 6 dígitos baseadas em tempo ou contador |
| **OpenSC** | Implementação open source de PKCS#11 para smartcards |
| **PIV** | Personal Identity Verification — padrão de smartcard corporativo americano |
| **PKCS#11** | Interface padrão para tokens criptográficos em browsers e aplicativos |
| **Prometheus** | Sistema de monitoramento e alertas; coleta métricas via exporters |
| **Rainmeter** | Engine de dashboards desktop para Windows — cria cockpit local |
| **RP2040** | Microcontrolador do Raspberry Pi Pico — base para chaves DIY |
| **Secure Element** | Chip dedicado que armazena chaves privadas de forma não-exportável |
| **SoloKeys** | Projeto open source de chave FIDO2 DIY — mais popular da categoria |
| **STM32** | Família de microcontroladores ARM; base de projetos de segurança DIY |
| **Textfile Collector** | Módulo do Node Exporter que lê arquivos `.prom` e os expõe ao Prometheus |
| **U2F** | Predecessor do FIDO2; segundo fator físico para serviços web |
| **Webhook** | Chamada HTTP automática disparada por evento (ex.: alerta do Alertmanager) |

---

## Posfácio

Você terminou a apostila. Ou pulou direto para o que precisava — e isso também é exatamente o propósito.

O Zero Trust Core Expert não é um curso sobre paranoia. É sobre **transformar segurança em rotina** — tão automática quanto fechar a porta ao sair.

Os Capítulos 7–9 desta apostila mostram que o mesmo rigor que empresas sérias aplicam à infraestrutura pode — e deve — ser aplicado à sua identidade digital pessoal. Não porque você é um alvo especial. Mas porque **você é o único responsável pelas suas chaves**.

Os insights que mais importam desta apostila:

1. **NTAG e smartcard são tecnologias diferentes** — um pode ser clonado, o outro não. Saiba qual você está usando.
2. **Frankenstein Key tem valor real** — não como substituto para ambientes críticos, mas como ferramenta de aprendizado e home lab a custo zero.
3. **Governança pessoal funciona** — separar Admin / Usuário / Auditor mentalmente muda a qualidade das suas decisões de segurança.
4. **Playbook antes do incidente** — você não escreve o runbook durante o incêndio.
5. **Cockpit não é luxo** — é visibilidade. O que não é monitorado, falha silenciosamente.

A master fica offline.  
O resto é subkey e disciplina.  
E se a disciplina existir, a volta de qualquer incidente é mecânica.

**Boa operação.**

---

*Apostila complementar ao curso [Zero Trust Core Expert](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md)*  
*VIPs-com · maio/2026 · [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)*
