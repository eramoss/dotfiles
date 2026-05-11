#!/usr/bin/env bash
SOURCE="eDP-1"
TARGET="HDMI-A-1"

apply_workspaces() {
    sleep 0.5  # give Hyprland time to register the monitor
    hyprctl dispatch moveworkspacetomonitor "1 HDMI-A-1"
    hyprctl dispatch moveworkspacetomonitor "2 HDMI-A-1"
    hyprctl dispatch moveworkspacetomonitor "3 HDMI-A-1"
    hyprctl dispatch moveworkspacetomonitor "4 eDP-1"
    hyprctl dispatch moveworkspacetomonitor "5 eDP-1"
}


if hyprctl monitors all | grep -q "monitor mirrors"; then
    hyprctl keyword monitor "$TARGET, preferred, 0x0, 0.75"
    notify-send "Hyprland" "Mirroring disabled"
    apply_workspaces
else
    hyprctl keyword monitor "$TARGET, preferred, auto, 1, mirror, $SOURCE"
    notify-send "Hyprland" "Mirroring $SOURCE → $TARGET"
    reload_quickshell
fi
