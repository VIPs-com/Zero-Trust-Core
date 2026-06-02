# 💾 Backup resiliente, off-site e Kit de Sobrevivência Digital

**Onde guardar as cópias, com que custo e energia, como torná-las imutáveis (à prova de ransomware), e o arsenal de mídias.** · [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)

> Companheiro prático do [Manual dos Três Mundos](GUIA-DO-USUARIO-TRES-MUNDOS.md) e da Parte 3 do curso.
> Responde: *"VM/VPS não custa caro e energia? Como faço o off-site sem gastar à toa? E o backup do Whonix?"*

---

## Sumário
- [1. Onde fica o off-site? (custo × energia × imutabilidade)](#1-onde-fica-o-off-site-custo--energia--imutabilidade)
- [2. Borg na máquina off-site — passo a passo](#2-borg-na-máquina-off-site--passo-a-passo)
- [3. Backup do Whonix (bare-metal × VM)](#3-backup-do-whonix-bare-metal--vm)
- [4. Kit de Sobrevivência Digital (o arsenal de mídias)](#4-kit-de-sobrevivência-digital-o-arsenal-de-mídias)
- [5. Quantas camadas? (anti-bloat)](#5-quantas-camadas-anti-bloat)

---

## 1. Onde fica o off-site? (custo × energia × imutabilidade)

> 🔑 **O ponto que resolve sua dúvida:** a **máquina onde você trabalha** (seu Whonix/Debian diário)
> **não é** a máquina de backup off-site. São coisas separadas. O off-site é só um **lugar para receber
> blobs cifrados** — e ele **não precisa ficar ligado 24/7**. O `borg` roda **sob demanda**: o destino
> só precisa estar acessível **no momento do sync** (minutos por semana).

| Opção off-site | Custo recorrente | Energia | Imutável? | Para quem |
|----------------|------------------|---------|:---------:|-----------|
| **HD externo frio** (desligado) | R$ 0 (compra única) | **zero** | ✅ por estar offline | Todo mundo — a base |
| **CD/DVD / M-DISC** | R$ 0 (mídia barata) | **zero** | ✅ WORM (grava 1×) | Cópia imutável de blobs pequenos |
| **Raspberry Pi / mini-PC** (borg) | R$ 0/mês | ~3–10 W (≈ **R$ 3–6/mês**) | ✅ borg append-only | Quem quer off-site automatizado barato |
| **NAS caseiro** (borg/ZFS) | R$ 0/mês | ~20–60 W (≈ R$ 15–40/mês) | ✅ append-only / snapshots | Quem já tem NAS |
| **VPS** (borg) | ~R$ 20–40/mês | zero (é deles) | ✅ borg append-only | Quem não quer hardware/energia em casa |

**Recomendação por perfil (não precisa de tudo):**

- 🥇 **Começo certo e barato:** **HD frio + CD/DVD**. Zero energia, zero conta mensal, imutável por estar
  offline/WORM. Manual (você pluga uma vez por mês) — mas é a base que **nunca falha por falta de luz**.
- 🥈 **Off-site automatizado sem conta mensal:** **Raspberry Pi** com `borg`. ~5 W ≈ centavos por dia.
  Pode até ficar **desligado** e você liga só para o backup (ou Wake-on-LAN).
- 🥉 **Zero manutenção de hardware em casa:** **VPS** com `borg` (a energia/uptime é problema do provedor).
  Troca dinheiro por conveniência. Lembre da [regra de ouro](GUIA-DO-USUARIO-TRES-MUNDOS.md): a VPS só
  recebe **blobs já cifrados**, nunca keyfile/PIN/master.

> 💡 **A VM "cara de energia" é um mito quando bem desenhada:** você não mantém uma VM ligada para o
> backup. Mantém um destino **leve** (Pi/cold HD/VPS) e dispara o `borg` quando quiser. O HD frio é
> literalmente **0 W**.

---

## 2. Borg na máquina off-site — passo a passo

O [`ztc-borg-offsite.sh`](../scripts/ztc-borg-offsite.sh) é o lado **cliente**. Aqui está o lado
**servidor** (Pi/VPS/NAS) — o setup extra que torna o repositório **append-only** (imutável):

### 2.1 — No servidor (uma vez)

```sh
# Conta dedicada só para backup (já existe no curso: ztc-bkp)
sudo adduser --disabled-password ztc-bkp
sudo apt install borgbackup

# Diretório do repositório
sudo -u ztc-bkp mkdir -p /home/ztc-bkp/borg-ztc
```

Edite `~ztc-bkp/.ssh/authorized_keys` e **prefixe** a chave pública do cliente com restrições — esta é
a linha que torna a chave **incapaz de apagar** (mesmo princípio do `command="rrsync"` do rsync, A1):

```
command="borg serve --append-only --restrict-to-path /home/ztc-bkp/borg-ztc",restrict ssh-ed25519 AAAA...sua-chave... ztc-borg
```

- `--append-only` → o cliente só **adiciona**; não apaga nem sobrescreve. **Anti-ransomware.**
- `--restrict-to-path` → a chave só enxerga o repo, nada mais.
- `restrict` → desliga port-forwarding, PTY, agente, etc. (SSH só serve borg).

### 2.2 — No cliente (uma vez)

```sh
sudo apt install borgbackup
export BORG_RSH="ssh -i ~/.ssh/ztc-bkp-ed25519 -o StrictHostKeyChecking=yes"

# Inicializa o repo. Escolha a cifra:
#  repokey-blake2  → chave guardada no repo (protegida por passphrase). Simples.
#  keyfile-blake2  → chave NO CLIENTE (não no servidor) — melhor se NÃO confia no servidor,
#                    mas você PRECISA fazer backup da chave exportada (senão perde tudo).
borg init --encryption=repokey-blake2 "ssh://ztc-bkp@10.66.66.1/~/borg-ztc"
```

> 🔴 **GUARDE A PASSPHRASE DO REPO NO KeePassXC.** Sem ela, o backup é **irrecuperável**. Como o
> `vault.hc` já é um blob VeraCrypt, mesmo um servidor comprometido só veria dados **já cifrados** —
> o `repokey` é uma segunda camada, não a única.

### 2.3 — No cliente (toda vez — ou via cron)

```sh
# Edite ~/ztc-backup/ztc.conf:  ZTC_BORG_REPO="ssh://ztc-bkp@10.66.66.1/~/borg-ztc"
~/bin/ztc-borg-offsite.sh
```

Para **cron** (não-interativo), defina `BORG_PASSCOMMAND` (ex.: ler a passphrase do KeePassXC via
`keepassxc-cli`/`secret-tool`) — **nunca** escreva a passphrase no `ztc.conf`.

### 2.4 — Retenção (rotação) — roda no SERVIDOR, não no cliente

Em append-only, o cliente **não apaga** (é o ponto). Quem recupera espaço é um job no **servidor**,
periodicamente, **fora** do modo append-only (ex.: cron mensal na conta admin do servidor):

```sh
borg prune --keep-daily=7 --keep-weekly=8 --keep-monthly=12 /home/ztc-bkp/borg-ztc
borg compact /home/ztc-bkp/borg-ztc
```

### 2.5 — Testar o restore (a "0 erros" também aqui)

```sh
borg list "ssh://ztc-bkp@10.66.66.1/~/borg-ztc"          # ver versões
borg extract "ssh://ztc-bkp@10.66.66.1/~/borg-ztc::vault-20260601-030000"  # restaura
# ou montar para inspecionar:
borg mount "ssh://ztc-bkp@10.66.66.1/~/borg-ztc::vault-..." /mnt/borg && ls /mnt/borg
```

> Depois de extrair o `vault.hc`, rode o [`ztc-restore-test.sh`](../scripts/ztc-restore-test.sh) nele —
> backup que não se testa **não é** backup.

---

## 3. Backup do Whonix (bare-metal × VM)

> 🔑 **A verdade que tira o peso da sua dúvida:** **não trate o Whonix como cofre de segredos.** A
> master vive **offline no Tails**; o Whonix só tem **subkeys descartáveis** (e dados públicos, como a
> xpub watch-only). Se o Whonix morrer, você **recria do Tails** — não perde nada crítico. Então
> "backup do Whonix" é sobre **conveniência** (não reconfigurar), não sobre **resiliência de segredo**.

| Modo | Como rodar | Como fazer backup | Trade-off |
|------|-----------|-------------------|-----------|
| **VM** (recomendado) | Gateway+Workstation em VirtualBox/KVM, ou **Qubes-Whonix** | **Snapshot/clone da VM no host**: VirtualBox → exportar `.ova`; KVM → copiar o `.qcow2`; Qubes → `qvm-backup` | Backup trivial (1 arquivo); isolamento do hypervisor; gasta RAM/disco |
| **Bare-metal** | Whonix-Host instalado direto na máquina | Imagem do disco (Clonezilla) **ou** backup dos arquivos de config | Menos overhead, mas o host **é** o Whonix → backup vira backup de SO inteiro; perde o isolamento do hypervisor |

**Recomendações:**

- A maioria deve usar **VM** — o snapshot é um arquivo, e o isolamento Gateway↔Workstation↔host é mais forte (máximo no **Qubes-Whonix**).
- Faça um snapshot da Workstation **depois de configurar** (subkeys importadas, apps prontos). Repita só quando mudar a config — não é backup diário.
- **Bare-metal** só se hardware fraco não aguenta VMs **e** você aceita o trade-off. Aí o backup é uma imagem de disco ocasional.
- Em **todos os casos**: as subkeys e a xpub têm origem no **Tails air-gap** — esse é o backup que importa, e ele é coberto pelo seu 3-2-1-1-0 + `borg`. O Whonix é descartável por design.

> ⚡ **Energia (sua dúvida):** a máquina Whonix gasta energia **enquanto você trabalha** — é o seu PC
> de uso, não um servidor 24/7. Não confunda com o **destino de backup** (§1), esse sim pode/deve ser
> leve (Pi/cold HD/VPS) e ligado só no sync.

---

## 4. Kit de Sobrevivência Digital (o arsenal de mídias)

Cada mídia tem uma propriedade. Combine **poucas** delas conforme o papel no 3-2-1-1-0 — não use todas.

```
                🛡️  "Não existe bala de prata — só rotina de aço"

   🔐 Pendrive LUKS/VeraCrypt   📲 Celular antigo air-gap   💿 CD/DVD / M-DISC
   📄 Papel (base64/QR)         📲 Micro SD                 🔑 KeePassXC (.kdbx)
```

| Mídia | Papel | Melhores práticas | Papel no 3-2-1-1-0 |
|-------|-------|-------------------|--------------------|
| 🔐 **Pendrive LUKS/VeraCrypt** | Cofre principal portátil | Senha-frase longa; desmontar sempre; 2ª cópia | Cópia #1 / #2 |
| 🔑 **KeePassXC (`.kdbx`)** | Banco de senhas e seeds | Dentro do cofre; senha-mestra + keyfile (2FA) | O conteúdo a proteger |
| 📲 **Celular antigo air-gap** | Cofre portátil offline | Reset de fábrica, **sem chip**, modo avião sempre; container cifrado (EDS Lite/DroidFS); nunca online | Cópia portátil extra |
| 💿 **CD/DVD / M-DISC** | Arquivamento **imutável** | Grava 1× (WORM — ransomware não reescreve); M-DISC dura décadas; guarde fresco/escuro; tenha leitor | **1 imutável** (low-tech) |
| 📄 **Papel (base64 / paperkey / QR)** | Backup final, sem eletricidade | `paperkey` p/ GPG; base64/QR p/ blobs pequenos; envelope lacrado; imune a EMP/bitrot | **1 imutável** definitivo |
| 📲 **Micro SD** | Cápsula discreta | Marca boa; **2 cópias** (flash sofre bitrot); porta-SD hermético; verificar a cada 6 meses | Cópia escondida |

**Síntese — a imutabilidade tem duas faces:**

- **Alta-tecnologia:** `borg` append-only na máquina off-site (§2) — versionado, automatizável.
- **Baixa-tecnologia:** **CD/DVD/M-DISC + papel** — imutável porque é físico e não regravável. Imune a
  ransomware **e** a falta de energia. Perfeito para os segredos pequenos (`master.age`, `revogacao.asc`, seed).

> Os dois se complementam: o borg protege o **histórico do cofre**; o CD/papel protege a **raiz** (master/seed)
> num formato que nenhum malware alcança.

---

## 5. Quantas camadas? (anti-bloat)

> 💡 **O segredo não é adicionar infinitas camadas, mas manter poucas camadas bem usadas com disciplina constante.**

Um setup **excelente e realista** não usa o arsenal inteiro. Por exemplo:

- **Cofre** (pendrive LUKS/VeraCrypt + KeePassXC + keyfile) — o dia a dia.
- **1 cópia local versionada** (`ztc-snapshot-vault.sh`) + **restore-test** (`ztc-restore-test.sh`).
- **1 off-site imutável** — escolha **um**: HD frio **ou** borg no Pi/VPS.
- **Raiz em baixa-tecnologia** — `master.age` + `revogacao.asc` em **papel** e/ou **CD/M-DISC**, guardados separados.

Isso **já é** 3-2-1-1-0 com folga. Acumular celular + micro SD + 5 pendrives sem rotina é o
**"modo paranoico"** que vira **teatro de segurança** — mais coisas para esquecer, perder ou errar.
O 🔴 Red Team não precisa quebrar 7 camadas: ele espera você relaxar em **uma**.

**Disciplina vence hardware. Rotina de aço > arsenal.**

---

*Zero Trust Core — Guia prático de backup/off-site · VIPs-com · [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)*
