#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  network-helper.sh
#  Dynamically detects network interfaces for EWW widgets
#  Usage: source this script and use $NET_IFACE variable
# ─────────────────────────────────────────────────────────────────────────────

# Get primary network interface (non-loopback, up)
# Priority: wireless (wlan/wlp) > ethernet (eth/enp) > other

get_network_interface() {
    # Try to get default route interface
    local default_iface
    default_iface=$(ip route | awk '/default/ {print $5; exit}')
    
    if [ -n "$default_iface" ]; then
        echo "$default_iface"
        return
    fi
    
    # Fallback: find first active non-loopback interface
    ip -o link show | awk -F': ' '{print $2}' | while read -r iface; do
        if [ "$iface" != "lo" ]; then
            # Check if interface is up
            if ip link show "$iface" | grep -q "state UP"; then
                echo "$iface"
                return
            fi
        fi
    done
}

# Export the interface name
NET_IFACE=$(get_network_interface)

# Also create aliases for convenience
WIRED_IFACE=$(ip -o link show | awk -F': ' '/^[0-9]+: (eth|enp|eno|ens|enx)/ && !/lo/ {print $2; exit}')
WIRELESS_IFACE=$(ip -o link show | awk -F': ' '/^[0-9]+: (wlan|wlp)/ && !/lo/ {print $2; exit}')
