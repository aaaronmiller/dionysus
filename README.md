# Dionysus Dotfiles

Hyprland rice configuration for **Arch Linux** (original) and **Fedora 43** (ported).

![Hyprland Demo](assets/demo.gif)

## Original Config (Arch Linux)
See [Arch branch](https://github.com/pewdiepie-archdaemon/dionysus) for the original Arch version.

## Fedora 43 Port
This branch contains a working port for **Fedora 43** with all necessary modifications.

### What's Different
- Fedora-specific installation script (`scripts/install-fedora.sh`)
- Dynamic network interface detection
- Fixed sudo/pkexec handling for ASUS keyboard scripts
- Updated package names and dependencies

---

## Quick Start (Fedora 43)

```bash
# 1. Clone and run install
git clone https://github.com/yourusername/dionysus.git
cd dionysus
bash scripts/install-fedora.sh

# 2. Configure sudo for ASUS keyboard (if ROG laptop)
sudo visudo
# Add: youruser ALL=(ALL) NOPASSWD: /usr/bin/tee /sys/class/leds/asus::kbd_backlight/*

# 3. Set zsh as default
chsh -s /bin/zsh

# 4. Reboot and select Hyprland from GDM
```

---

## Documentation

- [User Guide](docs/USER_GUIDE.md) - Detailed feature documentation
- [Cheat Sheet](docs/CHEAT_SHEET.md) - Quick reference for keybinds and commands

---

## Components

| Component | Config | Description |
|-----------|--------|-------------|
| Hyprland | `dotfiles/hypr/` | Window manager |
| Waybar | `dotfiles/waybar/` | Status bar |
| Eww | `dotfiles/eww/` | HUD widgets |
| Rofi | `dotfiles/rofi/` | App launcher |
| Alacritty | `dotfiles/alacritty/` | Terminal |
| Cava | `dotfiles/cava/` | Audio visualizer |
| Zsh | `dotfiles/zsh/` | Shell config |
| Neofetch | `dotfiles/neofetch/` | System info |

---

## Requirements

### Fedora Packages
```bash
hyprland, waybar, rofi, alacritty, thunar, grim, slurp,
wl-clipboard, playerctl, brightnessctl, upower, jq,
lm_sensors, cava, zsh, python3, NetworkManager
```

### Build from Source
- **Eww:** https://github.com/elkowar/eww

---

## Hardware Support

Tested on **ASUS ROG Zephyrus G15** (GA503).

Features:
- Keyboard backlight control
- Performance profile switching
- Battery monitoring
- Fan/temp monitoring (via lm-sensors)

---

## License

MIT - Feel free to use and modify.
