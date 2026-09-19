#!/bin/bash
# Shows whether the warm screen filter (hyprsunset) is on.
# ~/.config/hypr/scripts/night-light-toggle.sh signals waybar on toggle.
if pgrep -x hyprsunset >/dev/null; then
    echo '{"text": "", "class": "on", "tooltip": "Night light on (click to turn off)"}'
else
    echo '{"text": "", "class": "off", "tooltip": "Night light off (click to turn on)"}'
fi
