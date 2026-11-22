#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
#  cycle-profile.sh
#  Cycles ASUS performance profiles (Performance → Balanced → Silent).
#  Uses `asusctl` on Arch, or alternative methods on Fedora.
#  Bound to XF86Launch4 (F5) in Hyprland config.
#
#  Fedora Alternative:
#    - Install rog-control-center from COPR
#    - Or use: echo 1 | sudo tee /sys/devices/platform/asus-nb-wmi/throttle_thermal_policy
# ─────────────────────────────────────────────────────────────────────────────

PROFILES=("Quiet" "Balanced" "Performance")

# Check if asusctl is available (Arch)
if command -v asusctl &> /dev/null; then
    CURRENT_PROFILE=$(asusctl profile -p | grep "Active profile" | awk -F' ' '{print $NF}')
    
    NEXT_PROFILE=""
    for ((i = 0; i < ${#PROFILES[@]}; i++)); do
        if [[ "${PROFILES[$i]}" == "$CURRENT_PROFILE" ]]; then
            NEXT_INDEX=$(( (i + 1) % ${#PROFILES[@]} ))
            NEXT_PROFILE="${PROFILES[$NEXT_INDEX]}"
            break
        fi
    done
    
    if [[ -n "$NEXT_PROFILE" ]]; then
        asusctl profile -P "$NEXT_PROFILE"
        notify-send "Profile switched to $NEXT_PROFILE"
    fi

# Check for rog-control-center (Fedora)
elif command -v rog-control-center &> /dev/null; then
    CURRENT=$(cat /sys/devices/platform/asus-nb-wmi/throttle_thermal_policy 2>/dev/null || echo 2)
    NEXT=$(( (CURRENT + 1) % 3 ))
    echo $NEXT | sudo tee /sys/devices/platform/asus-nb-wmi/throttle_thermal_policy
    notify-send "Profile switched to mode $NEXT"

# Fallback: use throttle_thermal_policy directly
elif [ -f /sys/devices/platform/asus-nb-wmi/throttle_thermal_policy ]; then
    CURRENT=$(cat /sys/devices/platform/asus-nb-wmi/throttle_thermal_policy)
    NEXT=$(( (CURRENT + 1) % 3 ))
    
    # Try sudo first
    if sudo -n true 2>/dev/null; then
        echo $NEXT | sudo tee /sys/devices/platform/asus-nb-wmi/throttle_thermal_policy
    elif command -v pkexec &>/dev/null; then
        echo $NEXT | pkexec tee /sys/devices/platform/asus-nb-wmi/throttle_thermal_policy
    else
        echo "Error: Need sudo/pkexec for profile switching"
        exit 1
    fi
    
    case $NEXT in
        0) notify-send "Profile: Silent" ;;
        1) notify-send "Profile: Performance" ;;
        2) notify-send "Profile: Balanced" ;;
    esac

else
    echo "Error: No ASUS profile control found. Install asusctl or rog-control-center"
    notify-send "ASUS Profile: No control available"
    exit 1
fi
