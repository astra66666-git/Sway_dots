
#!/usr/bin/env bash

WALLPAPER="$HOME/.config/rofi/wallpaper/current-wallpaper"

if [[ -f "$WALLPAPER" ]]; then
    selected=$(cat "$WALLPAPER")

    if [[ -f "$selected" ]]; then
        pkill -x swaybg 2>/dev/null
        swaybg -i "$selected" -m fill &
    fi
fi
