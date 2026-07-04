# Playbook W01 — Instalar Whonix (Gateway + Workstation)

**Objetivo:** Baixar, **verificar a assinatura**, importar e isolar o Whonix-Gateway + Whonix-Workstation, confirmando que a Workstation não tem rota fora do Tor.  
**Tempo:** ~40 min (download depende da conexão)  
**Pré-requisitos:**
- [ ] Host com **virtualização** habilitada na BIOS/UEFI (VT-x / AMD-V)
- [ ] ~8 GB de RAM e dezenas de GB de disco livres
- [ ] **VirtualBox** instalado e configurado (ou KVM/libvirt) num host **confiável e atualizado** — se ainda não tiver, siga primeiro o [W00 — Instalar e Configurar o VirtualBox](./W00-instalar-configurar-virtualbox.md)
- [ ] Leu o [guia principal Whonix](../🧅%20Zero-Trust-Core-Whonix.md) — em especial "Requisitos honestos"

> 🔴 **Em PC fraco, pare aqui** e use o [guia Tails](../../tails/🐧%20Zero-Trust-Core-Tails.md). Duas VMs travando não te deixam mais seguro.

---

## Visão geral do processo

```mermaid
flowchart TD
    A["1 — Baixar imagens<br/>whonix.org"] --> B["2 — Importar a chave<br/>de assinatura do Whonix"]
    B --> C["3 — Verificar a assinatura<br/>gpg --verify (OBRIGATÓRIO)"]
    C --> D["4 — Importar no VirtualBox<br/>Gateway + Workstation"]
    D --> E["5 — Boot do Gateway<br/>conectar ao Tor"]
    E --> F["6 — Boot da Workstation"]
    F --> G["7 — systemcheck<br/>confirmar Tor + sem leak"]
    G --> H["8 — Atualizar via Tor<br/>upgrade-nonroot"]
    H --> I["✅ Whonix operacional<br/>tráfego 100% via Tor"]

    style C fill:#7f1d1d,color:#fff
    style I fill:#eab308,color:#000,stroke:#854d0e,stroke-width:2px
    style A fill:#0f766e,color:#fff
```

---

## 1 — Baixar as imagens

No **host**, baixe as imagens do Whonix (VirtualBox `.ova` ou KVM `.libvirt.xz`) **somente** de:

```
https://www.whonix.org/wiki/Download
```

> Baixe também o arquivo de **assinatura** (`.asc`/`.sig`) correspondente, na mesma página.
>
> Variante com GUI atual: **LXQt** (ex.: `Whonix-LXQt-<versão>.Intel_AMD64.ova`). A variante **Xfce** foi descontinuada. Alternativa sem GUI: **CLI**. Revalide nomes em [whonix.org/wiki/VirtualBox](https://www.whonix.org/wiki/VirtualBox) antes de cada turma.

---

## 2 — Importar a chave de assinatura do Whonix

A chave de assinatura oficial e seu **fingerprint** estão publicados na página oficial de verificação.
**Não confie em fingerprint de terceiros** — pegue da fonte:

```
https://www.whonix.org/wiki/Verify_the_images
```

```sh
# Importar a chave conforme instruído na página oficial
# (baixe derivative.asc em https://www.whonix.org/keys/derivative.asc)
gpg --import derivative.asc

# Conferir o fingerprint contra o publicado em whonix.org/wiki/Verify_the_images
gpg --keyid-format long --fingerprint <FINGERPRINT_DA_PÁGINA_OFICIAL>
```

> ⚠️ Por que não fixamos o fingerprint aqui: a chave de assinatura pode ser rotacionada. A regra ZTC é
> **verificar sempre contra a fonte oficial no momento do download** — o mesmo rigor da
> [verificação do Tails (T0.13)](../../tails/🐧%20Zero-Trust-Core-Tails.md).

---

## 3 — Verificar a assinatura (OBRIGATÓRIO)

```sh
gpg --verify Whonix-*.ova.asc Whonix-*.ova
```

Saída esperada (essência):
```
gpg: Good signature from "Patrick Schleizer ..." 
```

> 🔴 **Se aparecer `BAD signature` ou a chave não bater com o fingerprint oficial → PARE.** Não importe.
> Apague o arquivo e baixe de novo. Imagem não verificada = você não sabe o que está rodando.

---

## 4 — Importar no VirtualBox

**Via GUI:** VirtualBox → **Arquivo → Importar Appliance** → selecione o `.ova` → Importar.
Isso cria **duas VMs**: `Whonix-Gateway` e `Whonix-Workstation`.

**Via terminal:**
```sh
VBoxManage import Whonix-*.ova
VBoxManage list vms     # deve listar Whonix-Gateway e Whonix-Workstation
```

> **KVM/libvirt:** siga o guia oficial — extraia o `.libvirt.xz` e importe as redes + domínios com os
> scripts/arquivos fornecidos pelo Whonix. O isolamento de rede é equivalente.

---

## Automação (opcional — host)

O script [`ztc-whonix-import-ova.sh`](../scripts/ztc-whonix-import-ova.sh) automatiza importação da chave, verificação de fingerprint (informado por você), `gpg --verify` e `VBoxManage import`. **Não** automatiza passos dentro das VMs (Anon Connection Wizard, `systemcheck`).

```sh
cd whonix/scripts
chmod +x ztc-whonix-import-ova.sh

# Confira o fingerprint em https://www.whonix.org/wiki/Verify_the_images ANTES de rodar
sudo ./ztc-whonix-import-ova.sh \
     -i /caminho/Whonix-LXQt-VERSAO.Intel_AMD64.ova \
     -s /caminho/Whonix-LXQt-VERSAO.Intel_AMD64.ova.asc \
     -k /caminho/derivative.asc \
     -f "FINGERPRINT_CONFERIDO_NA_PAGINA_OFICIAL" \
     -b
```

| Flag | Função |
|------|--------|
| `-f` | Fingerprint **obrigatório** (sempre da página oficial) |
| `-b` | Inicia Gateway (headless) e Workstation (GUI) após import |
| `-t lxqt\|cli` | Variante esperada (opcional; detecta pelo nome do arquivo) |
| `-y` | Modo não-interativo |

Log: `/var/log/whonix-install.log`

---

## 5 — Boot do Gateway (conectar ao Tor)

```
Inicie PRIMEIRO o Whonix-Gateway.
```

- Aceite os avisos iniciais (uso legal, sem garantias).
- No **Anon Connection Wizard**: conexão normal, ou **bridge** se sua rede censura o Tor
  (mesmo conceito da [seção T0.3 do Tails](../../tails/🐧%20Zero-Trust-Core-Tails.md)).
- Aguarde o Gateway sinalizar **Tor conectado**.

---

## 6 — Boot da Workstation

```
Com o Gateway já rodando, inicie o Whonix-Workstation.
```

A Workstation só tem **uma** interface de rede, apontada para o Gateway. Ela **não** fala com a
internet diretamente — é o coração do modelo anti-vazamento.

---

## 7 — systemcheck (confirmar Tor + ausência de leak)

Na **Workstation**:

```sh
systemcheck
```

Esperado: confirmação de que o Tor está funcionando e a configuração de rede está correta.

**Teste de vazamento (sanidade):** abra o **Tor Browser** da Workstation em
`https://check.torproject.org` → deve dizer **"Congratulations. This browser is configured to use Tor."**
O IP mostrado é de um nó de saída Tor, **nunca** o seu.

> 🧪 Confirme o isolamento: a Workstation não deve ter rota para a internet exceto via Gateway. Se você
> tentou configurar uma segunda placa de rede "para facilitar", **desfez** a proteção — remova-a.

---

## 8 — Atualizar via Tor

Na Workstation e no Gateway:

```sh
sudo apt update && sudo apt full-upgrade
```

> No Whonix, o `apt` já sai pelo Tor. Mantenha **as duas VMs** atualizadas — o Gateway é tão crítico
> quanto a Workstation.

---

✅ **Concluído** — Whonix operacional, tráfego 100% via Tor, Workstation isolada sem rota de vazamento.

**Próximo passo:** → [W02 — Importar subkeys do Tails](./W02-importar-subkeys-tails.md)

📖 **Referência no guia:** [O modelo Gateway + Workstation](../🧅%20Zero-Trust-Core-Whonix.md#o-modelo-gateway--workstation) · [Requisitos honestos](../🧅%20Zero-Trust-Core-Whonix.md#requisitos-reais-e-honestos-o-dilema-do-pc-velho)
