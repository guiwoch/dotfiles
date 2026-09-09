#!/bin/bash

# File to store current layout state
STATE_FILE="$HOME/.config/hypr/kb_layout_state"

# Check current state (default to standard US if file doesn't exist)
if [[ -f "$STATE_FILE" ]]; then
    CURRENT_STATE=$(cat "$STATE_FILE")
else
    CURRENT_STATE="us"
fi

# Toggle between layouts
if [[ "$CURRENT_STATE" == "us" ]]; then
    # Switch to US International
    hyprctl keyword input:kb_variant intl
    echo "intl" > "$STATE_FILE"
    notify-send "Keyboard Layout" "Switched to US International" -t 2000
else
    # Switch to standard US
    hyprctl keyword input:kb_variant ""
    echo "us" > "$STATE_FILE"
    notify-send "Keyboard Layout" "Switched to US Standard" -t 2000
fi
