#!/usr/bin/env bash

# This script tries to detect if a selection has been made in the clipboard manager
# trying to work around this clipse limitation:
# https://github.com/savedra1/clipse/issues/221

scripts_folder=$HOME/.config/hypr/scripts

old_clipboard_hash=$(wl-paste | sha256sum)

hyprctl dispatch exec "[float; pin; center; size 622 652] kitty --class clipse -e clipse"

new_clipboard_hash=$(wl-paste | sha256sum)

if [ "$old_clipboard_hash" != "$new_clipboard_hash" ]; then
    "$scripts_folder/paste-or-shift-paste.sh"
fi
