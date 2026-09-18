#!/bin/bash
# Toggle between US and US International (PT, see ~/.config/xkb/symbols/us-pt).
# The live Hyprland option is the source of truth, so it stays correct after
# a reboot or config reload (which always start on kb_layout = us).

current=$(hyprctl getoption input:kb_layout | awk '/^str:/ {print $2}')

if [[ "$current" == "us" ]]; then
    hyprctl keyword input:kb_layout us-pt
    notify-send "Keyboard Layout" "Switched to US International (PT)" -t 2000
else
    hyprctl keyword input:kb_layout us
    notify-send "Keyboard Layout" "Switched to US Standard" -t 2000
fi

# Refresh the waybar layout indicator
pkill -RTMIN+8 waybar
