# Playbook 04 — Script de abertura automática

**Objetivo:** Configurar `ztc-open-cofre.sh` para abrir vault + KeePassXC com um comando.  
**Tempo:** ~15 min  
**Pré-requisitos:**
- [ ] Playbooks 01, 02 e 03 concluídos
- [ ] Leitor NFC USB conectado
- [ ] `nfc-list` funcionando (veja Playbook 01, Passo 7)

---

> ⚠️ **Leia antes de começar — sobre a segurança do UID NTAG:**
> O script `ztc-open-cofre.sh` verifica o UID da tag como **checagem de presença física**, não como segredo criptográfico.
> NTAG215 pode ser clonada com hardware acessível (Proxmark3, apps Android avançados). O UID **não é segredo**.
> O que protege o cofre é o *conteúdo* da tag (o keyfile) combinado com a senha do VeraCrypt e a senha do KeePassXC.
> Quem tiver a tag **e** souber as senhas consegue abrir — trate a tag como uma chave física, não como uma senha.

---

## Visão geral do processo

```mermaid
flowchart TD
    A["1 — Instalar scripts\ngit clone → cp → chmod +x"] --> B["2 — Obter UID da tag\nnfc-list"]
    B --> C["3 — Configurar ztc.conf\nUID + caminhos do vault"]
    C --> D["4 — Validar configuração\nztc-health.sh --check-conf"]
    D --> E{Tudo OK?}
    E -- Não --> C
    E -- Sim --> F["5 — Testar abertura\nztc-open-cofre.sh"]
    F --> G["6 — PATH + atalho\n(opcional)"]
    G --> H["✅ Um comando abre tudo\nNTAG → VeraCrypt → KeePassXC"]

    style A fill:#10b981,color:#fff
    style B fill:#10b981,color:#fff
    style C fill:#10b981,color:#fff
    style D fill:#10b981,color:#fff
    style E fill:#475569,color:#fff
    style F fill:#10b981,color:#fff
    style G fill:#10b981,color:#fff
    style H fill:#eab308,color:#000,stroke:#854d0e,stroke-width:2px
```

---

## 1 — Instalar o script

```sh
mkdir -p ~/bin ~/ztc-backup/manifest

# Clonar ou baixar o repositório
git clone https://github.com/VIPs-com/Zero-Trust-Core.git /tmp/ztc-repo

# Copiar scripts
cp /tmp/ztc-repo/scripts/debian/ztc-open-cofre.sh ~/bin/
cp /tmp/ztc-repo/scripts/debian/ztc-health.sh ~/bin/
cp /tmp/ztc-repo/scripts/debian/ztc-rsync-offsite.sh ~/bin/
chmod +x ~/bin/ztc-*.sh

# Copiar arquivo de configuração
cp /tmp/ztc-repo/scripts/debian/ztc.conf.example ~/ztc-backup/ztc.conf
```

---

## 2 — Obter o UID da tag NTAG

```sh
# Coloque a tag NTAG no leitor e rode:
nfc-list
```

Saída esperada:
```
NFC device: ACS ACR122U A9 opened
1 ISO14443A passive target(s) found:
ISO14443A (106 kbps) target:
    ATQA (SENS_RES): 00  44
       UID (NFCID1): 04 AB CD EF 12 34 56
```

Copie o UID sem espaços: `04:AB:CD:EF:12:34:56`

---

## 3 — Configurar `ztc.conf`

```sh
nano ~/ztc-backup/ztc.conf
```

Preencha as variáveis (substitua pelos seus caminhos reais):

```sh
ZTC_NFC_UID="04:AB:CD:EF:12:34:56"         # UID copiado no passo anterior
ZTC_VAULT_HC="$HOME/cofre/vault.hc"
ZTC_MOUNT_POINT="/media/veracrypt-ztc"
ZTC_KDBX="$ZTC_MOUNT_POINT/lab-passwords.kdbx"
ZTC_KEYFILE="$HOME/keepass-keyfile.ztc"
ZTC_REMOTE=""                               # deixe vazio por ora (Playbook 09)
ZTC_SSH_KEY=""                              # deixe vazio por ora
ZTC_MANIFEST_DIR="$HOME/ztc-backup/manifest"
```

Salvar: `Ctrl+O → Enter → Ctrl+X`

**🔴 OBRIGATÓRIO — proteger o `ztc.conf` (não pule):**

```sh
chmod 600 ~/ztc-backup/ztc.conf
```

> O `ztc.conf` contém o caminho da sua chave SSH (`ZTC_SSH_KEY`). Sem `chmod 600`, qualquer usuário do sistema (ou malware rodando como outro usuário) lê o arquivo. Permissão `600` = só você lê/escreve. Verifique com `ls -l ~/ztc-backup/ztc.conf` (deve mostrar `-rw-------`).

> **Nota sobre `ZTC_KEYFILE`:** se você executou o Passo 5 do Playbook 03 (`shred -u ~/keepass-keyfile.ztc`), o script não conseguirá ler o keyfile do disco. Nesse caso, copie o keyfile de uma das tags NTAG de volta para `~/keepass-keyfile.ztc` antes de rodar — ou mantenha o arquivo no disco com `chmod 400` (alternativa indicada no Playbook 03 Passo 5).

---

## 4 — Validar a configuração

```sh
~/bin/ztc-health.sh --check-conf
# Deve mostrar: [OK] para cada variável configurada
```

---

## 5 — Testar abertura completa

```sh
# Com a tag NTAG no leitor:
~/bin/ztc-open-cofre.sh

# Fluxo esperado:
# [OK] NTAG presente (UID: 04:AB:...)
# Informe a senha do VeraCrypt: ****
# [OK] Volume montado
# [OK] Abrindo KeePassXC...
```

---

## 6 — (Opcional) Adicionar ao PATH para abrir de qualquer lugar

```sh
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Agora você pode digitar apenas:
ztc-open-cofre.sh
```

---

## 7 — (Opcional) Atalho de desktop — abrir cofre

```sh
cat > ~/.local/share/applications/ztc-cofre-abrir.desktop << 'EOF'
[Desktop Entry]
Name=Abrir Cofre ZTC
Comment=NFC + VeraCrypt + KeePassXC
Exec=bash -c 'source ~/.bashrc; ~/bin/ztc-open-cofre.sh'
Icon=keepassxc
Terminal=true
Type=Application
Categories=Security;
EOF
```

---

## 8 — Instalar o script de FECHAR + atalho desktop

```sh
cp /tmp/ztc-repo/scripts/debian/ztc-close-cofre.sh ~/bin/
chmod +x ~/bin/ztc-close-cofre.sh
```

```sh
cat > ~/.local/share/applications/ztc-cofre-fechar.desktop << 'EOF'
[Desktop Entry]
Name=Fechar Cofre ZTC
Comment=Sync + dismount VeraCrypt
Exec=bash -c 'source ~/.bashrc; ~/bin/ztc-close-cofre.sh; read -p "Pressione Enter para sair..."'
Icon=system-lock-screen
Terminal=true
Type=Application
Categories=Security;
EOF
```

**O que ele faz:**
- Detecta se KeePassXC ainda está aberto (avisa para salvar e fechar primeiro)
- `sync` para garantir gravação no disco
- `veracrypt -t -d` desmonta o volume
- Confirma com `[OK] Cofre fechado`

> 💡 **Disciplina diária:** ao terminar de trabalhar, clique "Fechar Cofre ZTC" no menu de aplicativos. 2 segundos pra blindar tudo de novo.

---

✅ **Concluído** — `ztc-open-cofre.sh` + `ztc-close-cofre.sh` funcionando. Dois cliques no desktop para a rotina diária.

---

## 9 — Backup do vault em camadas (não pule — o cofre vale o que você protege)

O `.kdbx` interno já tem backup automático do KeePassXC (`.kdbx.old` no mesmo diretório, dentro do vault). Mas o **`vault.hc` em si** é um único arquivo binário — se corromper, perde tudo. Por isso usamos camadas:

| # | Camada | Protege contra | Onde | Custo |
|---|--------|----------------|------|-------|
| **1** | Snapshot local versionado (`ztc-snapshot-vault.sh`) | corrupção, deleção acidental | mesmo disco, pasta `~/ztc-backup/snapshots/` | 500MB × N versões |
| **2** | HD externo periódico ([Playbook 08](../3-backup-resiliencia/08-backup-hd-3211.md)) | falha do disco principal | HD plugado semanalmente | 1× HD externo |
| **3** | Off-site cifrado ([Playbook 09](../3-backup-resiliencia/09-wireguard-vm.md)) | roubo, incêndio, ransomware total | VM/cloud (vault já é AES-256) | ~R$0-25/mês |

### Camada 1 — já está automática

O `ztc-close-cofre.sh` chama `ztc-snapshot-vault.sh` **toda vez que você fecha o cofre**:

```sh
# Instalar (uma vez)
cp /tmp/ztc-repo/scripts/debian/ztc-snapshot-vault.sh ~/bin/
chmod +x ~/bin/ztc-snapshot-vault.sh
```

```sh
# O fluxo automático ao clicar "Fechar Cofre ZTC":
# 1. KeePassXC fecha
# 2. veracrypt -t -d desmonta
# 3. ztc-snapshot-vault.sh roda automaticamente:
#    - copia vault.hc → ~/ztc-backup/snapshots/vault-AAAAMMDD-HHMMSS.hc
#    - verifica sha256 (origem = cópia)
#    - rotação: mantém últimas 7 versões
#    - registra no MANIFEST.sha256 (datado)
```

**Saída esperada após fechar:**
```
[OK] Cofre fechado — todas as camadas seladas

--- Snapshot automatico do vault ---
Snapshot: ~/cofre/vault.hc (500M) -> vault-20260601-143022.hc
[OK] sha256 confere
[OK] 7 snapshots mantidos (3.5G total em ~/ztc-backup/snapshots)
```

### Configurar quantas versões manter

No `ztc.conf`:
```sh
ZTC_AUTO_SNAPSHOT="yes"                          # yes = snapshot ao fechar (default)
ZTC_SNAPSHOT_DIR="$HOME/ztc-backup/snapshots"   # onde guardar
ZTC_SNAPSHOT_KEEP="7"                            # rotação — 7 últimas versões
```

> **Cálculo de espaço:** 500MB × 7 versões = 3.5GB. Ajuste `ZTC_SNAPSHOT_KEEP` conforme espaço disponível. Se o vault é menor (ex: 100MB), pode subir para 30 versões.

> ⚠️ **Janela de histórico:** com `ZTC_SNAPSHOT_KEEP=7` e uso diário do cofre, você tem **apenas 7 dias** para detectar corrupção silenciosa antes que a última versão boa seja apagada pela rotação. Se você fecha o cofre múltiplas vezes por dia, a janela é ainda menor. Para janela de 30 dias com uso diário, ajuste para `ZTC_SNAPSHOT_KEEP="30"` (custo: 500MB × 30 = 15GB).

### Restore rápido de um snapshot

Se o `vault.hc` corromper, recupere a versão mais recente:

```sh
# Listar snapshots disponíveis (mais novo primeiro)
ls -lht ~/ztc-backup/snapshots/vault-*.hc | head -5

# Restaurar o último (verificar hash antes!)
LATEST=$(ls -1t ~/ztc-backup/snapshots/vault-*.hc | head -1)
sha256sum "$LATEST"
# Compare com a linha correspondente no MANIFEST.sha256

# Restaurar
cp "$LATEST" ~/cofre/vault.hc

# Testar abertura
~/bin/ztc-open-cofre.sh
```

### Camada 2 e 3 — quando ir além

- **HD externo (Camada 2):** se você guarda dados realmente importantes (chaves PGP, 2FA codes, identidade), faça também o [Playbook 08](../3-backup-resiliencia/08-backup-hd-3211.md) — 1× por semana, plug-and-rotate.
- **Off-site (Camada 3):** se o cenário inclui roubo/incêndio, [Playbook 09](../3-backup-resiliencia/09-wireguard-vm.md) leva os blobs cifrados pra VM via WireGuard. Como o `vault.hc` já é AES-256, **qualquer cloud serve** (rclone para Backblaze B2, Google Drive, OneDrive cabe os 500MB no plano free).

### Restore test mensal (importante!)

Backup que nunca foi testado **não é backup** — pode estar corrompido em silêncio. Pelo menos 1x por mês:

```sh
# Restaurar snapshot mais antigo + tentar abrir
OLDEST=$(ls -1t ~/ztc-backup/snapshots/vault-*.hc | tail -1)
cp "$OLDEST" /tmp/vault-test.hc
sudo mkdir -p /mnt/vault-test
veracrypt -t --pim=0 --keyfiles="" --protect-hidden=no \
  /tmp/vault-test.hc /mnt/vault-test
ls /mnt/vault-test/   # deve listar o .kdbx
veracrypt -t -d /mnt/vault-test
sudo rm -rf /mnt/vault-test /tmp/vault-test.hc
```

Detalhes completos: [Playbook 10 — Restore test mensal](../3-backup-resiliencia/10-restore-test.md).

---

## 10 — (Avançado) OpSec — disfarçar artefatos no disco

> 🥷 Esta seção é **opcional** e roda DEPOIS de tudo funcionar. O setup padrão do curso usa nomes didáticos (`vault.hc`, `keepass-keyfile.ztc`, `ztc-open-cofre.sh`) porque é mais fácil de aprender. Em produção, esses nomes denunciam o que você guarda.

### O que é gritante por padrão

| Local | Nome óbvio | Visto por... |
|-------|------------|---------------|
| `~/cofre/vault.hc` | "tem um cofre VeraCrypt aqui" | qualquer `ls`, navegador de arquivos |
| `~/keepass-keyfile.ztc` | "isto é keyfile do KeePass" | qualquer `ls` no home |
| `~/bin/ztc-open-cofre.sh` | "este script abre um cofre" | quem lista `~/bin/` ou `ps` |
| `~/ztc-backup/ztc.conf` | "pasta de backup com config" | qualquer `ls` |
| Menu de apps: "Abrir Cofre ZTC" | denuncia tudo | qualquer um na máquina |

> ⚠️ **Limite honesto:** quem ler o **código-fonte** do script vai entender o que ele faz (veracrypt + keepassxc). OpSec por nomes protege contra **listagem rápida**, não contra análise forense.

### Migração — antes vs depois

```sh
# Antes (didático)                          # Depois (discreto)
~/cofre/vault.hc                       →   ~/Documents/archive-2023.tar
~/keepass-keyfile.ztc                  →   ~/.config/.cache_session_b7f2.bin
~/bin/ztc-open-cofre.sh                →   ~/.local/bin/morning-routine.sh
~/bin/ztc-close-cofre.sh               →   ~/.local/bin/end-session.sh
~/ztc-backup/ztc.conf                  →   ~/.config/sync/cfg
/media/veracrypt-ztc/lab-passwords.kdbx →  /media/veracrypt-ztc/recipes.dat
"Abrir Cofre ZTC" (desktop entry)      →   "Morning Routine"
```

### Como aplicar a migração

**1. Rename físico dos arquivos (com cofre desmontado):**
```sh
mv ~/cofre/vault.hc                       ~/Documents/archive-2023.tar
mv ~/keepass-keyfile.ztc                  ~/.config/.cache_session_b7f2.bin

mkdir -p ~/.local/bin ~/.config/sync
mv ~/bin/ztc-open-cofre.sh                ~/.local/bin/morning-routine.sh
mv ~/bin/ztc-close-cofre.sh               ~/.local/bin/end-session.sh
mv ~/ztc-backup/ztc.conf                  ~/.config/sync/cfg
```

**2. Atualizar `cfg` (o ex-`ztc.conf`) com os novos caminhos:**
```sh
ZTC_VAULT_HC="$HOME/Documents/archive-2023.tar"
ZTC_KEYFILE="$HOME/.config/.cache_session_b7f2.bin"
ZTC_KDBX="/media/veracrypt-ztc/recipes.dat"
ZTC_MOUNT_POINT="/media/veracrypt-ztc"   # pode manter — só aparece quando montado
```

**3. Renomear o `.kdbx` na primeira abertura após montar:**
```sh
# Monta com a senha
veracrypt -t --pim=0 --keyfiles="" --protect-hidden=no \
  ~/Documents/archive-2023.tar /media/veracrypt-ztc

mv /media/veracrypt-ztc/lab-passwords.kdbx /media/veracrypt-ztc/recipes.dat
```

**4. Apontar os scripts para o novo `cfg` via env var:**
```sh
# Edite os 2 .desktop:
nano ~/.local/share/applications/ztc-cofre-abrir.desktop
nano ~/.local/share/applications/ztc-cofre-fechar.desktop
```

Trocar `Name=`, `Exec=` e nome do arquivo `.desktop`:
```ini
[Desktop Entry]
Name=Morning Routine
Exec=bash -c 'ZTC_CONF=$HOME/.config/sync/cfg ~/.local/bin/morning-routine.sh'
Icon=keepassxc
Terminal=true
Type=Application
```

```sh
mv ~/.local/share/applications/ztc-cofre-abrir.desktop \
   ~/.local/share/applications/morning-routine.desktop

mv ~/.local/share/applications/ztc-cofre-fechar.desktop \
   ~/.local/share/applications/end-session.desktop
```

**5. Testar:**
```sh
ZTC_CONF=$HOME/.config/sync/cfg ~/.local/bin/morning-routine.sh
# Deve abrir como antes
```

### Disciplina ao migrar

- [ ] Variáveis internas (`ZTC_VAULT_HC`, etc.) **podem ficar com nome ZTC** — só são vistas por quem lê o código do script
- [ ] Não renomeie os scripts antes de fazer backup do `cfg` antigo
- [ ] **Atualize o cron** se rodava `ztc-health.sh` ou `ztc-rsync-offsite.sh` automaticamente
- [ ] **Anote no Bitwarden** os caminhos novos — você vai esquecer em 6 meses

### O que NÃO vale a pena disfarçar

- Os nomes das variáveis dentro do script (`ZTC_VAULT_HC`) — só visíveis em análise de código
- O nome `keepassxc` no executável — é um pacote do sistema, todo mundo tem
- O nome `veracrypt` no executável — idem

**OpSec por nomes não é segurança forte** — é uma camada de inconveniência para quem só passa rápido pela máquina. A segurança real vem das **camadas criptográficas** (senha + keyfile + cofre cifrado). Mas disfarçar custa pouco e ajuda contra olhares casuais.

**Próximo passo Turbo:** → [Playbook 10 — Restore test mensal](../3-backup-resiliencia/10-restore-test.md)  
**Próximo passo Expert:** → [Playbook 05 — Chave mestra PGP no Tails](../2-identidade-pgp/05-tails-master-pgp.md)

📖 **Referência no curso:** [COMANDO 5.0](../../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-50-validar-ztcconf-antes-dos-scripts) · [5.3](../../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-53-keepass--veracrypt-condicional-nfc-opcional)
