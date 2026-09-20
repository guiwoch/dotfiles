#!/bin/bash
# Toggle the groupbar between the thin indicator strip (hyprland.conf) and
# Omarchy-style titled tabs with opaque backgrounds.
#
# Tab backgrounds are only built on a config reload (setting the options with
# `hyprctl keyword` leaves them transparent), so the titled look lives in a
# sourced file that this script fills or empties before reloading.

mode_file="$HOME/.config/hypr/groupbar-mode.conf"

if grep -q render_titles "$mode_file" 2>/dev/null; then
    echo "# Written by scripts/groupbar-titles.sh. Empty = thin strip." > "$mode_file"
else
    cat > "$mode_file" <<'CONF'
# Written by scripts/groupbar-titles.sh. Titled tabs; empty = thin strip.
group:groupbar:render_titles = true
group:groupbar:gradients = true
group:groupbar:indicator_height = 0
group:groupbar:col.active = rgba(3A3A3Aff)
group:groupbar:col.inactive = rgba(1E1E1Eff)
CONF
fi

# A reload resets the keyboard layout to kb_layout; put the live one back.
layout=$(hyprctl getoption input:kb_layout | awk '/^str:/ {print $2}')
hyprctl reload >/dev/null
[[ -n "$layout" ]] && hyprctl keyword input:kb_layout "$layout" >/dev/null
