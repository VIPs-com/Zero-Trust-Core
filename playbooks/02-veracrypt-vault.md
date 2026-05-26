# Playbook 02 — VeraCrypt vault

**Objetivo:** Criar volume VeraCrypt e mover o `.kdbx` para dentro dele.  
**Tempo:** ~10 min  
**Pré-requisitos:**
- [ ] `lab-passwords.kdbx` criado (Playbook 01)
- [ ] `keepass-keyfile.ztc` criado (Playbook 01)

---

## Visão geral do processo

```mermaid
flowchart TD
    A["1 — Instalar VeraCrypt\nwget + dpkg -i .deb"] --> B["2 — Criar volume\nveracrypt -t --create vault.hc"]
    B --> C["3 — Montar volume\n/media/veracrypt-ztc"]
    C --> D["4 — Mover .kdbx\npara dentro do volume"]
    D --> E["5 — Desmontar\nveracrypt -t -d"]
    E --> F["6 — Testar abertura completa\nveracrypt → keepassxc --keyfile"]
    F --> G["✅ Duas camadas independentes\nVeraCrypt + KeePassXC + NTAG"]

    style A fill:#10b981,color:#fff
    style B fill:#10b981,color:#fff
    style C fill:#10b981,color:#fff
    style D fill:#10b981,color:#fff
    style E fill:#10b981,color:#fff
    style F fill:#10b981,color:#fff
    style G fill:#eab308,color:#000,stroke:#854d0e,stroke-width:2px
```

---

## 1 — Instalar VeraCrypt

```sh
# Baixar o .deb oficial (NÃO está nos repos Ubuntu)
wget -O /tmp/veracrypt.deb \
  "https://launchpad.net/veracrypt/trunk/1.26.24/+download/veracrypt-1.26.24-Ubuntu-24.04-amd64.deb"

sudo dpkg -i /tmp/veracrypt.deb

veracrypt --version   # deve mostrar 1.26.24
```

---

## 2 — Criar o volume criptografado

```sh
mkdir -p ~/cofre

veracrypt -t --create ~/cofre/vault.hc \
  --size=100M \
  --encryption=AES \
  --hash=SHA-512 \
  --filesystem=Ext4 \
  --volume-type=Normal \
  --password="" \
  --random-source=/dev/urandom
```

> O comando vai pedir a **senha mestra** interativamente. Use uma senha forte e diferente da do KeePass.

---

## 3 — Montar o volume

```sh
sudo mkdir -p /media/veracrypt-ztc

veracrypt -t ~/cofre/vault.hc /media/veracrypt-ztc
# Informe a senha quando solicitado
```

---

## 4 — Mover o banco KeePassXC para dentro do volume

```sh
mv ~/cofre/lab-passwords.kdbx /media/veracrypt-ztc/

# Confirmar
ls -lh /media/veracrypt-ztc/
```

---

## 5 — Desmontar

```sh
veracrypt -t -d /media/veracrypt-ztc
```

---

## 6 — Testar abertura completa

```sh
# Montar volume
veracrypt -t ~/cofre/vault.hc /media/veracrypt-ztc

# Abrir KeePassXC com o banco dentro do volume
keepassxc --keyfile ~/keepass-keyfile.ztc \
  /media/veracrypt-ztc/lab-passwords.kdbx

# Ao fechar o KeePassXC, desmontar:
veracrypt -t -d /media/veracrypt-ztc
```

---

✅ **Concluído** — `vault.hc` montado → `lab-passwords.kdbx` dentro → só abre com senha VeraCrypt + senha KeePass + keyfile NTAG.

**Próximo passo:** → [Playbook 04 — Script de abertura automática](./04-abrir-cofre-auto.md)

📖 **Referência no curso:** COMANDO 3.1.1, 3.1.2, 3.1.3
