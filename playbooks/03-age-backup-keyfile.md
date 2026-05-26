# Playbook 03 — Backup do keyfile com `age`

**Objetivo:** Cifrar o keyfile NTAG com `age` e guardar em pendrive separado.  
**Tempo:** ~5 min  
**Pré-requisitos:**
- [ ] `~/keepass-keyfile.ztc` criado (Playbook 01)
- [ ] Pendrive separado disponível (diferente dos NTAGs)

---

## Visão geral do processo

```mermaid
flowchart TD
    A["1 — Instalar age"] --> B["2 — Cifrar keyfile\nage -p -o .ztc.age"]
    B --> C["3 — Verificar integridade\nage -d → cmp → BACKUP OK"]
    C --> D{Idêntico?}
    D -- Sim --> E["4 — Copiar para pendrive\nlsblk → mount → cp → sync"]
    D -- Não --> B
    E --> F["5 — Opcional: shred original\nsó após NTAGs confirmados"]
    F --> G["✅ Backup cifrado\nem pendrive separado dos NTAGs"]

    style A fill:#10b981,color:#fff
    style B fill:#10b981,color:#fff
    style C fill:#10b981,color:#fff
    style D fill:#475569,color:#fff
    style E fill:#10b981,color:#fff
    style F fill:#10b981,color:#fff
    style G fill:#eab308,color:#000,stroke:#854d0e,stroke-width:2px
```

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

📖 **Referência no curso:** [COMANDO 2B.2](../🎓%20Zero-Trust-Core-Expert%20-%20Versão%201.0.md#-comando-2b2-backup-cifrado-do-keyfile-age--obrigatório-antes-dos-ntags)
