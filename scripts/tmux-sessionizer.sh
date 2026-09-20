#!/usr/bin/env bash
# Jump to a session per directory: pick a directory, get a tmux session named
# after it, create it the first time. Bound to `prefix C-f` in tmux.conf, where
# it runs inside a popup.
#
# Candidates come from zoxide, so the list is ordered by where you actually
# work instead of by a hardcoded projects root. A directory can also be passed
# as $1, which is how you'd call it from a shell.
set -euo pipefail

if [[ $# -eq 1 ]]; then
    dir=$1
else
    dir=$(zoxide query -l | fzf --prompt="session > " --height=100% --reverse) || exit 0
fi
[[ -n ${dir:-} && -d $dir ]] || exit 0

# tmux treats dots as part of its target syntax (session:window.pane), so they
# cannot appear in a session name.
name=$(basename "$dir" | tr '. ' '__')

if ! tmux has-session -t "=$name" 2>/dev/null; then
    tmux new-session -ds "$name" -c "$dir"
fi

if [[ -n ${TMUX:-} ]]; then
    # If there is no client to move (a detached server, i.e. when scripted),
    # creating the session was the useful half - don't fail over the rest.
    tmux switch-client -t "=$name" 2>/dev/null || true
else
    tmux attach -t "=$name"
fi
