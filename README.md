# setup-prod

Contrato universal de criação — a esteira **IDEAL** aplicada a qualquer entregável:
software, feature, processo, procedimento, rotina, manual, produto, oferta, página.

Backup em nuvem do setup que vive em
`AAI - ORGANIZAÇÃO EMPRESARIAL/5 - AUTOMAÇÃO E IA/1. SETUP`.

## Os três arquivos

| Arquivo | Papel |
|---|---|
| `CLAUDE.md` | A esteira (I·D·E·A·L), o roteamento entre times, o Protocolo de Acoplamento e o de Iteração. Carregado em toda sessão — por isso é roteador, não enciclopédia. |
| `MASTER.md` | Mapa mestre do projeto: registro de todo item criado, versão, estado, interfaces e dependências. Índice e interfaces, nunca conteúdo. |
| `STACK.md` | Contrato da stack travada e suas fronteiras. Fonte **única** — nenhum agente repete a stack no próprio prompt. |

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

## O que NÃO está aqui

Os agentes dos times (`dev-*-webapp`, `prc-*`, meta-squad) vivem em `~/.claude/agents/` e não
fazem parte deste backup. Uma restauração a partir deste repositório traz o contrato, não o time.
