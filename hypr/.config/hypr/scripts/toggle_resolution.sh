#!/bin/bash

CONF="$HOME/.config/hypr/hyprland.conf"
MON="DP-1"

RES1="1920x1080@75"
RES2="2560x1080@75"

# find current resolution
if grep -q "$MON,$RES1" "$CONF"; then
    # switch to RES2
    sed -i "s/$MON,$RES1/$MON,$RES2/" "$CONF"
else
    # switch to RES1
    sed -i "s/$MON,$RES2/$MON,$RES1/" "$CONF"
fi

# reload hyprland
hyprctl reload

