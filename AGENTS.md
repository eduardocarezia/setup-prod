# AGENTS.md — Porta de entrada, qualquer ferramenta

Arquivo neutro. Claude Code, Cursor, Codex e qualquer agente que leia `AGENTS.md` começa aqui.

**O contrato é o `CLAUDE.md`.** Leia-o. Este arquivo só diz o que dele vale na ferramenta que
você está usando — e o que não vale.

> Referência, não cópia (`CLAUDE.md` §0.1). Nada aqui repete conteúdo de lá. Se você está
> prestes a copiar uma regra do `CLAUDE.md` para cá ou para `.cursor/rules/`: pare. Duplicar
> garante que as duas versões vão divergir, e ninguém vai saber qual manda.

---

## 1. Fonte de verdade — vale em toda ferramenta

| Arquivo | Papel |
|---|---|
| `CLAUDE.md` | A esteira IDEAL, protocolos de acoplamento e iteração, regras de conduta |
| `MASTER.md` | Registro de tudo que existe no projeto, com versão, estado e interfaces |
| `STACK.md` | Stack travada e suas fronteiras |
| `ORQUESTRACAO.md` | Catálogo de padrões multi-agente (só operável no Claude Code) |
| `HOOKS.md` | Automação de harness (só Claude Code) |
| `REQUIREMENTS.md` | Dependências do setup, com estado verificado |

---

## 2. O que vale em qualquer ferramenta

| Seção do `CLAUDE.md` | Por que transfere |
|---|---|
| **§0.1** referência, não cópia | Disciplina de documento, independe de ferramenta |
| **§0.2** entregar, não interrogar | Conduta. Vale igual no Cursor |
| **§0.3** autoanálise, detector de repetição | idem |
| **§1** fonte de verdade | Os arquivos são os mesmos |
| **§5.1** diagramas: saída em fence `plantuml`, um arquivo por item, nós com nome real do `MASTER.md` | Convenção de formato — PlantUML é texto |
| **§5.3** git sempre na `main`, nunca criar nem trocar de branch | **Crítico**: o working tree é compartilhado. Cursor e Claude Code podem estar abertos no mesmo diretório ao mesmo tempo |
| **§6** ID, pasta `docs/ideal/<ID>-<slug>/`, estados | Estrutura de arquivo |
| **§7** Protocolo de Acoplamento | O `MASTER.md` é o mesmo |
| **§8** Protocolo de Iteração | idem |
| **§9** anti-padrões | idem |
| **`STACK.md` inteiro** | Fronteiras da stack não mudam com o editor |

---

## 3. O que é só Claude Code

Não tente reproduzir no Cursor. Não existe equivalente, e fingir que existe produz alucinação.

| Seção | Depende de |
|---|---|
| **§2** `/sc:pm` e os três times | SuperClaude + subagentes |
| **§3** mapeamento das etapas para `/sc:*` | SuperClaude |
| **§4** paralelismo de subagentes na etapa | subagentes |
| **§5.2** `claude-in-chrome` | MCP + extensão |
| **§5.4** e `ORQUESTRACAO.md` | workflows dinâmicos |
| `HOOKS.md` | hooks do harness |

**No Cursor, a esteira IDEAL vira disciplina manual, não orquestração.** As 5 etapas e os
portões continuam valendo como sequência de trabalho; o que você perde é quem as conduz
automaticamente. Faça as etapas na ordem, produza os mesmos artefatos numerados em
`docs/ideal/<ID>-<slug>/`, e o `MASTER.md` fica consistente entre as duas ferramentas.

Diagrama sem a skill `uml`/`bpmn`: escreva PlantUML à mão, respeitando a `§5.1`. O formato é
que importa para o acoplamento, não a skill.

---

## 4. Trabalhando nas duas ao mesmo tempo

Este é o risco real, e não é teórico.

1. **Nunca troque de branch em nenhuma das duas.** `CLAUDE.md` §5.3. As duas compartilham
   o mesmo working tree — `git checkout` numa arranca o trabalho da outra.
2. **Commit incremental é o ponto de restauração.** Antes de operação grande, commite.
3. **Se as duas editarem o mesmo arquivo**, a última escrita ganha em silêncio. Divida por
   arquivo, não por linha.
4. **O `MASTER.md` é o ponto de encontro.** Qualquer uma das duas que fechar um item atualiza
   o Registro. Quem abrir depois lê de lá o estado real.
