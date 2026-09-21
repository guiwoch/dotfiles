#!/bin/bash
# Step the night light temperature through hyprsunset's IPC.
# Usage: warmth.sh warmer|cooler
# "warmer" while the night light is off turns it on (at the toggle's default).

STEP=250
MIN=2500
MAX=6500

if ! pgrep -x hyprsunset >/dev/null; then
    [[ "$1" == "warmer" ]] && exec ~/.config/hypr/scripts/night-light-toggle.sh
    exit 0
fi

current=$(hyprctl hyprsunset temperature)
case "$1" in
    warmer) new=$((current - STEP)) ;;
    cooler) new=$((current + STEP)) ;;
    *) echo "usage: $0 warmer|cooler" >&2; exit 1 ;;
esac
((new < MIN)) && new=$MIN
((new > MAX)) && new=$MAX

hyprctl hyprsunset temperature "$new" >/dev/null
# Silenced: no notification for per-step warmth changes.
