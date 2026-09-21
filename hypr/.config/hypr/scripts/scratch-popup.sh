#!/bin/bash
# Floating scratch pad on a special workspace (bound to Alt+S / Alt+Shift+S).
#
# If the pad is already running, toggle it in and out of view. Otherwise
# start one running `scratch` (new draft) or `note` (note picker), both from
# ~/dotfiles/zsh/tools.zsh. :q in nvim closes the pad; the next press starts
# fresh.

cmd="${1:-scratch}"
class="dev.guiwoch.scratchpad"   # ghostty requires a valid GTK app ID
ws="special:scratchpad"

if hyprctl clients -j | jq -e --arg c "$class" 'any(.[]; .class == $c)' >/dev/null; then
    hyprctl dispatch togglespecialworkspace scratchpad
    exit
fi

# Launched but not mapped yet (a quick double press): don't start a second.
pgrep -f -- "[g]hostty.*--class=$class" >/dev/null && exit

# Show the (empty) special workspace first so the new window lands there
# and is visible.
if ! hyprctl monitors -j | jq -e --arg w "$ws" 'any(.[]; .specialWorkspace.name == $w)' >/dev/null; then
    hyprctl dispatch togglespecialworkspace scratchpad
fi

# --gtk-single-instance=false replaces wezterm's --always-new-process: without
# it the pad is folded into the running ghostty and never gets its own app ID.
# -e overrides ghostty's `command`, so the pad deliberately stays out of tmux.
hyprctl dispatch exec "[workspace $ws] ghostty --class=$class --gtk-single-instance=false -e zsh -c 'source ~/dotfiles/zsh/tools.zsh && $cmd'"
