#!/usr/bin/env bash
# Current Theme
dir="$HOME/.config/rofi/powermenu"
theme="powermeny-style"

# Commands
uptime="$(uptime -p | sed 's/up //')"
host="$(hostname)"

# Options
shutdown=''
reboot=''
lock=''
suspend=''
logout=''
yes='☑'
no=''

# Rofi CMD
rofi_cmd() {
    rofi -dmenu \
        -p "Uptime: $uptime" \
        -mesg "Uptime: $uptime" \
        -theme "${dir}/${theme}.rasi"
}

# Confirmation CMD
confirm_cmd() {
    rofi -dmenu \
        -p "Confirmation" \
        -mesg "Are you Sure?" \
        -theme "$HOME/.config/rofi/shared/confirm.rasi"
}

# Ask for confirmation
confirm_exit() {
    printf '%s\n%s\n' "$yes" "$no" | confirm_cmd
}

# Pass variables to Rofi dmenu
run_rofi() {
    printf '%s\n' "$lock" "$suspend" "$logout" "$reboot" "$shutdown" | rofi_cmd
}

# Execute Command
run_cmd() {
    selected="$(confirm_exit)"

    if [[ "$selected" == "$yes" ]]; then

        case "$1" in

            --shutdown)
                systemctl poweroff
                ;;

            --reboot)
                systemctl reboot
                ;;

            --suspend)
                # Pause music if MPC is installed
                if command -v mpc >/dev/null 2>&1; then
                    mpc -q pause 2>/dev/null
                fi

                # Lock screen before suspending
                swaylock -f
                systemctl suspend
                ;;

            --logout)
                # Exit Sway
                swaymsg exit
                ;;

        esac
    else
        exit 0
    fi
}

# Actions
chosen="$(run_rofi)"

case "$chosen" in

    "$shutdown")
        run_cmd --shutdown
        ;;

    "$reboot")
        run_cmd --reboot
        ;;

    "$lock")
        swaylock
        ;;

    "$suspend")
        run_cmd --suspend
        ;;

    "$logout")
        run_cmd --logout
        ;;

esac

exit 0
