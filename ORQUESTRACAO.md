# ORQUESTRACAO.md — Catálogo de padrões

Quando usar cada forma de orquestração multi-agente, e **o que dizer** para acionar.
Roteamento de nível (solo / subagente / workflow) está no `CLAUDE.md` §5.4.

Leia este arquivo na hora de montar um workflow. Não é carregado em toda sessão.

> **Antes de montar, cheque o pronto:** `/code-review <nível>` (revisão adversarial do diff;
> `ultra` roda na nuvem) e `/security-review`. Montar um workflow para fazer o que um comando
> built-in já faz é desperdício.

---

## 1. Padrões de fase

Os nomes **não** colidem com as etapas IDEAL de propósito — "padrão Explorar" ≠ "etapa Desenhar".

| Padrão | Diga assim | A pergunta que ele responde | Forma |
|---|---|---|---|
| **Mapear** | *"mapeia isso com N leitores paralelos"* | "O que existe aqui?" — não há hipótese prévia | N leitores, um por subsistema → síntese |
| **Explorar** | *"gera N abordagens e põe juízes"* | "Qual caminho seguir?" — as alternativas **ainda não existem** | N abordagens geradas em paralelo, sem se verem → juízes pontuam → sintetiza da vencedora enxertando o melhor das outras |
| **Julgar** | *"põe N juízes nessas opções"* | "Qual destas é melhor?" — as candidatas **já existem** | N juízes independentes pontuam cada candidata → síntese |
| **Refutar** | *"roda um review adversarial"* | "Isto está certo?" — existe artefato concreto a julgar | Dimensões (bug, perf, segurança, teste) → cada achado verificado por céticos |
| **Investigar** | *"pesquisa isso por ângulos diferentes"* | "O que se sabe fora daqui?" | Varredura multi-ângulo → leitura profunda → síntese com fontes |
| **Migrar** | *"descobre, transforma e verifica cada ocorrência"* | "Como mudo N lugares sem quebrar?" | Descobrir ocorrências → transformar cada uma → verificar |

### Regra de corte — rename não é Migrar

Renomear símbolo com suporte de LSP é **operação única**, independente do número de arquivos:
`mcp__serena__rename_symbol`. Solo, não workflow.

**Migrar** só quando a transformação exige julgamento por ocorrência: a assinatura muda, o
chamador precisa adaptar, ou há casos que não devem mudar.

---

## 2. Padrões de qualidade

Compõem **dentro** de qualquer padrão de fase.

| Padrão | Diga assim | O que faz | Quando importa |
|---|---|---|---|
| **Verificação adversarial** | *"verifica adversarialmente"* | N céticos independentes tentam **refutar** cada achado; morre se a maioria refuta | Sempre que uma afirmação vai virar decisão. Pegou 26 erros no `REQUIREMENTS.md` e 32 na §5.4 do `CLAUDE.md` |
| **Lentes diversas** | *"verifica por lentes diferentes"* | Cada verificador recebe uma lente distinta (correção, segurança, reproduz?) em vez de N iguais | O achado pode falhar de mais de um jeito |
| **Loop até secar** | *"continua até secar"* | Busca até K rodadas seguidas sem achado novo | Descoberta de tamanho desconhecido — contador fixo perde a cauda |
| **Varredura multi-modal** | *"varredura multi-modal"* | Agentes buscando por eixos diferentes: por container, por conteúdo, por entidade, por tempo | Um ângulo de busca sozinho não acha tudo |
| **Crítico de completude** | *"passa um crítico de completude"* | Agente final pergunta "o que ficou de fora?" | Fecha a rodada; o que ele achar vira a próxima |

---

## 3. Onde encaixa na esteira

| Etapa IDEAL | Padrão natural |
|---|---|
| Idealizar | **Investigar** + varredura multi-modal |
| Desenhar | **Explorar** (alternativas novas) ou **Julgar** (candidatas já existem) |
| Executar | **Migrar**, quando é mudança ampla |
| Aprimorar | **Refutar** + verificação adversarial ← **o de maior retorno** |
| Lançar | **Crítico de completude** contra os portões da §3 |

Estes rodam **dentro** da esteira, sem autorização adicional — o `/sc:pm` já é o comando que
manda (`CLAUDE.md` §2). A regra de acionamento da §5.4 vale para orquestração fora da esteira.

---

## 4. Regras operacionais

**Barreira só quando a etapa seguinte precisa de todos os resultados juntos.** Deduplicar antes
de verificar, abortar se o total for zero, comparar um achado com os demais — isso é barreira
legítima. "Preciso achatar a lista" não é: transforme dentro da etapa. Sem necessidade de
barreira, cada item corre o percurso inteiro sem esperar os outros, e o tempo total é o do item
mais lento, não a soma das etapas.

**Escrita em paralelo vai isolada.** Leitura paralela é livre. Dois agentes editando a mesma
árvore se sobrescrevem em silêncio — e o `CLAUDE.md` §5.3 lembra que outros chats usam esta mesma
árvore. Fan-out que escreve roda em worktree isolada, uma por agente.

**Sem teto silencioso.** Limitou algo (top-N, amostragem, corte por tempo)? Declare no resultado
o que ficou de fora.

**Escale ao pedido.** "Acha bugs" → poucos buscadores, voto simples. "Seja exaustivo" / auditoria
→ mais buscadores, 3–5 votos adversariais, síntese no fim.

**Não confie no relatório do agente.** Verificador também erra — nesta casa dois se contradisseram
sobre um limite de concorrência, e um refutou uma afirmação correta. Achado que vira decisão passa
por conferência própria antes de virar edição.

Limites de concorrência, tamanho de workflow e teto de agentes são da ferramenta e mudam com
máquina e versão. Consulte na hora; não fixe números em documento. `/workflows` acompanha as
execuções, que rodam em background.
