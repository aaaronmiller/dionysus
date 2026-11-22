#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
#  kbd-breathing.sh
#  Toggles ASUS keyboard backlight "breathing" effect.
#  Bound to XF86Launch3 (F4) in Hyprland config.
#
#  Fedora: Requires passwordless sudo for sysfs writes
# ─────────────────────────────────────────────────────────────────────────────

KEY_BRIGHTNESS_PATH="/sys/class/leds/asus::kbd_backlight/brightness"
MAX_BRIGHTNESS_FILE="/sys/class/leds/asus::kbd_backlight/max_brightness"

SLEEP_TIME=0.2
MIN_BRIGHTNESS=1
PID_FILE="/tmp/kbd-breathing.pid"

# Check if keyboard backlight exists
if [ ! -f "$MAX_BRIGHTNESS_FILE" ]; then
    echo "ASUS keyboard backlight not found."
    exit 1
fi

MAX_BRIGHTNESS=$(cat "$MAX_BRIGHTNESS_FILE")

# Determine write method
if [ "$EUID" -eq 0 ]; then
    WRITE_BRIGHTNESS="tee"
else
    if sudo -n true 2>/dev/null; then
        WRITE_BRIGHTNESS="sudo tee"
    elif command -v pkexec &>/dev/null; then
        WRITE_BRIGHTNESS="pkexec tee"
    else
        WRITE_BRIGHTNESS="tee"
    fi
fi

# If the script is already running, stop it
if [[ -f "$PID_FILE" ]]; then
    kill "$(cat $PID_FILE)" 2>/dev/null
    rm "$PID_FILE"
    echo 3 | $WRITE_BRIGHTNESS "$KEY_BRIGHTNESS_PATH" 2>/dev/null
    exit 0
fi

# Store process ID
echo $$ > "$PID_FILE"

cleanup() {
    rm -f "$PID_FILE"
    echo 3 | $WRITE_BRIGHTNESS "$KEY_BRIGHTNESS_PATH" 2>/dev/null
    exit 0
}

trap cleanup SIGINT SIGTERM

while true; do
    # Fade in
    for level in $(seq $MIN_BRIGHTNESS $MAX_BRIGHTNESS); do
        echo $level | $WRITE_BRIGHTNESS "$KEY_BRIGHTNESS_PATH" 2>/dev/null
        sleep $SLEEP_TIME
    done

    # Fade out
    for level in $(seq $MAX_BRIGHTNESS -1 $MIN_BRIGHTNESS); do
        echo $level | $WRITE_BRIGHTNESS "$KEY_BRIGHTNESS_PATH" 2>/dev/null
        sleep $SLEEP_TIME
    done
done
