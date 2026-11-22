# Dionysus - Quick Reference Cheat Sheet

```
╔═══════════════════════════════════════════════════════════════════════╗
║                    DIONYSUS HYPRLAND RICE                            ║
║                    Fedora 43 Port - Quick Ref                         ║
╚═══════════════════════════════════════════════════════════════════════╝
```

---

## 🔑 KEYBINDS

### Launcher & Terminal
| Key | Action |
|-----|--------|
| `Alt + Space` | Rofi app launcher |
| `Alt + T` | Open Alacritty |
| `Alt + Return` | Terminal (alternative) |

### Window Management
| Key | Action |
|-----|--------|
| `Alt + W` | Close window |
| `Alt + V` | Toggle floating |
| `Alt + J` | Toggle split |
| `Alt + {` | Pseudo tile |
| `Alt + Arrow` | Move focus |
| `Alt + Drag` | Move window |
| `Alt + Right-drag` | Resize window |

### Workspaces
| Key | Action |
|-----|--------|
| `Alt + 1-4` | Switch workspace |
| `Super + 1-4` | Move window to workspace |
| `Alt + Tab` | Cycle windows |
| `Super + S` | Toggle special workspace |

### Screenshots
| Key | Action |
|-----|--------|
| `Alt + P` | Screenshot (region) |

### Media Keys
| Key | Action |
|-----|--------|
| `Vol Up/Down` | Volume ±5% |
| `Mute` | Toggle mute |
| `Mic Mute` | Toggle mic mute |
| `Bright Up/Down` | Screen brightness |
| `Play/Pause` | Media control |
| `Prev/Next` | Media skip |

### ASUS Laptop (ROG)
| Key | Action |
|-----|--------|
| `F3` | Keyboard brightness up |
| `Fn + F3` | Keyboard brightness down |
| `F4` | Toggle breathing effect |
| `F5` | Cycle performance profile |
| `Super + S` | Switch keyboard layout |

---

## 📁 CONFIG LOCATIONS

```bash
# Main configs
~/.config/hypr/config          # Hyprland
~/.config/waybar/config        # Waybar  
~/.config/rofi/config.rasi     # Rofi
~/.config/alacritty/config.toml # Terminal
~/.config/eww/                 # Widgets

# Scripts
~/.config/hypr/scripts/
├── waybar_watcher.sh          # Auto-toggle EWW/Waybar
└── asus-kbd/
    ├── kbd-brightness.sh      # Keyboard backlight
    ├── kbd-breathing.sh       # Breathing effect
    └── cycle-profile.sh       # Performance profile

# Dotfiles repo
~/code/dionysus/
```

---

## 🛠️ COMMON COMMANDS

### Hyprland
```bash
# Reload config
hyprctl reload

# Workspaces
hyprctl dispatch workspace 1
hyprctl dispatch movetoworkspace 2

# Windows
hyprctl dispatch killactive
hyprctl dispatch togglefloating

# Status
hyprctl activeworkspace
hyprctl monitors
hyprctl clients
```

### Waybar
```bash
# Restart
pkill waybar && waybar &

# Validate config
waybar --validate
```

### Eww
```bash
# Daemon
eww daemon

# Open widgets
eww open-many active_workspace ascii_decor_frame

# Close all
eww close-all
```

### System
```bash
# Brightness
brightnessctl set 50%
brightnessctl s +10%

# Volume
wpctl set-volume @DEFAULT_AUDIO_SINK@ 50%
wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

# Screenshots
grim -g "$(slurp)" - | wl-copy
```

---

## 🔌 SOFTWARE STACK

| Component | Package | Purpose |
|-----------|---------|---------|
| Compositor | Hyprland | Wayland WM |
| Status Bar | Waybar | Top bar |
| Widgets | Eww | HUD overlay |
| Launcher | Rofi | App picker |
| Terminal | Alacritty | Terminal |
| Visualizer | Cava | Audio bars |
| Shell | Zsh + Oh-My-Zsh | Shell |
| Fetch | Neofetch | System info |
| Wallpaper | hyprpaper | Wallpaper daemon |

---

## 🐛 TROUBLESHOOTING

### Nothing loads?
```bash
# Check Hyprland logs
journalctl -b -u hyprland

# Try starting from tty
Hyprland 2>&1 | less
```

### Waybar blank?
```bash
# Kill and restart
pkill waybar
waybar &

# Check errors
waybar 2>&1
```

### EWW not working?
```bash
# Ensure daemon running
eww daemon

# Check widgets
eww windows
```

### Audio issues?
```bash
# Check PipeWire
pw-cli info

# Restart audio
pulseaudio -k
```

### Brightness not working?
```bash
# Check backlight
ls /sys/class/backlight/

# Add user to video group
sudo usermod -aG video $USER
```

---

## 📝 NOTES

- **Workspaces:** 1-4 persistent, 9 hidden (background tasks)
- **EWW:** Shows when NO windows open
- **Waybar:** Shows when windows ARE open
- **VPN:** NordVPN detection (10.6.0.x range)
- **Monitor:** Auto-detected on Fedora

---

## 🚀 FIRST TIME SETUP

```bash
# 1. Install
bash scripts/install-fedora.sh

# 2. Sudo for keyboard (ASUS laptops)
sudo visudo
# Add: username ALL=(ALL) NOPASSWD: /usr/bin/tee /sys/class/leds/asus::kbd_backlight/*

# 3. Set shell
chsh -s /bin/zsh

# 4. Logout → Select Hyprland from GDM
```

---

*Press `Alt + Space` to launch apps. Press `Alt + P` to screenshot.*
