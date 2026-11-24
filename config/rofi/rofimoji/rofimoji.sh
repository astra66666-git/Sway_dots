
#!/usr/bin/env bash

dir="$HOME/.config/rofi/rofimoji"
theme="$dir/rofimoji-style.rasi"

rofimoji \
    --selector rofi \
    --action copy \
    --clipboarder wl-copy \
    --files emojis \
    --skin-tone ask \
    --use-icons \
    --max-recent 10 \
    --selector-args="-theme $theme"
