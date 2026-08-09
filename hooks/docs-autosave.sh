#!/usr/bin/env bash
# docs-autosave — hook Stop: salva documentação numa branch por sessão.
#
# Objetivo: recuperar plano/status após bug, queda de energia ou fechar o chat.
#
# Invariantes (nesta ordem de importância):
#   1. NUNCA troca de branch, nunca escreve no working tree, nunca mexe no índice
#      principal. Usa plumbing + GIT_INDEX_FILE. Outro chat pode estar trabalhando
#      no mesmo diretório.
#   2. Uma branch por sessão (docs-auto/<id>) — dois chats nunca disputam o mesmo
#      ref, então o hook jamais precisa resolver conflito sem humano.
#   3. Só documentação. Nunca código.
#   4. Nunca quebra o turno. Toda falha sai com 0.
#
# Opt-in por repositório: só age onde existe MASTER.md (contrato da esteira IDEAL).

set -uo pipefail

payload=$(cat 2>/dev/null || echo '{}')

command -v git >/dev/null 2>&1 || exit 0
command -v jq  >/dev/null 2>&1 || exit 0

cwd=$(printf '%s' "$payload" | jq -r '.cwd // empty' 2>/dev/null)
[ -n "$cwd" ] || cwd="$PWD"
cd "$cwd" 2>/dev/null || exit 0

# --- portões de entrada -------------------------------------------------------
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$root" 2>/dev/null || exit 0

# opt-in: repositório sem o contrato IDEAL é ignorado em silêncio
[ -f MASTER.md ] || exit 0

# precisa de um HEAD com commit (repo recém-init não serve)
git rev-parse --verify HEAD >/dev/null 2>&1 || exit 0

sid=$(printf '%s' "$payload" | jq -r '.session_id // empty' 2>/dev/null \
      | tr -cd 'a-zA-Z0-9' | cut -c1-12)
[ -n "$sid" ] || sid="nosession"
branch="docs-auto/$sid"

# --- o que conta como documentação -------------------------------------------
paths=()
for p in docs claudedocs CLAUDE.md MASTER.md STACK.md REQUIREMENTS.md; do
  [ -e "$p" ] && paths+=("$p")
done
[ ${#paths[@]} -gt 0 ] || exit 0

# --- índice temporário: não disputa .git/index com ninguém --------------------
tmpindex=$(mktemp -t docsauto.XXXXXX 2>/dev/null) || exit 0
rm -f "$tmpindex"                      # git quer criar ele mesmo
export GIT_INDEX_FILE="$tmpindex"
trap 'rm -f "$tmpindex"' EXIT

# base do commit: a branch da sessão se já existe, senão o HEAD atual
if git show-ref --verify --quiet "refs/heads/$branch"; then
  parent=$(git rev-parse "refs/heads/$branch" 2>/dev/null) || exit 0
else
  parent=$(git rev-parse HEAD 2>/dev/null) || exit 0
fi

git read-tree "$parent" 2>/dev/null || exit 0
git add -A -- "${paths[@]}" 2>/dev/null || exit 0

tree=$(git write-tree 2>/dev/null) || exit 0
[ -n "$tree" ] || exit 0

# nada mudou desde o último autosave → não polui o histórico
if [ "$tree" = "$(git rev-parse "$parent^{tree}" 2>/dev/null)" ]; then
  exit 0
fi

stamp=$(date '+%Y-%m-%d %H:%M:%S')
commit=$(printf 'docs: autosave %s\n\nSessao: %s\nBranch de origem: %s\n' \
           "$stamp" "$sid" "$(git rev-parse --abbrev-ref HEAD 2>/dev/null)" \
         | git commit-tree "$tree" -p "$parent" 2>/dev/null) || exit 0
[ -n "$commit" ] || exit 0

# compare-and-swap: só move o ref se ninguém o moveu desde que lemos
if git show-ref --verify --quiet "refs/heads/$branch"; then
  git update-ref "refs/heads/$branch" "$commit" "$parent" 2>/dev/null || exit 0
else
  git update-ref "refs/heads/$branch" "$commit" "" 2>/dev/null || exit 0
fi

# --- push (o backup em si) ----------------------------------------------------
git remote get-url origin >/dev/null 2>&1 || exit 0   # sem remoto: commit local basta

if ! git push -q origin "refs/heads/$branch:refs/heads/$branch" 2>/dev/null; then
  # commit local existe (recuperável), mas o backup remoto falhou — avise
  printf '{"systemMessage":"docs-autosave: commit local em %s ok, push falhou (sem rede?). Rode: git push origin %s"}\n' \
    "$branch" "$branch"
fi

exit 0
