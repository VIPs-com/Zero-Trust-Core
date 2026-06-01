# 🔐 1 — Cofre (KeePassXC + VeraCrypt + NFC)

**Trilha:** Turbo (base do curso) · **Tempo total:** ~50 min · **Custo:** ~R$50-265

Bloco que monta o cofre de senhas com fator físico opcional via NTAG.
**O NFC é opcional** — desabilite com `ZTC_NFC_UID=""` no `ztc.conf` para usar só senha + keyfile no disco.

---

## Sequência

| # | Playbook | O que você terá | Tempo |
|---|----------|-----------------|------:|
| [00](./00-uso-diario.md) | Uso diário + modelo de segurança | Entende os 3 fatores + abre/fecha manual + limites (keylogger) | ~10 min |
| [01](./01-keepass-ntag.md) | KeePassXC + NTAG keyfile | Cofre de senhas com fator físico | ~20 min |
| [02](./02-veracrypt-vault.md) | VeraCrypt vault | Volume cifrado com `.kdbx` dentro | ~10 min |
| [03](./03-age-backup-keyfile.md) | Backup do keyfile com `age` | Cópia cifrada do keyfile em pendrive | ~5 min |
| [04](./04-abrir-cofre-auto.md) | Script de abertura automática | `ztc-open-cofre.sh` configurado | ~15 min |

> **Ordem de leitura/execução:** leia o conceito do **00** primeiro → construa com **01-03** → volte ao **00** para a prática manual → automatize com **04**. O playbook 00 é a ponte entre construir e usar todo dia.

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
