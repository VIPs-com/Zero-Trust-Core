# 💾 3 — Backup + Resiliência (HD + off-site + restore test)

**Trilha:** Turbo (10) + Expert (08, 09) · **Tempo total:** ~60 min

Bloco que implementa a matriz **3-2-1-1-0**: 3 cópias, 2 mídias, 1 off-site, 1 air-gap, 0 erros verificados.

---

## Sequência

| # | Playbook | O que você terá | Tempo |
|---|----------|-----------------|------:|
| [08](./08-backup-hd-3211.md) | Backup HD + manifesto | Cópia fria local com `sha256` verificado | ~10 min |
| [09](./09-wireguard-vm.md) | WireGuard + VM off-site | Backup remoto cifrado via túnel | ~30 min |
| [10](./10-restore-test.md) | Restore test mensal | Prova de que o backup realmente funciona | ~20 min |

> ⚠️ Backup que nunca foi restaurado **não é backup**. O playbook 10 é obrigatório.

---

## Matriz 3-2-1-1-0

| # | Regra | Implementação |
|---|-------|---------------|
| **3** | 3 cópias | PC + HD externo + VM off-site |
| **2** | 2 mídias diferentes | HD interno/externo + VM remota |
| **1** | 1 off-site | VM via WireGuard (Playbook 09) |
| **1** | 1 imutável | Manifesto `sha256` + snapshot (Playbook 08) |
| **0** | 0 erros | Restore test mensal (Playbook 10) |

---

## Política do que vai off-site

```
✅ Sobe para a VM:   vault.hc cifrado · manifesto sha256
❌ NUNCA sobe:        keyfile em claro · master PGP · PINs · senhas
```

A VM recebe **blobs opacos** — para o servidor remoto, parece dados aleatórios.

---

**Pré-requisitos:** [Bloco 1 — Cofre](../1-cofre/README.md) (para o `vault.hc`) · [Bloco 2 — PGP](../2-identidade-pgp/README.md) (para assinar manifestos)
**[← README principal](../README.md)**
