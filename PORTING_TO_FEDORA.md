# Porting Dionysus Dotfiles from Arch Linux to Fedora 43

## Overview

This document outlines the work required to port the Dionysus Hyprland dotfiles from Arch Linux to Fedora 43.

## Current State Analysis

### What This Config Is
- **Hyprland** dotfiles for a Wayland-based rice/terminal setup
- Designed for **ASUS ROG Zephyrus G15** laptop
- Uses: Hyprland, Waybar, Eww (widgets), Cava (audio visualizer), Rofi, Alacritty, Neofetch

### Directories in Scope
- `dotfiles/hypr/` - Window manager config and scripts
- `dotfiles/waybar/` - Status bar
- `dotfiles/eww/` - HUD widgets
- `dotfiles/rofi/` - Launcher
- `dotfiles/alacritty/` - Terminal
- `dotfiles/zsh/` - Shell config
- `dotfiles/neofetch/` - System info display
- `dotfiles/cava/` - Audio visualizer
- `dotfiles/firefox/` - Browser theme

---

## Required Work

### 1. Package Installation (Fedora Equivalents)

| Arch Package | Fedora Package | Notes |
|--------------|----------------|-------|
| hyprland | `hyprland` | May need COPR |
| hyprpaper | `hyprpaper` | May need COPR |
| eww | Build from source | Not in Fedora repos |
| rofi | `rofi` | + `rofi-emoji` |
| alacritty | `alacritty` | |
| thunar | `thunar` | + `thunar-archive-plugin` |
| firefox | `firefox` | System package |
| grim | `grim` | |
| slurp | `slurp` | |
| wl-clipboard | `wl-clipboard` | |
| playerctl | `playerctl` | |
| brightnessctl | `brightnessctl` | |
| upower | `upower` | |
| jq | `jq` | |
| lm-sensors | `lm_sensors` | |
| curl | `curl` | |
| NetworkManager | `NetworkManager` | |
| cava | `cava` | May need COPR |
| zsh | `zsh` | |
| oh-my-zsh | Manual install | |
| GohuFont | Manual install | Or use alternative |
| nerd-fonts | `jetbrains-mono-fonts` | Alternative |
| python3 | `python3` | For eww scripts |

### 2. Hardcoded Path Fixes

**Files needing path updates:**

- `dotfiles/hypr/scripts/waybar_watcher.sh` (lines 6-7):
  - `/home/pewds/` → `$HOME/.config/`

- `dotfiles/waybar/config` (line 88):
  - `/home/pewds/.config/cycle-profile.sh` → `$HOME/.config/cycle-profile.sh`

- `dotfiles/zsh/.zshrc` (line 34):
  - `Archlinux` → `Fedora` in prompt

### 3. Network Interface Name

The EWW scripts use hardcoded interface names like `wlp4s0`. Fedora uses predictable network names (e.g., `wlan0` or `wlp0s20f3`). **Required action:** Update network scripts in `dotfiles/eww/scripts/net/` to detect interface dynamically or use `ip route` approach.

### 4. Battery Path

`dotfiles/waybar/scripts/battery.sh` (lines 8-9):
- Uses `/sys/class/power_supply/BAT0/` - This is typically consistent across distros but should be verified

### 5. ASUS Keyboard Scripts

`dotfiles/hypr/scripts/asus-kbd/*.sh`:
- Use `sudo tee` for sysfs writes
- **Option A:** Configure passwordless sudo for these commands
- **Option B:** Use a systemd service with elevated privileges
- **Option C:** Modify to use `pkexec` (PolicyKit)

### 6. GPU Monitoring (NVIDIA)

The EWW widgets use `nvidia-smi` for GPU monitoring. If the system has NVIDIA:
- Install `akmod-nvidia` and `xorg-x11-drv-nvidia-cuda`
- Ensure `nvidia-smi` is available

### 7. Font Installation

Required fonts:
- GohuFont (available on AUR, manual install on Fedora)
- JetBrains Mono (Fedora: `jetbrains-mono-fonts`)
- Nerd Fonts (Fedora: install from GitHub or COPR)

### 8. Systemd Integration (Optional but Recommended)

For running EWW and Cava more reliably, create user systemd units:
- `~/.config/systemd/user/eww.service`
- `~/.config/systemd/user/cava.service`

---

## Testing Options

### Option A: Boot into New Config
1. Install Fedora 43 on a separate partition or VM
2. Apply ported configs
3. Reboot into Fedora and test

### Option B: Run in Parallel (Chroot/Container)
1. Mount Fedora root as subdirectory
2. Use `systemd-nspawn` or chroot
3. Run Hyprland nested (if GPU passthrough available)

### Option C: Virtual Machine
1. Create Fedora 43 VM
2. Install Hyprland and dependencies
3. Test configs in isolated environment

---

## Files Requiring Modification (Priority Order)

1. **High Priority:**
   - Package installation script (create new fedora-install.sh)
   - `hypr/scripts/waybar_watcher.sh` - fix hardcoded paths
   - `waybar/config` - fix hardcoded path
   - `zsh/.zshrc` - update prompt and paths

2. **Medium Priority:**
   - `eww/scripts/net/*.sh` - dynamic network interface detection
   - `hypr/scripts/asus-kbd/*.sh` - sudo/pkexec handling
   - `waybar/scripts/battery.sh` - verify battery path

3. **Low Priority:**
   - `neofetch/config.conf` - update OS name display
   - `eww/scripts/sys/*.sh` - verify sensor paths

---

## Next Steps

1. **Approve this plan** - Confirm you want to proceed
2. **Create Fedora installation script** - Package list + installation
3. **Fix hardcoded paths** - Update all `/home/pewds` references
4. **Test in VM** - Verify basic functionality before metal install

---

## Risk Factors

- **Eww** is not packaged for Fedora - requires building from source (Elkowar's GitHub)
- **Cava** may need COPR on Fedora
- **Hyprland** on Fedora may have slight version differences affecting config compatibility
- Hardware-specific scripts (ASUS keyboard, ROG laptop sensors) may need adjustment
