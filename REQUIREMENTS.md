# REQUIREMENTS.md — Dependências do setup

O que precisa existir para `CLAUDE.md`, `STACK.md` e os agentes funcionarem.

**Verificado em:** 2026-08-09, macOS, máquina do Eduardo.
Cada linha foi conferida em disco e submetida a verificação adversarial (72 afirmações testadas,
26 refutadas e corrigidas). Status ✅/❌ é **observação**, não suposição.
Em outra máquina, rode a §8 antes de confiar nas marcas.

---

## 1. Base — Claude Code

| Item | Observado | Origem |
|---|---|---|
| Claude Code | `2.1.197` | npm global — `@anthropic-ai/claude-code` |

```bash
npm install -g @anthropic-ai/claude-code
```

> O pacote npm **não distribui skill nenhuma**. Toda skill deste setup vem de outro lugar (§3).

---

## 2. SuperClaude Framework — os comandos `/sc:`

Todo `/sc:*` citado no `CLAUDE.md` vem daqui. **Não são nativos do Claude Code.**

| Item | Observado | Origem |
|---|---|---|
| Pacote `superclaude` | `4.3.0` | pipx (Python 3.14.3) |
| Arquivos em `~/.claude` | também `4.3.0` | `superclaude install` |
| Binário | `~/.local/bin/superclaude` (**um só**) | pipx |

```bash
pipx install superclaude
superclaude install
```

> ⚠️ **Nome em minúsculas.** O pacote e o executável são `superclaude`. `SuperClaude install`
> só funciona no macOS porque o filesystem é case-insensitive — em Linux dá `command not found`.

> ⚠️ **`.superclaude-metadata.json` está defasado, os arquivos não.** O JSON grava `4.1.6`
> (install de 2025-10-27) e declara 17 agentes. O disco tem os arquivos da `4.3.0`: 31/31
> comandos e 19/20 agentes byte-idênticos ao pacote, datados de 2026-04-30 — mesmo timestamp do
> symlink do pipx. O `superclaude install` foi rodado; ele apenas não reescreve o campo `version`.
> **Nada a reconciliar.** Não use esse JSON como fonte de versão — use `superclaude --version`.

**O que o framework implanta:** `agents`, `commands`, `core`, `mcp`, `mcp_docs`, `modes` —
inclui `RULES.md`, `PRINCIPLES.md`, `FLAGS.md`, os `MODE_*.md`, os `MCP_*.md` e os 20 especialistas.

### Comandos `/sc:` — 31 arquivos em `~/.claude/commands/sc/`

Os 18 da esteira, **todos presentes**:

| Etapa | Comandos |
|---|---|
| Sessão | `load` ✅ · `save` ✅ · `pm` ✅ |
| Idealizar | `brainstorm` ✅ · `document` ✅ |
| Desenhar | `design` ✅ · `workflow` ✅ · `estimate` ✅ |
| Executar | `implement` ✅ · `task` ✅ · `build` ✅ |
| Aprimorar | `analyze` ✅ · `test` ✅ · `troubleshoot` ✅ · `cleanup` ✅ · `improve` ✅ |
| Lançar | `index-repo` ✅ · `git` ✅ |

Instalados e não usados pela esteira (13): `agent`, `business-panel`, `explain`, `help`, `index`,
`recommend`, `reflect`, `research`, `sc`, `select-tool`, `spawn`, `spec-panel` e `README`
(arquivo do pacote que o harness também registra como `/sc:README`). 18 + 13 = 31. ✅

### Comandos `/ideal:*`

6 arquivos em `~/.claude/commands/ideal/` ✅.

> ⚠️ **Quebrados.** Os 6 mandam seguir `IDEAL.md`, que **não existe**. O `~/.claude/CLAUDE.md`
> global também referencia `IDEAL.md` e `META-SQUAD.md`, ambos ausentes. A esteira deste setup
> não depende deles. Ou crie os arquivos, ou repoint os comandos.

---

## 3. Skills

> ❗ **Correção importante:** skills **não vêm com o Claude Code**. São baixadas por um
> gerenciador de skills, com procedência registrada em `~/.agents/.skill-lock.json`.
> Um symlink existir não significa que a skill carrega — 15 estão quebrados nesta máquina.

### 3.1 Funcionando

| Skill | Forma | Usada por |
|---|---|---|
| `uml` | symlink → `~/.agents/skills/uml` ✅ | `CLAUDE.md` §5.1 · `prc-desenhista` |
| `bpmn` | symlink → `~/.agents/skills/bpmn` ✅ | `CLAUDE.md` §5.1 · `prc-desenhista` |
| `use-railway` | symlink → `~/.agents/skills/use-railway` ✅ | `dev-lancador-webapp` · `STACK.md` §7 |
| `find-docs` | diretório real ✅ | `dev-desenhista-webapp`, `dev-executor-webapp` |
| `railway-template` | diretório real ✅ | `STACK.md` §7 |
| `graphify` | diretório real ✅ | `~/.claude/CLAUDE.md` global — fora da esteira |

Existe `find-docs` em `~/.agents/skills/` **e** como diretório real em `~/.claude/skills/`.
A real tem precedência. Duplicação a vigiar, não erro.

### 3.2 ❌ Symlinks quebrados — usados pelo setup

Apontam para `~/.agents/skills/<nome>`, que não existe. **Estas skills não carregam.**

| Skill | Citada por | Onde o conteúdo está |
|---|---|---|
| `explore` ❌ | agentes do squad webapp | `~/.agentss/skills/explore` |
| `code-edit` ❌ | `dev-executor-webapp` | `~/.agentss/skills/code-edit` |
| `feature-research` ❌ | `dev-idealizador-webapp` | `~/.agentss/skills/feature-research` |
| `playwright-best-practices` ❌ | `dev-aprimorador-webapp` (residual) | `~/codex-config/skills/…` |

**Existem dois diretórios**: `~/.agents/` e `~/.agentss/` (dois "s"), cada um com seu
`.skill-lock.json`. Os links apontam para o primeiro; parte do conteúdo está no segundo.

Outros 11 quebrados, fora da esteira: `ai-seo`, `baoyu-youtube-transcript`, `composio-cli`,
`ffmpeg-video-editor`, `gemini-api-dev`, `pexels-video-downloader`, `pixel-art-sprites`,
`remotion-best-practices`, `trello`, `youtube-thumbnail-design`, `yt-dlp-downloader`.

Diagnóstico e correção:

```bash
# listar todos os links mortos
for s in ~/.claude/skills/*; do [ -L "$s" ] && [ ! -e "$s" ] && echo "QUEBRADO: $(basename $s)"; done

# opção A — reapontar para o diretório onde o conteúdo está
ln -sfn ~/.agentss/skills/explore ~/.claude/skills/explore

# opção B — reinstalar pelo gerenciador, usando a procedência do .skill-lock.json
```

### 3.3 Built-in do harness

`simplify` — citada pelo `dev-aprimorador-webapp`. Não existe em disco: é fornecida pelo Claude
Code em runtime. Nada a instalar, nada a versionar; pode variar entre versões do produto.

---

## 4. MCP servers — quatro origens distintas

Confundir escopos é a causa mais provável de um requirements errado. Status abaixo vem de
`claude mcp list` rodado em `/Users/eduardocarezia/Projects/caravieri`.

### 4.1 Escopo user — `~/.claude.json`, chave `.mcpServers` de topo

| Servidor | Comando | Usado por | Status |
|---|---|---|---|
| `context7` | `npx -y @upstash/context7-mcp` | Desenhista/Executor webapp | ✔ conectado |
| `sequential-thinking` | `npx -y @modelcontextprotocol/server-sequential-thinking` | análise multi-camada | ✔ conectado |
| `serena` | `uvx --from git+…/serena serena start-mcp-server --context ide-assistant --enable-web-dashboard false --enable-gui-log-window false` | `/sc:load`, `/sc:save` | ✔ conectado |
| `morphllm-fast-apply` | `npx -y @morph-llm/morph-fast-apply` (env `MORPH_API_KEY`) | Executor webapp | ✔ conectado |
| `chrome-devtools` | `npx -y chrome-devtools-mcp@latest` | Aprimorador (Core Web Vitals) | ✔ conectado |
| `magic` | `npx -y @21st-dev/magic` (env `API_KEY_21ST`) | Desenhista/Executor webapp | ❌ **falha ao conectar** |
| `trello` | `mcp-server-trello` (env `TRELLO_*`) | fora da esteira | ✔ conectado |
| `composio` | `https://connect.composio.dev/mcp` | fora da esteira | ⚠️ precisa auth |
| `vercel` | `https://mcp.vercel.com` | **nenhum** — órfão (§7) | ⚠️ precisa auth |

```bash
claude mcp add context7 -- npx -y @upstash/context7-mcp
claude mcp add sequential-thinking -- npx -y @modelcontextprotocol/server-sequential-thinking
claude mcp add serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server \
  --context ide-assistant --enable-web-dashboard false --enable-gui-log-window false
claude mcp add chrome-devtools -- npx -y chrome-devtools-mcp@latest
claude mcp add morphllm-fast-apply -e MORPH_API_KEY=<chave> -- npx -y @morph-llm/morph-fast-apply
claude mcp add magic -e API_KEY_21ST=<chave> -- npx -y @21st-dev/magic
```

`serena` exige `uv`/`uvx`. `magic` e `morphllm` exigem chave do fornecedor.

### 4.2 Escopo projeto — `~/.claude.json`, chave `.projects[<caminho>].mcpServers`

Só valem quando o cwd é exatamente aquele caminho.

| Caminho | Servidores |
|---|---|
| `/Users/eduardocarezia` | `Railway` (`npx @railway/mcp-server`), `convex` |
| `…/Apps/ai-code-lab` | `clerk`, `convex` |
| `…/Apps/zapflower` | `clerk`, `convex` |
| `…/Apps/barbearia-ai` · `…/Apps/entrega-ai` | `convex` |

> ⚠️ **`caravieri` não aparece nesta lista.** Os MCP de `convex` e `clerk` que outros apps seus
> têm **não** estão disponíveis lá. Se quiser, adicione no escopo do projeto.

### 4.3 `~/.mcp.json`

| Servidor | Status |
|---|---|
| `supabase` (`https://mcp.supabase.com/mcp`) | ⚠️ precisa auth · fora da esteira |

### 4.4 Connectors da claude.ai

Não se instalam por CLI. Autorize nas configurações de connectors.

| Connector | Usado por | Status |
|---|---|---|
| **claude-in-chrome** | `CLAUDE.md` §5.2 — padrão para navegador | ✔ (exige extensão do Chrome conectada) |
| **Railway** (`https://mcp.railway.com`) | `dev-lancador-webapp` | ✔ conectado |
| Notion · Gmail · Google Drive · Calendar · Atlassian | fora da esteira | ✔ conectados |

> Existem **dois** Railway: o connector (ativo em qualquer projeto) e o `npx @railway/mcp-server`
> do escopo `/Users/eduardocarezia`. Em `caravieri` vale o connector.

---

## 5. Agentes

`~/.claude/agents/` — **44 arquivos `.md`** (45 no total: há um `.orquestrador-ideal.md.swp`,
swap órfão do Vim de 2026-04-30, sem função; não copie numa restauração).

| Grupo | Qtd | Origem |
|---|---|---|
| Especialistas transversais | 20 | SuperClaude 4.3.0 |
| Meta-squad (`orquestrador-ideal` + 5) | 6 | manual |
| Squad webapp (`dev-*-webapp`) | 6 | manual · retrofit p/ Railway em 2026-08-07 |
| Squad dev genérico (`dev-*`) | 6 | manual · stack-agnostic |
| Time de processos (`prc-*`) | 6 | manual · criado 2026-08-07 |

Os 24 manuais **não são reinstaláveis por pacote**. Backup dos 6 do webapp antes do retrofit:
`~/.claude/backups/agents-pre-railway-20260807-220606/`.

---

## 6. Matriz — o que quebra sem o quê

| Falta | Quebra | Gravidade |
|---|---|---|
| SuperClaude | Todo `/sc:*` — a esteira perde a orquestração | 🔴 |
| `serena` | `/sc:load` e `/sc:save`; sessão sem memória | 🔴 |
| `context7` | Desenhista/Executor escrevem API Convex/Clerk de memória | 🔴 |
| `MASTER.md` no projeto | A checagem de duplicidade da §7.1 deixa de existir — ela vem do `CLAUDE.md` do projeto, **não** do `/sc:pm` (que é o PM Agent do SuperClaude e não conhece `MASTER.md`); `prc-orquestrador` aborta `MASTER_AUSENTE` | 🔴 |
| `STACK.md` no projeto | Só o `dev-orquestrador-webapp` aborta `STACK_AUSENTE`; o `dev-idealizador-webapp` para sem veredito. Os outros 4 **seguem em frente sem a stack travada** — é o modo de falha silencioso a vigiar | 🔴 |
| `claude-in-chrome` | §5.2 — sem discovery, sem ver tela, sem testar front | 🟡 |
| Connector Railway | `dev-lancador-webapp` perde status, logs e alvo de rollback | 🟡 |
| `chrome-devtools` | Aprimorador perde Core Web Vitals; portão A→L reprova por falta de evidência | 🟡 |
| `uml` / `bpmn` | Portão D→E bloqueia: sem diagrama não há acoplamento | 🟡 |
| `magic` (hoje quebrado) | Degrada: componente shadcn escrito à mão | 🟢 |
| `morphllm` / `find-docs` | Degrada: edição manual / `context7` cobre | 🟢 |

---

## 7. Lacunas conhecidas

| Lacuna | Impacto | Correção |
|---|---|---|
| **`magic` falha ao conectar** | Desenhista e Executor perdem geração de componente. Degrada, não bloqueia | Reconfigurar com `API_KEY_21ST` válida, ou remover |
| **15 symlinks de skill quebrados** — 4 usados pelo setup | `explore`, `code-edit`, `feature-research`, `playwright-best-practices` não carregam | §3.2 |
| **MCP `playwright` ausente** | Baixo: os 3 casos migraram para `claude-in-chrome`. Só morde se pedir suíte E2E de CI | `claude mcp add playwright -- npx -y @playwright/mcp@latest` — ⚠️ nome do pacote **não verificado** |
| **MCP `tavily` ausente** | Médio para pesquisa: agentes de research caem em WebSearch. SuperClaude implanta `MCP_Tavily.md` mesmo assim | Exige `TAVILY_API_KEY`. Fora da esteira |
| **MCP `vercel` órfão** | Nenhum: config morta desde o retrofit, ainda pedindo auth | `claude mcp remove vercel` |
| **`IDEAL.md` e `META-SQUAD.md` ausentes** | 6 comandos `/ideal:*` apontam para o vazio | Criar, ou repoint para o `CLAUDE.md` do projeto |
| **`.orquestrador-ideal.md.swp`** | Nenhum: resíduo | `rm ~/.claude/agents/.orquestrador-ideal.md.swp` |

---

## 8. Verificação

Rode **a partir da raiz do projeto** — o último bloco usa caminhos relativos.

```bash
echo "— Claude Code —"; npm ls -g --depth=0 2>/dev/null | grep claude-code || echo "AUSENTE"
echo "— SuperClaude —"; superclaude --version 2>/dev/null || echo "AUSENTE"
echo "— comandos /sc: (esperado 30 + README) —"
  ls ~/.claude/commands/sc/*.md 2>/dev/null | grep -v '/README.md$' | wc -l
echo "— agentes .md (esperado 44) —"; ls ~/.claude/agents/*.md 2>/dev/null | wc -l
echo "— MCP user scope —"; jq -r '.mcpServers|keys[]' ~/.claude.json 2>/dev/null || echo "AUSENTE ~/.claude.json"
echo "— skills quebradas —"
  for s in ~/.claude/skills/*; do [ -L "$s" ] && [ ! -e "$s" ] && echo "QUEBRADA $(basename $s)"; done
echo "— skills da esteira —"; for s in uml bpmn use-railway railway-template find-docs; do
  [ -e ~/.claude/skills/$s ] && echo "ok $s" || echo "AUSENTE $s"; done
echo "— contrato em $PWD —"; for f in CLAUDE.md MASTER.md STACK.md; do
  [ -f "$f" ] && echo "ok $f" || echo "AUSENTE $f"; done
```

Conectividade real (inclui connectors, que não estão em disco):

```bash
claude mcp list
```

---

## 9. Instalação do zero, na ordem

```bash
# 1. Base
npm install -g @anthropic-ai/claude-code

# 2. Framework dos /sc: (minúsculas)
pipx install superclaude && superclaude install

# 3. MCP escopo user — ver §4.1 para os comandos com env
```

4. **Connectors** (§4.4) na claude.ai: `claude-in-chrome` (+ extensão do Chrome), Railway.
5. **Skills** (§3): instalar pelo gerenciador; conferir que nenhum symlink ficou quebrado.
6. **Agentes**: copiar os 24 manuais para `~/.claude/agents/` — não há pacote.
7. **Contrato**: `cp CLAUDE.md MASTER.md STACK.md /caminho/do/projeto/`
8. **Bootstrap** (`CLAUDE.md` §10): inventariar o projeto no `MASTER.md` antes de criar item.
