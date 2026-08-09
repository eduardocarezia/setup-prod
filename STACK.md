# STACK.md — Contrato de Stack Travada

Fonte **única** da stack. Todo agente do time de sistemas lê este arquivo.
**Nenhum agente repete a stack no próprio prompt** — foi assim que o deploy derivou para Vercel.

> Se você é um agente e este arquivo não existe na raiz do projeto: **pare** e peça o Bootstrap
> (`CLAUDE.md` §10). Não deduza a stack.

---

## 1. As quatro camadas

| Camada | Ferramenta | Dono de |
|---|---|---|
| Hospedagem | **Railway** | Container Docker, env vars, domínio, logs, métricas, rollback |
| Backend / Dados | **Convex** | Banco reativo, queries/mutations/actions, agentes, automações, chamadas a APIs externas, file storage, cron |
| Autenticação | **Clerk** | Identidade, sessão, JWT para o Convex, middleware de rota |
| Frontend | **React + Next.js (App Router) + shadcn/ui** | UI, rotas, componentes, Tailwind |

**Travado** significa: não se propõe alternativa, não se compara, não se "avalia se vale a pena".
Pedido que exige sair daqui → veredito **não** na fase Idealizar, com a fronteira citada.

---

## 2. Fronteiras — o que é proibido

| Proibido | Porque | Faça em vez disso |
|---|---|---|
| Vercel, Netlify, Fly, AWS, Render | Hospedagem é Railway | Container no Railway |
| Postgres, Supabase, Mongo, Prisma, Drizzle | Dados são Convex | Tabela em `convex/schema.ts` |
| NextAuth, Auth0, Lucia, auth caseiro | Auth é Clerk | Clerk + `ctx.auth` |
| API REST custom, `app/api/*` para dados | Convex já é o backend | `useQuery` / `useMutation` / `useAction` |
| MUI, Chakra, Bootstrap, Ant | Componentes são shadcn | `npx shadcn@latest add <componente>` |
| shadcn como dependência npm | shadcn é copy-paste | Arquivos em `components/ui/` |
| `pages/` router | App Router | `app/` |
| Cron externo, n8n para agendar | Convex tem cron | `convex/crons.ts` |
| Chamar API externa de dentro de `query`/`mutation` | Só `action` faz I/O externo | `action()` → salva via mutation interna |

Exceção só existe com decisão humana registrada no `MASTER.md`.

---

## 3. Regras do Convex

- **Sem JOIN.** Desnormalize ou faça múltiplas queries. Pedido com JOIN → recorte ou desnormalização.
- **Sem offset/skip.** Paginação é por cursor: `paginate({ numItems, cursor })` → `{ page, isDone, continueCursor }`.
- **Sem recursão nativa.** Estruturas em árvore levam campo `depth` com teto (recomendado 3).
- `query` / `mutation` = puros e transacionais. I/O externo só em `action`.
- Args sempre com validators explícitos (`v.object({...})`). Nunca campo "a definir".
- Tipos vêm do Convex: `Doc<"tabela">`, `Id<"tabela">`. Não recriar tipo à mão.
- Toda `mutation` e `action` que escreve verifica identidade antes (§4).
- Busca: `searchIndex` (texto) e `vectorIndex` (semântica) são nativos — não instale motor de busca.
- Agendamento: `convex/crons.ts`, `scheduler.runAfter()`, `scheduler.runAt()`.

---

## 4. Wiring Clerk ↔ Convex

Esta é a integração que mais quebra. Formato canônico abaixo — **confirme a sintaxe atual via
Context7 (`resolve-library-id "convex"` / `"clerk"`) antes de implementar.** As APIs mudam;
o que está aqui é a forma da solução, não a garantia da assinatura.

**Peças obrigatórias — faltando uma, a auth falha silenciosa ou em runtime:**

1. **JWT template no Clerk** com o nome `convex`. Sem isso o Convex rejeita o token.
2. **`convex/auth.config.ts`** declarando o issuer domain do Clerk e `applicationID: "convex"`.
3. **Provider aninhado na ordem certa** — `ClerkProvider` por **fora**, `ConvexProviderWithClerk`
   (de `convex/react-clerk`) por dentro, recebendo o `useAuth` do Clerk. Ordem invertida = sessão nunca chega no Convex.
4. **`middleware.ts`** na raiz com o middleware do Clerk e `matcher` cobrindo as rotas protegidas.
5. **Identidade no backend** — `await ctx.auth.getUserIdentity()`. Retorna `null` se não autenticado.
   `identity.subject` é o ID do usuário no Clerk.
6. **Tabela `users` espelhada** (quando precisar de dados próprios do usuário): campo `clerkId`
   com índice `by_clerk_id`, populada por webhook do Clerk num `httpAction` do Convex.

**Padrão de checagem em toda mutation/action que escreve:**

```typescript
const identity = await ctx.auth.getUserIdentity()
if (!identity) throw new ConvexError("Não autenticado")
// identity.subject === Clerk user id
```

**Erros clássicos:** template JWT com nome diferente de `convex` · provider na ordem invertida ·
`CLERK_JWT_ISSUER_DOMAIN` ausente no deployment Convex · confiar em `userId` vindo do cliente
como argumento em vez de ler de `ctx.auth`.

---

## 5. Deploy no Railway

Frontend Next.js roda **em container**, não em serverless. Consequências que o desenho precisa absorver:

- `next.config` com `output: "standalone"` — sem isso a imagem fica enorme.
- O container **precisa escutar a porta do env `PORT`** que a Railway injeta. Porta fixa = deploy sobe e não responde.
- Healthcheck configurado — sem ele a Railway não sabe distinguir "subindo" de "quebrado".
- Build multi-stage no Dockerfile (deps → build → runner) para imagem enxuta.
- Backend Convex **não** vai para a Railway: roda no Convex Cloud, deployado por `npx convex deploy`.
  A Railway hospeda só o Next.js.

**Variáveis de ambiente:**

| Variável | Onde | Para quê |
|---|---|---|
| `NEXT_PUBLIC_CONVEX_URL` | Railway | Cliente encontra o backend |
| `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY` | Railway | Clerk no browser |
| `CLERK_SECRET_KEY` | Railway | Clerk no servidor |
| `CLERK_JWT_ISSUER_DOMAIN` | **Deployment Convex** | Convex valida o JWT |
| `CLERK_WEBHOOK_SECRET` | **Deployment Convex** | Valida webhook de sync de usuário |
| `CONVEX_DEPLOY_KEY` | CI | `convex deploy` no pipeline |

Variável do Convex configurada na Railway (ou o inverso) é o erro mais comum aqui. As duas
plataformas têm painéis de env separados.

**Ordem de deploy — inverter derruba produção:** `convex deploy` (backend) **primeiro**,
Railway (frontend) depois. O frontend novo pode exigir campo que só existe no schema novo.

**Rollback:** Railway → redeploy do deployment anterior. Convex → o schema é o ponto de não-retorno;
migração destrutiva precisa de plano de reversão escrito **antes** de aplicar.

---

## 6. Frontend

- Server Components por padrão. `"use client"` só quando há hook, estado ou evento — e é declarado no desenho.
- Hooks do Convex (`useQuery`, `useMutation`, `useAction`) são client-side. Componente que usa → é CC.
- Para dados no servidor: `preloadQuery` e passe para o CC.
- shadcn instalado via `npx shadcn@latest add <componente>`, arquivos em `components/ui/`, versionados.
- Tailwind para estilo. Sem CSS-in-JS.
- Props tipadas com os tipos do Convex (`Doc<>`, `Id<>`).

---

## 7. Ferramentas por camada

| Camada | MCP | Skill |
|---|---|---|
| Railway | `mcp__*railway*` (status, logs, variáveis, deploy, métricas) | `use-railway`, `railway-template` |
| Convex | `context7` (`resolve-library-id "convex"`) | `find-docs` |
| Clerk | `context7` (`resolve-library-id "clerk"`) | `find-docs` |
| Next / React | `context7` | `find-docs` |
| shadcn | `mcp__Shadcn_UI__*` (list/get component, blocks, themes) | — |
| Ver, explorar, testar no browser | **`claude-in-chrome`** | — |
| Medir performance no browser | `chrome-devtools` | — |
| Suíte E2E versionada para CI | `playwright` (só se o entregável é o teste) | `playwright-best-practices` |

**Regra:** antes de escrever qualquer API de Convex, Clerk ou Next — consulte Context7.
Conhecimento de treino sobre estas quatro ferramentas envelhece rápido.

**Regra:** toda interação real com navegador é `claude-in-chrome` (`CLAUDE.md` §5.2).
Se precisar estudar documentação viva, ver a tela ou testar um fluxo — é lá.

---

## 8. Manutenção deste arquivo

Mudou a stack? Muda **aqui**, e só aqui. Depois verifique que nenhum agente voltou a copiar
a stack no próprio prompt:

```bash
grep -rin "vercel\|supabase\|nextauth\|postgres\|auth0" ~/.claude/agents/dev-*-webapp.md
```

Não espere retorno vazio: citar ferramenta proibida **como exemplo de rejeição** é correto e
desejável. Leia cada ocorrência e confirme que está em contexto de fronteira ("não", "proibido",
"fronteira"). Ocorrência em contexto de instrução — "faça deploy na X", "use Y para auth" — é
que é o vazamento. Esse é o teste.
