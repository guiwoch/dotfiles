#!/bin/bash
# Shows the active keyboard layout, read live from Hyprland.
# ~/.config/hypr/scripts/keyboard-layout-change.sh signals waybar on switch.
layout=$(hyprctl getoption input:kb_layout | awk '/^str:/ {print $2}')
if [[ "$layout" == "us-pt" ]]; then
    echo '{"text": "PT", "class": "pt", "tooltip": "US International (PT)"}'
else
    echo '{"text": "US", "class": "us", "tooltip": "US Standard"}'
fi
