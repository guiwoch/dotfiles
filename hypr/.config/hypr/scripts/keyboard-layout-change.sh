#!/bin/bash
# Toggle between US and US International (PT, see ~/.config/xkb/symbols/us-pt).
# The live Hyprland option is the source of truth, so it stays correct after
# a reboot or config reload (which always start on kb_layout = us).

current=$(hyprctl getoption input:kb_layout | awk '/^str:/ {print $2}')

# No notification: the waybar custom/kb-layout module already shows the
# active layout, and it is refreshed by the signal below.
if [[ "$current" == "us" ]]; then
    hyprctl keyword input:kb_layout us-pt
else
    hyprctl keyword input:kb_layout us
fi

# Refresh the waybar layout indicator
pkill -RTMIN+8 waybar
