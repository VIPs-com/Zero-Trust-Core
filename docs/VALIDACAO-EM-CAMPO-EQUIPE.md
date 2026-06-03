# 🧪 Manual de Validação em Campo — Equipe

**Público:** mantenedores / equipe VIPs-com (e aluno-testador) · **Alvo:** artefatos novos (Whonix + tooling de backup) · [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)

> **Objetivo:** transformar o que está **auditado estaticamente** (`sh -n`, links, lógica) em **provado em hardware/VM real**.
> Este manual diz **exatamente o que rodar, o que capturar e como me enviar** para eu validar cada processo.
>
> Para **NFC + Tails (Issue #2)** o protocolo já existe — use o [CHECKLIST-PRE-TURMA-EQUIPE.md](./CHECKLIST-PRE-TURMA-EQUIPE.md). Este aqui cobre o **resto novo**.

---

## Sumário
- [Como funciona o loop de validação](#como-funciona-o-loop-de-validação)
- [⚠️ OpSec ao capturar e enviar evidências (leia primeiro)](#️-opsec-ao-capturar-e-enviar-evidências-leia-primeiro)
- [Bloco de ambiente (cole no topo de todo relatório)](#bloco-de-ambiente-cole-no-topo-de-todo-relatório)
- [V1 — Restore-test do cofre (Debian)](#v1--restore-test-do-cofre-debian)
- [V2 — Off-site imutável com borg](#v2--off-site-imutável-com-borg)
- [V3 — Whonix: instalação e isolamento (W01)](#v3--whonix-instalação-e-isolamento-w01)
- [V4 — Whonix: health + identidade (W02)](#v4--whonix-health--identidade-w02)
- [V5 — Bitcoin PSBT, duas mídias (W03, opcional)](#v5--bitcoin-psbt-duas-mídias-w03-opcional)
- [V6 — Scripts do Tails](#v6--scripts-do-tails)
- [V7 — NFC + Tails (Issue #2)](#v7--nfc--tails-issue-2)
- [Template de relatório (copiar e colar aqui)](#template-de-relatório-copiar-e-colar-aqui)
- [Matriz de cobertura](#matriz-de-cobertura)
- [Pós-validação — o que isso destrava](#pós-validação--o-que-isso-destrava)

---

## Como funciona o loop de validação

```
1. Você roda a suíte (V1…V7) numa máquina/VM real
2. Captura a saída no formato pedido (REDIGIDA — sem segredos)
3. Cola aqui (neste chat) usando o template de relatório
4. Eu valido: confirmo PASS, ou aponto a correção e o motivo
5. Quando uma suíte passa → vira ✅ na matriz e no INVENTARIO (dispositivos testados)
```

Onde registrar oficialmente depois: comentário no [Issue #2](https://github.com/VIPs-com/Zero-Trust-Core/issues/2) (ou um issue novo "Validação Whonix/backup") + PR atualizando a tabela de dispositivos.

---

## ⚠️ OpSec ao capturar e enviar evidências (leia primeiro)

> 🔴 **O objetivo é provar o PROCESSO, não expor segredos.** Validar não pode virar vazamento.

- **Use material de LABORATÓRIO**, descartável: chave PGP **fictícia** (ex.: `lab-test@exemplo.local`, expira em 30 dias), cofre de **teste**, e — se for Bitcoin — **testnet/regtest** (NUNCA mainnet com fundos reais).
- **NUNCA cole:** seed/12 palavras, senha do VeraCrypt, senha-mestra do KeePass, passphrase do `age`/`borg`, conteúdo de `.kdbx`/`vault.hc`, chave privada.
- **Mascare** ao colar: fingerprint/UID real → troque dígitos por `xx`; IP/hostname da VM → `10.x.x.x` / `vm-lab`; e-mail real → `lab@exemplo`.
- Prefira **resumo da saída** (as linhas `[OK]`/`[FAIL]`/`PASS`/`FAIL` + o placar) a dumps gigantes.
- Screenshots: **borre** IPs, nomes de arquivo sensíveis e qualquer trecho de senha.

> Se na dúvida sobre colar algo, descreva em vez de colar. *"O `gpg -K` mostrou `sec#` + 3 `ssb`"* é melhor que colar o keyring real.

---

## Bloco de ambiente (cole no topo de todo relatório)

```sh
date -Is
uname -a
# versões relevantes ao teste em questão (veja cada suíte)
```

---

## V1 — Restore-test do cofre (Debian)

**Prova:** que um snapshot do `vault.hc` realmente **restaura** (a "0 erros" do 3-2-1-1-0).
**Pré-req:** um cofre/snapshot de **LAB** + [`ztc-restore-test.sh`](../scripts/ztc-restore-test.sh) instalado + `ztc.conf` apontando para o snapshot de lab.

```sh
veracrypt --version 2>/dev/null | head -1
keepassxc-cli --version
ls -la "${ZTC_SNAPSHOT_DIR:-$HOME/ztc-backup/snapshots}"/   # há snapshot?
~/bin/ztc-restore-test.sh ; echo "exit=$?"
# (informe a senha VeraCrypt de LAB e a senha KeePass de LAB quando pedido)
```

**Esperado:** Teste 1 sha256 confere · Teste 2 monta **read-only** · Teste 3 `.kdbx` presente · Teste 4 **KeePassXC abre** → `🟢 RESTORE 100% VERIFICADO`, `exit=0`.

**📋 Capturar e enviar:** o placar final (`Total/PASS/FAIL/WARN`), o `exit`, e a versão do VeraCrypt/KeePassXC. **Não** cole as senhas.

---

## V2 — Off-site imutável com borg

**Prova:** que o off-site `borg` é **append-only** (cliente comprometido não destrói histórico) **e** que restaura.
**Pré-req:** máquina-destino de LAB (Raspberry Pi / VPS / 2ª máquina) com `borg`, conta dedicada e a chave do cliente **restrita** no `authorized_keys`.

**(a) Mostre o enforcement (config do servidor — REDIGIDA):**
```sh
# Na VM/destino: a linha que torna a chave append-only (mascare a chave!)
grep 'borg serve' ~ztc-bkp/.ssh/authorized_keys
# Esperado conter: command="borg serve --append-only --restrict-to-path .../borg-ztc",restrict ssh-ed25519 AAAA…(MASCARAR)
```

**(b) Backup:**
```sh
borg --version
~/bin/ztc-borg-offsite.sh ; echo "exit=$?"
```

**(c) Prova de imutabilidade (a evidência-chave):**
```sh
# Tente APAGAR um archive a partir do CLIENTE:
borg list                       # escolha um archive (mascare o nome do repo/host)
borg delete ::vault-AAAAMMDD-HHMMSS ; echo "exit=$?"
```
> **Esperado:** o append-only **impede a destruição real**. Dependendo da versão, o `borg delete` é **recusado** (erro de append-only) **ou** "registrado" mas os dados **permanecem recuperáveis** (só um `borg compact` server-side, fora do append-only, libera espaço). Em ambos os casos: o **dado antigo continua lá**. Capture a mensagem exata.

**(d) Restore (prova que volta):**
```sh
mkdir -p /tmp/borg-restore && cd /tmp/borg-restore
borg extract ::vault-AAAAMMDD-HHMMSS
ls -la                          # vault.hc restaurado?
# opcional: rode ztc-restore-test.sh apontando para este vault.hc
```

**📋 Capturar e enviar:** (a) a linha `authorized_keys` **com a chave mascarada** (prova do `--append-only`), (b) `exit` do backup, (c) a **mensagem do `borg delete`** (a prova de imutabilidade), (d) confirmação de que o `borg extract` trouxe o `vault.hc`. Mascare repo/host/IP.

---

## V3 — Whonix: instalação e isolamento (W01)

**Prova:** Whonix verificado, Tor forçado, Workstation sem rota de vazamento. Segue o [W01](../whonix/playbooks/W01-instalar-whonix.md).

**(a) Verificação de assinatura (no host, antes de importar):**
```sh
gpg --verify Whonix-*.ova.asc Whonix-*.ova 2>&1 | sed -n '1,4p'
```
> **Esperado:** `Good signature from "Patrick Schleizer …"` e o **fingerprint conferido** contra a página oficial de verificação. Se `BAD signature` → **parar**.

**(b) Teste de leak (na Workstation):** abra o **Tor Browser** em `https://check.torproject.org` → deve dizer **"Congratulations. This browser is configured to use Tor."**

**(c) systemcheck (na Workstation):**
```sh
systemcheck 2>&1 | tail -n 15
```

**📋 Capturar e enviar:** o trecho `Good signature` + "fingerprint confere com a fonte oficial: sim/não"; **screenshot** do check.torproject (com IP **borrado**); resumo do `systemcheck` (Tor OK). **Não** precisa colar IP nenhum.

---

## V4 — Whonix: health + identidade (W02)

**Prova:** o `ztc-whonix-health.sh` funciona e as **subkeys** estão lá com a **master ausente**.
**Pré-req:** subkeys de uma chave de **LAB** importadas via [W02](../whonix/playbooks/W02-importar-subkeys-tails.md).

```sh
~/bin/ztc-whonix-health.sh ; echo "exit=$?"
gpg -K | sed -n '1,8p'     # deve mostrar sec#  +  3x ssb  (mascare fingerprint/UID)
```

**Esperado:** health `OK` (ou `OK com avisos`); `gpg -K` mostra **`sec#`** (master ausente) + 3 `ssb`. Se aparecer `sec` **sem** `#` → o health deve marcar **FAIL** (master vazou para o online — bug a corrigir).

**📋 Capturar e enviar:** a saída do health (linhas `[OK]/[WARN]/[FAIL]` + veredito) e a confirmação `sec#` + 3 `ssb` (pode descrever em vez de colar). Use **chave de lab**.

---

## V5 — Bitcoin PSBT, duas mídias (W03, opcional)

**Prova:** a seed nunca toca o online; transporte ≠ segredo. Segue o [W03](../whonix/playbooks/W03-bitcoin-psbt-tails-whonix.md).
**🔴 Use testnet/regtest** (nunca mainnet com fundos reais).

Execute o fluxo: watch-only no Whonix (xpub testnet) → PSBT → assina no Tails offline → broadcast via Tor. Prefira **QR** ao USB; se usar USB, **um** pendrive só de transporte.

**📋 Capturar e enviar:** descrição do que usou (QR ou pendrive transitório dedicado), confirmação "a carteira do Whonix era watch-only (sem seed)", e — se testnet — o **txid** (público, pode colar). **Nunca** a seed.

---

## V6 — Scripts do Tails

**Prova:** os scripts do Tails rodam sem `FAIL` numa sessão real.

```sh
# Na sessão Tails (Persistent ativo, chave de lab):
sh ztc-tails-health.sh ; echo "exit=$?"
sh ztc-tails-restore-test.sh ; echo "exit=$?"   # contra um backup .age de LAB
```

**📋 Capturar e enviar:** os vereditos (`OK`/placar) dos dois scripts e `exit`. Mascare caminhos de pendrive.

---

## V7 — NFC + Tails (Issue #2)

Já tem protocolo dedicado: **[CHECKLIST-PRE-TURMA-EQUIPE.md](./CHECKLIST-PRE-TURMA-EQUIPE.md)** (teste de `ztc-open-cofre.sh` com leitor NFC + revalidação do Tails) + o [modelo de comentário do Issue #2](./MODELO-COMENTARIO-ISSUE-2.md). **Não repita aqui** — rode aquele e registre no Issue #2.

---

## Template de relatório (copiar e colar aqui)

```markdown
## Validação [V_] — <nome do processo>
- Data: AAAA-MM-DD · Responsável: @você
- Ambiente: <SO/versão · hardware ou VM · RAM>
- Resultado: ✅ PASS · ⚠️ WARN · ❌ FAIL

### Comando(s)
<colar os comandos rodados>

### Saída (REDIGIDA — sem segredos)
<colar só o essencial: linhas [OK]/[FAIL] + placar + exit>

### Evidência extra
<screenshot com IP/nomes borrados, se aplicável>

### Observações
<o que travou, divergência de versão, dúvida>
```

---

## Matriz de cobertura

| ID | Processo | Script/Guia | Status | Evidência |
|----|----------|-------------|:------:|-----------|
| V1 | Restore-test cofre (Debian) | `ztc-restore-test.sh` | ⏳ | — |
| V2 | Off-site imutável (borg) | `ztc-borg-offsite.sh` | ⏳ | — |
| V3 | Whonix instalar + leak test | W01 | ⏳ | — |
| V4 | Whonix health + identidade | `ztc-whonix-health.sh` · W02 | ⏳ | — |
| V5 | Bitcoin PSBT duas mídias (opt) | W03 | ⏳ | — |
| V6 | Scripts do Tails | `ztc-tails-*` | ⏳ | — |
| V7 | NFC + Tails | [CHECKLIST-PRE-TURMA](./CHECKLIST-PRE-TURMA-EQUIPE.md) · Issue #2 | ⏳ | — |

> Legenda: ⏳ pendente · 🟡 parcial · ✅ validado em campo. Atualize ao colar a evidência aqui.

---

## Pós-validação — o que isso destrava

Quando uma suíte passa (validada aqui + registrada):

1. **`INVENTARIO` → "Dispositivos testados":** mover o item de **⏳ para ✅** com link da evidência. ([tabela](./INVENTARIO-SOFTWARE-HARDWARE.md#-dispositivos-testados-compatibilidade-confirmada))
2. **FAQ:** registrar qualquer pega real encontrada (formato da [FAQ](./FAQ-TROUBLESHOOTING.md)).
3. **Scorecard:** subir os pontos cobertos pela validação (NFC, Praticabilidade).
4. **Release:** com V1–V4 (+V7) validadas, promover **`v1.0.3-rc1` → `v1.0.3`** final e fechar o [Issue #2](https://github.com/VIPs-com/Zero-Trust-Core/issues/2).

---

*Guia da equipe VIPs-com · validação de campo dos artefatos pós-v1.0.2 · [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)*
