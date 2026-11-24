#!/usr/bin/env bash

dir="$HOME/.config/rofi/wallpaper"
theme="$dir/wallpaper-chager-style.rasi"
wallpaper_dir="$HOME/Pictures/Wallpapers"

# Check dependencies
for cmd in rofi swaybg find sort; do
    command -v "$cmd" >/dev/null 2>&1 || exit 1
done

# Find wallpaper images
mapfile -d '' wallpapers < <(
    find "$wallpaper_dir" -type f \
        \( -iname '*.png' -o -iname '*.jpg' \
        -o -iname '*.jpeg' -o -iname '*.webp' \
        -o -iname '*.bmp' \) -print0 | sort -z
)

[[ ${#wallpapers[@]} -eq 0 ]] && exit 0

# Build Rofi entries
chosen=$(
    for i in "${!wallpapers[@]}"; do
        file="${wallpapers[$i]}"
        name="$(basename "$file")"

        printf '%s\0icon\x1fthumbnail://%s\n' "$name" "$file"
    done |
    rofi -dmenu \
        -i \
        -show-icons \
        -p "WALLPAPER" \
        -mesg "Choose your desktop wallpaper" \
        -theme "$theme"
)

# Cancel handling
[[ -z "$chosen" ]] && exit 0

# Locate selected wallpaper
for file in "${wallpapers[@]}"; do
    if [[ "$(basename "$file")" == "$chosen" ]]; then
        selected="$file"
        break
    fi
done

[[ -z "${selected:-}" ]] && exit 0

# Apply wallpaper
pkill -x swaybg 2>/dev/null
swaybg -i "$selected" -m fill >/dev/null 2>&1 &

# Save selection
printf '%s\n' "$selected" > "$dir/current-wallpaper"
