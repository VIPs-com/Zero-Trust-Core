# Playbook 01 — KeePassXC + NTAG keyfile

**Objetivo:** Criar cofre KeePassXC protegido por senha + keyfile gravado em 3 tags NTAG.  
**Tempo:** ~20 min  
**Pré-requisitos:**
- [ ] KeePassXC 2.7.12+ instalado
- [ ] 3 tags NTAG215 em mãos
- [ ] Celular Android com NFC + app **NFC Tools** instalado (F-Droid ou Play Store)

---

## 1 — Instalar KeePassXC

```sh
sudo apt install -y keepassxc
keepassxc --version   # deve mostrar 2.7.x ou superior
```

---

## 2 — Gerar o keyfile

```sh
# Criar pasta de trabalho
mkdir -p ~/cofre ~/ztc-backup

# Gerar keyfile aleatório (32 bytes = 256 bits)
dd if=/dev/urandom bs=32 count=1 2>/dev/null | base64 > ~/keepass-keyfile.ztc
chmod 600 ~/keepass-keyfile.ztc

# Confirmar que foi criado
ls -lh ~/keepass-keyfile.ztc
```

---

## 3 — Criar o banco de dados KeePassXC

**Via GUI (obrigatório para criar o banco corretamente):**

1. Abra o KeePassXC
2. **Database → New Database**
3. Nome: `Lab Passwords` — Next
4. Em **Encryption Settings** → Next (padrão está OK)
5. Em **Database Credentials:**
   - Marque **Password** → defina uma senha forte
   - Marque **Key File** → clique em **Browse** → selecione `~/keepass-keyfile.ztc`
6. **Done** → salve como `~/cofre/lab-passwords.kdbx`

---

## 4 — Testar abertura (confirmar que senha + keyfile são necessários)

```sh
keepassxc --keyfile ~/keepass-keyfile.ztc ~/cofre/lab-passwords.kdbx
```

O banco deve abrir pedindo só a senha. Feche após confirmar.

---

## 5 — Copiar keyfile para o celular

```sh
# Via cabo USB (Android File Transfer / MTP)
sudo apt install -y simple-mtpfs
mkdir -p ~/mnt-android
simple-mtpfs ~/mnt-android

cp ~/keepass-keyfile.ztc ~/mnt-android/Documents/

fusermount -u ~/mnt-android
```

> Alternativa sem `simple-mtpfs`: copie o arquivo via Bluetooth, cabo com gerenciador de arquivos do SO, ou cartão microSD.

---

## 6 — Gravar as 3 tags NTAG no celular

No celular Android com **NFC Tools**:

1. Abra o app → aba **Write**
2. **Add a record → Files → Custom** → selecione `keepass-keyfile.ztc`
3. Aproxime a tag NTAG → **Write / OK**
4. Repita para as outras 2 tags

**Destinos das tags:**
- Tag 1 → bolsa/bolso (uso diário)
- Tag 2 → gaveta/cofre em casa (reserva)
- Tag 3 → local off-site (familiar, escritório)

---

## 7 — Verificar leitura no Linux

```sh
sudo apt install -y libnfc-bin

# Conecte o leitor NFC USB e aproxime uma tag
nfc-list
# Saída esperada: UID da tag, ex: 04:AB:CD:EF:12:34:56
```

---

✅ **Concluído** — você tem um cofre KeePassXC que só abre com senha + tag NFC física.

**Próximo passo obrigatório:** → [Playbook 03 — Backup do keyfile com age](./03-age-backup-keyfile.md) (não pule)  
**Depois:** → [Playbook 02 — Volume VeraCrypt](./02-veracrypt-vault.md)

📖 **Referência no curso:** COMANDO 2B.1, 2B.2, 2B.3, 2B.4
