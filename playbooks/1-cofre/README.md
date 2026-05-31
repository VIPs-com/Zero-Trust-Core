# 🔐 1 — Cofre (KeePassXC + VeraCrypt + NFC)

**Trilha:** Turbo (base do curso) · **Tempo total:** ~50 min · **Custo:** ~R$50-265

Bloco que monta o cofre de senhas com fator físico opcional via NTAG.
**O NFC é opcional** — desabilite com `ZTC_NFC_UID=""` no `ztc.conf` para usar só senha + keyfile no disco.

---

## Sequência

| # | Playbook | O que você terá | Tempo |
|---|----------|-----------------|------:|
| [01](./01-keepass-ntag.md) | KeePassXC + NTAG keyfile | Cofre de senhas com fator físico | ~20 min |
| [02](./02-veracrypt-vault.md) | VeraCrypt vault | Volume cifrado com `.kdbx` dentro | ~10 min |
| [03](./03-age-backup-keyfile.md) | Backup do keyfile com `age` | Cópia cifrada do keyfile em pendrive | ~5 min |
| [04](./04-abrir-cofre-auto.md) | Script de abertura automática | `ztc-open-cofre.sh` configurado | ~15 min |

---

## Modelo de segurança em camadas

```
Senha VeraCrypt (algo que sabe)
        ↓
Senha KeePassXC (algo que sabe)
        ↓
Keyfile NTAG ou disco (algo que tem)
        ↓
Cofre aberto
```

Os 3 fatores são **independentes** — perder um não compromete os outros.

---

**Próximo bloco:** [2 — Identidade PGP](../2-identidade-pgp/README.md) (Expert) · [README principal](../README.md)
