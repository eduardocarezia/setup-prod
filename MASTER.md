# MASTER.md — Mapa Mestre

Índice único de tudo que existe neste projeto. Todo item criado pela esteira IDEAL
(ver `CLAUDE.md`) é acoplado aqui na etapa **Lançar**.

> **Este arquivo guarda índice e interfaces — nunca conteúdo.**
> O conteúdo mora em `docs/ideal/<ID>-<slug>/`. Inflar este arquivo infla toda sessão.

**Projeto:** `<nome>`
**Última atualização:** `<AAAA-MM-DD>`
**Próximos IDs livres:** SW-001 · PRC-001 · PRD-001 · DOC-001 · PAG-001

---

## 1. Registro

Uma linha por item. Ordene por ID. Nunca recicle ID.

| ID | Nome | Tipo | Ver. | Estado | Dono | Entrada | Saída | Depende de | Usado por | Pasta | Diagrama | Atualizado |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| — | _vazio: rode o inventário do Bootstrap_ | | | | | | | | | | | |

**Tipos:** `SW` software/feature · `PRC` processo/rotina · `PRD` produto/oferta · `DOC` manual/política · `PAG` página/ativo

**Estados:** `idealizando` → `desenhando` → `executando` → `aprimorando` → `lançado` → `depreciado`

Regras da tabela:
- `Entrada` / `Saída` em termos concretos (artefato, formato, gatilho). "Melhora o processo" não é saída.
- `Depende de` e `Usado por` são espelhos: se A depende de B, B é usado por A. As duas linhas mudam juntas.
- `Atualizado` = data do último acoplamento, não da última conversa.

---

## 2. Dependências

Grafo de acoplamento. Deve bater com a coluna `Depende de` do Registro — divergência aqui é bug.

```plantuml
@startuml
left to right direction
skinparam componentStyle rectangle

' Exemplo (substituir):
' [PRC-001 Captação de lead] --> [SW-001 Formulário do site]
' [SW-001 Formulário do site] --> [SW-002 Integração CRM]

@enduml
```

**Itens órfãos** (sem `Depende de` e sem `Usado por`): liste aqui e justifique.
Órfão sem justificativa é sinal de item esquecido ou duplicado.

- _(nenhum)_

---

## 3. Diagramas mestres

| Arquivo | Cobre | Skill | Atualizar quando |
|---|---|---|---|
| `docs/diagramas/mestre.puml` | Todos os `PRC`, `PRD`, `DOC` | `bpmn` | Acoplar ou versionar item desses tipos |
| `docs/diagramas/arquitetura.puml` | Todos os `SW`, `PAG` | `uml` | Acoplar ou versionar item desses tipos |
| `docs/diagramas/<ID>.puml` | Um item específico | `bpmn` ou `uml` conforme §5 do CLAUDE.md | Etapa Desenhar do item |

Nó no diagrama mestre sem linha no Registro (ou o contrário) = acoplamento quebrado. Corrija antes de seguir.

---

## 4. Convenções deste projeto

Preencha uma vez, no Bootstrap. Curto — se ficar longo, vira documento próprio e fica só o link.

- **Idioma dos artefatos:** `<pt-BR>`
- **Stack / ferramentas padrão:** `<...>`
- **Nomenclatura de arquivos:** `<...>`
- **Onde vive o entregável real** (código, planilha, Notion, Drive): `<...>`
- **Dono padrão / responsável por aprovar portão:** `<...>`
- **Documentos externos que são fonte de verdade:** `<link>` — referenciar, não copiar

---

## 5. Fila

Itens que ainda não entraram na esteira. Sai daqui quando `/sc:pm` abre o `01-idealizar.md`.

| Pedido | Tipo provável | Prioridade | Aberto em |
|---|---|---|---|
| — | | | |

---

## 6. Histórico de acoplamentos

Append-only. Uma linha por acoplamento ou versionamento. Nunca reescreva linha antiga.

| Data | ID | Ver. | O que mudou | Reentrou em | Impacto em |
|---|---|---|---|---|---|
| — | | | | | |
