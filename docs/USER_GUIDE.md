# Dionysus - User Guide

A Hyprland-based Wayland rice configuration with neon-radioactive aesthetics.

---

## Components Overview

### 1. Hyprland (Window Manager)
- **Type:** Wayland compositor and window manager
- **Config:** `~/.config/hypr/config`
- **Features:** Dynamic workspaces, window animations, border styling

### 2. Waybar (Status Bar)
- **Location:** Top of screen
- **Config:** `~/.config/waybar/config`
- **Modules:** Clock, network, battery, volume, workspaces, ASUS profile

### 3. Eww (Widgets/HUD)
- **Type:** Elkowar's Wacky Widgets
- **Shows:** When no windows are open (via waybar_watcher)
- **Displays:** ASCII art, system stats, network, audio visualizer

### 4. Rofi (Launcher)
- **Hotkey:** `Alt + Space`
- **Modes:** Application launcher (drun), run dialog
- **Config:** `~/.config/rofi/config.rasi`

### 5. Alacritty (Terminal)
- **Default terminal:** `Alt + T`
- **Theme:** Nord-inspired neon
- **Config:** `~/.config/alacritty/config.toml`

### 6. Cava (Audio Visualizer)
- **Type:** Console-based audio spectrum visualizer
- **Integration:** EWW widget display
- **Config:** `~/.config/cava/config`

### 7. Neofetch (System Info)
- **Display:** Animated on terminal startup
- **Config:** `~/.config/neofetch/config.conf`

---

## Custom Features

### Workspace System
- **4 persistent workspaces** (1-4)
- Workspace 9: Hidden background tasks
- **Keybinds:** `Alt + 1-4` to switch
- **Move windows:** `Super + 1-4`

### Dynamic Wallpaper (waybar_watcher.sh)
- **Empty workspace:** Shows EWW HUD + wallpaper with no windows
- **Active windows:** Switches to Waybar status bar + different wallpaper
- Script monitors window count and toggles accordingly

### Screenshot (grim + slurp)
- **Hotkey:** `Alt + P`
- **Action:** Select region → copies to clipboard + saves to Pictures/Screenshots

### Audio Visualizer
- **Cava** runs in background
- **Python script** converts to ASCII
- **EWW window** displays the visualization

### Battery Status
- **Location:** Waybar (right side)
- **Shows:** Percentage + ASCII bar
- **Colors:** Red (<20%), Orange (<55%), Cyan (normal)

### Network Monitoring
- **EWW widgets:** Download/upload bars, ping latency
- **Auto-detect:** Uses first active interface (WiFi/Ethernet)

---

## Hardware-Specific Features (ASUS ROG Laptops)

### Keyboard Backlight
- **Up:** `F3` or `Super + F3`
- **Down:** `Fn + F3` or `Super + Fn + F3`
- **Script:** `~/.config/hypr/scripts/asus-kbd/kbd-brightness.sh`

### Breathing Effect
- **Hotkey:** `F4` or `Super + F4`
- **Toggle:** Starts/stops keyboard breathing animation
- **Script:** `~/.config/hypr/scripts/asus-kbd/kbd-breathing.sh`

### Performance Profile
- **Hotkey:** `F5` or `Super + F5`
- **Cycles:** Quiet → Balanced → Performance
- **Script:** `~/.config/hypr/scripts/asus-kbd/cycle-profile.sh`

---

## Installation

### Quick Start (Fedora 43)
```bash
# 1. Run installation script
bash scripts/install-fedora.sh

# 2. Configure sudo for keyboard scripts
sudo visudo
# Add: yourusername ALL=(ALL) NOPASSWD: /usr/bin/tee /sys/class/leds/asus::kbd_backlight/*

# 3. Set zsh as default shell
chsh -s /bin/zsh

# 4. Reboot and select Hyprland from GDM
```

### Manual Setup
```bash
# Install dependencies
sudo dnf install hyprland waybar rofi alacritty thunar grim slurp wl-clipboard \
    playerctl brightnessctl upower jq lm_sensors cava zsh python3

# Link dotfiles
ln -s dotfiles/hypr/hyprland.conf ~/.config/hypr/config
ln -s dotfiles/waybar/config ~/.config/waybar/config
# ... etc
```

---

## Troubleshooting

### Hyprland not starting
- Check logs: `journalctl -b -u hyprland`
- Verify GPU drivers installed
- Try: `Hyprland` in terminal to see errors

### Waybar not showing
- Run manually: `waybar`
- Check config: `waybar --validate`

### EWW widgets not appearing
- Ensure eww is installed: `eww --version`
- Check logs: `eww daemon`

### Audio visualizer not working
- Ensure Cava is running: `cava`
- Check pipewire: `pw-cli info`

### Screen brightness not working
- Install: `brightnessctl`
- Add user to video group: `sudo usermod -aG video $USER`

---

## Configuration Files

| File | Purpose |
|------|---------|
| `~/.config/hypr/config` | Main window manager config |
| `~/.config/hypr/hyprpaper.conf` | Wallpaper settings |
| `~/.config/waybar/config` | Status bar config |
| `~/.config/waybar/style.css` | Status bar styling |
| `~/.config/rofi/config.rasi` | Launcher config |
| `~/.config/rofi/theme.rasi` | Launcher theme |
| `~/.config/alacritty/config.toml` | Terminal config |
| `~/.config/cava/config` | Audio visualizer config |
| `~/.config/neofetch/config.conf` | System info config |
| `~/.zshrc` | Shell configuration |

---

## Keybinds Reference

| Keys | Action |
|------|--------|
| `Alt + T` | Open terminal |
| `Alt + Space` | Rofi launcher |
| `Alt + B` | Open Firefox |
| `Alt + F` | Open file manager |
| `Alt + W` | Close window |
| `Alt + V` | Toggle floating |
| `Alt + P` | Screenshot |
| `Alt + 1-4` | Switch workspace |
| `Super + 1-4` | Move to workspace |
| `Alt + Arrow` | Move focus |
| `Alt + Mouse` | Drag window |
| `F3` | Keyboard brightness |
| `F4` | Keyboard breathing |
| `F5` | Cycle profile |
| `F7/F8` | Screen brightness |
| `Vol keys` | Volume control |
