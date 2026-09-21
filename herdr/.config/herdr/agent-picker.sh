#!/usr/bin/env bash
# prefix+. then a digit jumps to that agent. herdr has no chord sequences and no
# agent navigate mode, so the second step lives here: the popup prints the
# numbered list and reads one key. The numbers are on screen, which is the part
# herdr's own indexed bindings cannot do -- it rejects bracketed agent names.
# A digit jumps, f falls back to fzf by name, anything else cancels.
set -euo pipefail

dir=$(dirname "$(readlink -f "$0")")
rows=$({ herdr agent list; herdr workspace list; herdr tab list; } | python3 "$dir/agent-picker.py")
[ -n "$rows" ] || { echo "no agents"; read -r -n1 -s; exit 0; }

printf '\033[1magents\033[0m  -  digit jumps, f finds, any other key cancels\n\n'
n=0
while IFS=$'\t' read -r label task pane; do
  n=$((n + 1))
  printf '  \033[1m%d\033[0m  %s\n' "$n" "$label"
done <<< "$rows"
printf '\n'

read -r -n1 -s key || exit 0

case "$key" in
  [1-9])
    pane=$(sed -n "${key}p" <<< "$rows" | cut -f3)
    [ -n "$pane" ] && herdr agent focus "$pane" >/dev/null
    ;;
  f)
    sel=$(fzf --delimiter=$'\t' --with-nth=1,2 --layout=reverse --height=100% \
              --info=inline --bind='ctrl-j:down,ctrl-k:up' \
              --prompt='agent > ' --header='enter jumps · esc cancels' <<< "$rows") || exit 0
    [ -n "$sel" ] && herdr agent focus "$(cut -f3 <<< "$sel")" >/dev/null
    ;;
esac
