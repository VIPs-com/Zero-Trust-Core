# Playbook 03 — Backup do keyfile com `age`

**Objetivo:** Cifrar o keyfile NTAG com `age` e guardar em pendrive separado.  
**Tempo:** ~5 min  
**Pré-requisitos:**
- [ ] `~/keepass-keyfile.ztc` criado (Playbook 01)
- [ ] Pendrive separado disponível (diferente dos NTAGs)

---

## 1 — Instalar `age`

```sh
sudo apt install -y age
age --version   # deve mostrar v1.x
```

---

## 2 — Cifrar o keyfile

```sh
mkdir -p ~/ztc-backup

# Cifrar com senha interativa (pede 2x para confirmar)
age -p -o ~/ztc-backup/keepass-keyfile.ztc.age ~/keepass-keyfile.ztc
```

> Quando pedir a passphrase: use uma senha **diferente** da senha do KeePass e da senha do VeraCrypt. Anote ou memorize — sem ela, o backup é inútil.

---

## 3 — Verificar a integridade do backup

```sh
# Decifrar em arquivo temporário
age -d ~/ztc-backup/keepass-keyfile.ztc.age > /tmp/keyfile-check.ztc

# Comparar com o original (deve mostrar nada = idênticos)
cmp ~/keepass-keyfile.ztc /tmp/keyfile-check.ztc && echo "BACKUP OK"

# Apagar o temporário
shred -u /tmp/keyfile-check.ztc
```

---

## 4 — Copiar o backup para pendrive

```sh
# Descobrir o dispositivo do pendrive
lsblk

# Montar (ajuste sdb1 pelo seu dispositivo)
sudo mount /dev/sdb1 /mnt

# Copiar
cp ~/ztc-backup/keepass-keyfile.ztc.age /mnt/
sync

# Desmontar
sudo umount /mnt
```

---

## 5 — (Opcional) Apagar o keyfile em texto claro do disco

```sh
# Só faça isso se tiver certeza que os NTAGs estão gravados corretamente
# e o backup .age está no pendrive
shred -u ~/keepass-keyfile.ztc
```

> Se optar por manter o `keepass-keyfile.ztc` no disco, proteja com `chmod 400`.

---

✅ **Concluído** — backup cifrado do keyfile em pendrive separado dos NTAGs.

**Regra:** se os 3 NTAGs e o pendrive ficarem no mesmo lugar → você não tem backup real.

📖 **Referência no curso:** COMANDO 2B.2
