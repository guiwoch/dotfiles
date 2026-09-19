#!/bin/bash
# Toggle warm screen colours with hyprsunset.
# A running hyprsunset process is the state: it applies the filter while alive
# and restores normal colours when it exits, so a reboot always starts neutral.

TEMPERATURE=4000

if ! command -v hyprsunset >/dev/null; then
    notify-send "Night Light" "hyprsunset is not installed" -t 3000
    exit 1
fi

if pgrep -x hyprsunset >/dev/null; then
    pkill -x hyprsunset
    want=off
else
    setsid -f hyprsunset -t "$TEMPERATURE" >/dev/null 2>&1
    want=on
fi

# hyprsunset takes a moment to start or exit; wait (up to 2s) so waybar
# doesn't read the old state
for _ in $(seq 20); do
    if pgrep -x hyprsunset >/dev/null; then now=on; else now=off; fi
    [[ "$now" == "$want" ]] && break
    sleep 0.1
done

# Refresh the waybar night light indicator
pkill -RTMIN+9 waybar
