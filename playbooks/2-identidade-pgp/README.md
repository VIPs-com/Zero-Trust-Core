# 🔑 2 — Identidade PGP (Tails + Smartcard + SSH)

**Trilha:** Expert · **Tempo total:** ~80 min · **Custo:** smartcard ~R$300-500

Bloco que cria identidade criptográfica forte: master no air-gap, subkeys no hardware físico, SSH autenticado pelo smartcard.

---

## Sequência

| # | Playbook | O que você terá | Tempo |
|---|----------|-----------------|------:|
| [05](./05-tails-master-pgp.md) | Chave mestra PGP no Tails | Master [C] offline + subkeys [S][E][A] + revogação | ~45 min |
| [06](./06-smartcard-keytocard.md) | Smartcard — keytocard | Subkeys no token físico + PINs configurados | ~20 min |
| [07](./07-ssh-gpg-agent.md) | SSH via gpg-agent | Login SSH com smartcard como segundo fator | ~15 min |

---

## Modelo de identidade

```
Master [C]  ←  só no Tails, nunca no PC online
    │
    ├── Subkey [S] sign   ─┐
    ├── Subkey [E] encrypt ├─→  no smartcard físico (não extraível)
    └── Subkey [A] auth   ─┘
                              │
                              └── SSH via gpg-agent
```

A master assina/revoga as subkeys; as subkeys vivem no hardware. Se o smartcard sumir, você revoga as subkeys com a master no Tails — sem comprometer a identidade.

---

**Pré-requisito:** [Bloco 1 — Cofre](../1-cofre/README.md) (para guardar a passphrase da master)
**Próximo bloco:** [3 — Backup + Resiliência](../3-backup-resiliencia/README.md) · [README principal](../README.md)
