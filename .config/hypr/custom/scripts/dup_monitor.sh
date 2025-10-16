#!/usr/bin/env bash

SOURCE="eDP-1"
TARGET="HDMI-A-1"

# Check if currently mirrored
if hyprctl monitors all | grep "monitor mirrors"; then
    # Turn off mirror, enable as normal extended or off
    hyprctl reload
    notify-send "Hyprland" "Mirroring disabled"
else
    # Mirror the target from the source
		hyprctl keyword monitor $TARGET, preferred, auto, 1, mirror, $SOURCE
    notify-send "Hyprland" "Mirroring $SOURCE → $TARGET"
fi
