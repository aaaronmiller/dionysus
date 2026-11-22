#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
#  kbd-brightness.sh
#  Adjusts ASUS keyboard backlight brightness (up/down).
#  Reads max brightness from sysfs.
#  Bound to XF86KbdBrightnessUp (F3) / XF86KbdBrightnessDown (Fn2).
#
#  Fedora: Requires passwordless sudo OR use pkexec
#  Run: sudo visudo and add:
#       username ALL=(ALL) NOPASSWD: /usr/bin/tee /sys/class/leds/asus::kbd_backlight/*
# ─────────────────────────────────────────────────────────────────────────────

KEY_BRIGHTNESS_PATH="/sys/class/leds/asus::kbd_backlight/brightness"
MAX_BRIGHTNESS_FILE="/sys/class/leds/asus::kbd_backlight/max_brightness"

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    BRIGHTNESS_WRITE="tee"
else
    # Try sudo first, then pkexec
    if sudo -n true 2>/dev/null; then
        BRIGHTNESS_WRITE="sudo tee"
    elif command -v pkexec &>/dev/null; then
        BRIGHTNESS_WRITE="pkexec tee"
    else
        # Fallback: try direct write (may fail without permissions)
        BRIGHTNESS_WRITE="tee"
    fi
fi

# Check if keyboard backlight exists
if [ ! -f "$MAX_BRIGHTNESS_FILE" ]; then
    echo "ASUS keyboard backlight not found. Is this an ASUS laptop?"
    exit 1
fi

MAX_BRIGHTNESS=$(cat "$MAX_BRIGHTNESS_FILE")

case "$1" in
    up)
        BRIGHTNESS=$(cat "$KEY_BRIGHTNESS_PATH")
        if [ "$BRIGHTNESS" -lt "$MAX_BRIGHTNESS" ]; then
            NEW_BRIGHTNESS=$((BRIGHTNESS + 1))
            echo "$NEW_BRIGHTNESS" | $BRIGHTNESS_WRITE "$KEY_BRIGHTNESS_PATH"
        fi
        ;;
    down)
        BRIGHTNESS=$(cat "$KEY_BRIGHTNESS_PATH")
        if [ "$BRIGHTNESS" -gt 0 ]; then
            NEW_BRIGHTNESS=$((BRIGHTNESS - 1))
            echo "$NEW_BRIGHTNESS" | $BRIGHTNESS_WRITE "$KEY_BRIGHTNESS_PATH"
        fi
        ;;
    get)
        cat "$KEY_BRIGHTNESS_PATH"
        ;;
    max)
        echo "$MAX_BRIGHTNESS" | $BRIGHTNESS_WRITE "$KEY_BRIGHTNESS_PATH"
        ;;
    *)
        echo "Usage: $0 {up|down|get|max}"
        exit 1
        ;;
esac
