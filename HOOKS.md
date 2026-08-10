# HOOKS.md — Automação de harness

Configuração de hooks para copiar e colar. Hook é o que o **harness** executa; regra em
`CLAUDE.md` depende de eu lembrar. Para "sempre que X, faça Y", só hook garante.

---

## 1. `docs-autosave` — salva documentação a cada resposta

Recupera plano de ação, status de feature e diagramas depois de bug, queda de energia ou
fechar o chat sem querer.

### Passo 1 — o script

Copie [`hooks/docs-autosave.sh`](hooks/docs-autosave.sh) para `~/.claude/hooks/` e dê permissão:

```bash
mkdir -p ~/.claude/hooks
cp hooks/docs-autosave.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/docs-autosave.sh
```

### Passo 2 — registre em `~/.claude/settings.json`

**Cole dentro do objeto raiz.** Se já existe a chave `"hooks"`, mescle — não substitua:

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/docs-autosave.sh",
            "timeout": 45,
            "statusMessage": "Salvando documentação..."
          }
        ]
      }
    ]
  }
}
```

### Passo 3 — valide

```bash
jq -e '.hooks.Stop[] | .hooks[] | select(.type=="command") | .command' ~/.claude/settings.json
```

Exit 0 e imprime o comando = registrado. Exit 5 = JSON malformado — e **um `settings.json`
quebrado desativa todos os settings daquele arquivo em silêncio**, então conserte antes de seguir.

Hooks `Stop` disparam fora do turno atual. Se nada acontecer na primeira sessão, o watcher de
config não recarregou: abra `/hooks` uma vez ou reinicie o Claude Code.

---

## 2. O que ele faz

Ao fim de cada resposta, num repositório que tenha `MASTER.md`:

1. Monta um commit com `docs/`, `claudedocs/`, `CLAUDE.md`, `MASTER.md`, `STACK.md`, `REQUIREMENTS.md`
2. Grava em `refs/docs-autosave/<sessão>`
3. Faz push desse ref para o `origin`

Nada mudou desde o último autosave → não commita.

### Invariantes (nesta ordem de importância)

| # | Garantia | Como |
|---|---|---|
| 1 | Nunca troca de branch nem escreve no working tree | Plumbing: `read-tree` → `write-tree` → `commit-tree` → `update-ref`. O working tree é só lido |
| 2 | Não é branch | Grava em `refs/docs-autosave/`, fora de `refs/heads/`. Não aparece em `git branch`, nunca sofre checkout — respeita a `§5.3` do `CLAUDE.md` |
| 3 | Não disputa `.git/index` | Índice temporário via `GIT_INDEX_FILE` |
| 4 | Vários chats em paralelo não colidem | Um ref por sessão + compare-and-swap no `update-ref`. O hook nunca precisa resolver merge sem humano |
| 5 | Nunca leva código | Só os caminhos de documentação. Alteração de código não commitada fica intacta |
| 6 | Nunca quebra o turno | Todo caminho de erro sai com `0` |

Testado: dois chats simultâneos no mesmo diretório, com código modificado não commitado —
`git branch` continuou só com `main`, `index.lock` não travou, o código em andamento não vazou.

### Opt-in por repositório

Só age onde existe `MASTER.md` na raiz do repo. Projeto fora da esteira IDEAL é ignorado em
silêncio. Para pausar num projeto específico sem desligar o hook:

```bash
mv MASTER.md MASTER.md.off
```

---

## 3. Recuperar depois de uma queda

```bash
# refs salvos no remoto, mais recente primeiro
git ls-remote origin 'refs/docs-autosave/*'

# trazer para inspecionar
git fetch origin 'refs/docs-autosave/*:refs/docs-autosave/*'
git for-each-ref --sort=-committerdate --format='%(refname) %(committerdate:relative)' refs/docs-autosave

# ver o que tem dentro, sem checkout
git show refs/docs-autosave/<sessao> --stat
git show refs/docs-autosave/<sessao>:docs/ideal/SW-001/01-idealizar.md

# restaurar um arquivo específico para o working tree
git checkout refs/docs-autosave/<sessao> -- docs/ideal/SW-001/01-idealizar.md
```

O último comando é a única operação que toca o working tree, e é você quem roda.

### Limpar refs antigos

```bash
git for-each-ref --format='%(refname)' refs/docs-autosave | xargs -n1 git update-ref -d
git push origin --delete 'refs/docs-autosave/<sessao>'
```

---

## 4. Desligar

Remova o bloco `"hooks"` do `~/.claude/settings.json`, ou desative tudo de uma vez:

```json
{ "disableAllHooks": true }
```

`disableAllHooks` também desliga a status line. Para desativar só este hook, remova o bloco.
