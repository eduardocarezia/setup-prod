# setup-prod

Contrato universal de criação — a esteira **IDEAL** aplicada a qualquer entregável:
software, feature, processo, procedimento, rotina, manual, produto, oferta, página.

Backup em nuvem do setup que vive em
`AAI - ORGANIZAÇÃO EMPRESARIAL/5 - AUTOMAÇÃO E IA/1. SETUP` e em `~/.claude/`.

## Conteúdo

### Contrato — vai para a raiz de cada projeto

| Arquivo | Papel |
|---|---|
| `CLAUDE.md` | A esteira (I·D·E·A·L), roteamento entre times, padrões de ferramenta (diagramas §5.1, navegador §5.2), Protocolo de Acoplamento (§7) e de Iteração (§8). Carregado em toda sessão — por isso é roteador, não enciclopédia. |
| `MASTER.md` | Mapa mestre do projeto: registro de todo item criado, versão, estado, interfaces, dependências. Índice e interfaces, nunca conteúdo. |
| `STACK.md` | Contrato da stack travada e suas fronteiras. Fonte **única** — nenhum agente repete a stack no próprio prompt. |
| `REQUIREMENTS.md` | Tudo que precisa existir para o setup funcionar, com o estado real verificado em disco: versões, origens, lacunas conhecidas e script de verificação. |

### `agents/` — 25 agentes que **não** têm pacote

Os especialistas do SuperClaude são reinstaláveis (`superclaude install`). Estes não:
se sumirem do disco, só existem aqui.

| Grupo | Agentes |
|---|---|
| Time de Sistemas | `dev-*-webapp` (6) — stack travada Railway/Convex/Clerk/Next |
| Time de Processos | `prc-*` (6) — BPMN + SOP + decisão de rota |
| Meta-squad | `orquestrador-ideal` + fases (6) — processo → squad de IA |
| Dev genérico | `dev-*` (6) — fallback stack-agnostic |
| Customizado | `deep-research-agent` (1) — **vem** do SuperClaude, mas carrega edição local (roteamento para `claude-in-chrome`). Um `superclaude install` sobrescreve; restaure daqui. |

Restauração: `cp agents/*.md ~/.claude/agents/`

### `hooks/` — automação

| Arquivo | O que faz |
|---|---|
| `docs-autosave.sh` | Hook `Stop`: commita e faz push da documentação numa branch por sessão (`docs-auto/<id>`). Nunca troca de branch, nunca toca o working tree, seguro com vários chats simultâneos. Opt-in por repositório: só age onde existe `MASTER.md`. |

Instalação: copiar para `~/.claude/hooks/`, `chmod +x`, e registrar em `~/.claude/settings.json`:

```json
{
  "hooks": {
    "Stop": [
      { "hooks": [ { "type": "command", "command": "bash ~/.claude/hooks/docs-autosave.sh", "timeout": 45 } ] }
    ]
  }
}
```

## Stack travada

| Camada | Ferramenta |
|---|---|
| Hospedagem | Railway (container Docker) |
| Backend / dados | Convex |
| Autenticação | Clerk (integrado ao Convex) |
| Frontend | React + Next.js (App Router) + shadcn/ui |

## Instalar num projeto

```bash
cp CLAUDE.md MASTER.md STACK.md /caminho/do/projeto/
```

Depois rode o Bootstrap (`CLAUDE.md` §10): inventarie no `MASTER.md` o que o projeto já tem
**antes** de criar item novo. Acoplar sobre um mapa vazio produz um mapa que mente.

## O que ainda não está aqui

- Os 20 especialistas do SuperClaude — reinstaláveis por pacote, ver `REQUIREMENTS.md` §2.
- Comandos `/sc:*` e `/ideal:*` — idem.
- Configuração de MCP (`~/.claude.json`) — contém chaves; ver `REQUIREMENTS.md` §4 para recriar.
- `~/.claude/settings.json` completo — contém preferências pessoais.
