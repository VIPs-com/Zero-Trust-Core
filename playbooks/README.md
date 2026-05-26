# ⚡ Playbooks — Zero Trust Core Expert

**Execução direta. Zero teoria. Copie e cole.**

Cada arquivo = um procedimento completo, do zero ao "funcionou".  
Cada playbook começa com um **diagrama "Visão geral do processo"** — olhe antes de executar.  
Para entender *por quê* cada passo existe → curso principal (link no rodapé de cada playbook).

---

## Trilha Turbo — comece aqui

| # | Playbook | O que você terá ao final | Tempo |
|---|----------|--------------------------|------:|
| [01](./01-keepass-ntag.md) | KeePassXC + NTAG keyfile | Cofre de senhas com fator físico | ~20 min |
| [02](./02-veracrypt-vault.md) | VeraCrypt vault | Volume criptografado com `.kdbx` dentro | ~10 min |
| [03](./03-age-backup-keyfile.md) | Backup do keyfile com `age` | Cópia cifrada do keyfile em pendrive/nuvem | ~5 min |
| [04](./04-abrir-cofre-auto.md) | Script de abertura automática | `ztc-open-cofre.sh` configurado e funcionando | ~15 min |
| [10](./10-restore-test.md) | Restore test mensal | Prova de que seu backup realmente funciona | ~20 min |

## Trilha Expert — depois do Turbo

| # | Playbook | O que você terá ao final | Tempo |
|---|----------|--------------------------|------:|
| [05](./05-tails-master-pgp.md) | Chave mestra PGP no Tails | Master [C] offline + subkeys [S][E][A] + revogação | ~45 min |
| [06](./06-smartcard-keytocard.md) | Smartcard — keytocard | Subkeys no token físico + PINs configurados | ~20 min |
| [07](./07-ssh-gpg-agent.md) | SSH via gpg-agent | Login SSH com hardware físico como segundo fator | ~15 min |
| [08](./08-backup-hd-3211.md) | Backup HD + manifesto | Cópia fria local com sha256 verificado | ~10 min |
| [09](./09-wireguard-vm.md) | WireGuard + VM off-site | Backup remoto criptografado via túnel | ~30 min |

---

## Estrutura de cada playbook

```
# Título
Objetivo · Tempo · Pré-requisitos
---
## Visão geral do processo   ← diagrama Mermaid do fluxo completo
## 1 — Passo 1               ← comandos, sem teoria
...
✅ Concluído                  ← próximo passo + referência no curso
```

## Regras deste formato

- **Cada passo tem no máximo 2 linhas de texto** — o resto é código
- **Diagrama Mermaid obrigatório** — o aluno enxerga o fluxo antes de executar
- **Nenhum link externo obrigatório** — o playbook é autossuficiente
- **Último bloco sempre:** `✅ Concluído` + link de referência no curso
- Se um passo exigir leitura extra → está errado — simplifique ou separe em outro playbook

---

*Zero Trust Core Expert · VIPs-com · [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)*
