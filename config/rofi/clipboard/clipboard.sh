
#!/usr/bin/env bash

# Rofi Clipboard Manager

dir="$HOME/.config/rofi/clipboard"
theme="$dir/clipboard-style.rasi"
confirm_theme="$HOME/.config/rofi/shared/confirm.rasi"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

# Check dependencies
for cmd in rofi cliphist wl-copy; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        notify-send "Clipboard" "Missing dependency: $cmd" 2>/dev/null
        exit 1
    fi
done

clear_option="󰆴  Clear Clipboard History"

# Generate clipboard entries with image thumbnails
{
    printf '%s\n' "$clear_option"

    while IFS=$'\t' read -r id format preview; do
        [[ -z "$id" ]] && continue

        if [[ -n "$format" ]]; then
            # Decode image to temporary thumbnail source
            image="$tmp_dir/$id.$format"

            if cliphist decode "$id" > "$image" 2>/dev/null; then
                label="󰋩  Image ($format)"

                printf '%s\t%s\0icon\x1f%s\n' \
                    "$id" "$label" "$image"
            fi
        else
            # Normal text entry
            printf '%s\t%s\n' "$id" "$preview"
        fi

    done < <(cliphist list -fields id,format,preview)

} | rofi \
    -dmenu \
    -i \
    -show-icons \
    -p "CLIPBOARD" \
    -mesg "Select text or screenshot to restore" \
    -theme "$theme" > "$tmp_dir/selection"

selected=$(cat "$tmp_dir/selection")

# Exit if cancelled
[[ -z "$selected" ]] && exit 0

# Clear history
if [[ "$selected" == "$clear_option" ]]; then

    confirm=$(printf '☑\n\n' | rofi \
        -dmenu \
        -p "Confirmation" \
        -mesg "Clear all clipboard history?" \
        -theme "$confirm_theme")

    if [[ "$confirm" == "☑" ]]; then
        cliphist wipe
        wl-copy --clear 2>/dev/null
        notify-send "Clipboard" "Clipboard history cleared!" 2>/dev/null
    fi

    exit 0
fi

# Restore selected text or image
printf '%s\n' "$selected" | cliphist decode | wl-copy

notify-send "Clipboard" "Clipboard item restored!" 2>/dev/null
