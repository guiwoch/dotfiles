#!/bin/bash
# Step the monitor's real backlight over DDC/CI (VCP code 0x10, brightness).
# Usage: brightness.sh up|down
# Needs ddcutil, the i2c-dev kernel module and DDC/CI enabled in the monitor OSD.

STEP=5

case "$1" in
    up) sign="+" ;;
    down) sign="-" ;;
    *) echo "usage: $0 up|down" >&2; exit 1 ;;
esac

# ddcutil takes ~0.2s per call; drop presses that arrive while one is running
# so key repeat doesn't queue up a long tail of steps on the i2c bus.
exec 9>"$XDG_RUNTIME_DIR/brightness.lock"
flock -n 9 || exit 0

ddcutil --noverify setvcp 10 "$sign" "$STEP" || exit 1

# No notification for per-step changes; the monitor's own OSD shows the level.
