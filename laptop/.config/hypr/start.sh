#!/usr/bin/env bash

# wallpaper daemon
swww init &

nm-applet --indicator &

waybar &

dunst &
