#!/bin/bash
# ──────────────────────────────────────────────────────────────────────────────
#  Link Configs - Connect dotfiles to ~/.config/
#  Run this AFTER installing packages. No sudo needed.
# ──────────────────────────────────────────────────────────────────────────────

echo "Linking Dionysus dotfiles..."

# Create config directories if they don't exist
mkdir -p ~/.config/hypr
mkdir -p ~/.config/waybar
mkdir -p ~/.config/rofi
mkdir -p ~/.config/alacritty
mkdir -p ~/.config/eww
mkdir -p ~/.config/cava
mkdir -p ~/.config/zsh
mkdir -p ~/.config/neofetch
mkdir -p ~/.local/share/applications

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTS_DIR="$(dirname "$SCRIPT_DIR")/dotfiles"

echo "Source: $DOTS_DIR"

# Link all configs (overwrites existing)
ln -sf "$DOTS_DIR/hypr/hyprland.conf" ~/.config/hypr/config
ln -sf "$DOTS_DIR/hypr/hyprpaper.conf" ~/.config/hypr/hyprpaper.conf
ln -sf "$DOTS_DIR/hypr/scripts" ~/.config/hypr/scripts
ln -sf "$DOTS_DIR/hypr/extras" ~/.config/hypr/extras
ln -sf "$DOTS_DIR/hypr/shaders" ~/.config/hypr/shaders
ln -sf "$DOTS_DIR/hypr/wallpapers" ~/.config/hypr/wallpapers

ln -sf "$DOTS_DIR/waybar/config" ~/.config/waybar/config
ln -sf "$DOTS_DIR/waybar/scripts" ~/.config/waybar/scripts
ln -sf "$DOTS_DIR/waybar/style.css" ~/.config/waybar/style.css

ln -sf "$DOTS_DIR/rofi/config.rasi" ~/.config/rofi/config.rasi
ln -sf "$DOTS_DIR/rofi/theme.rasi" ~/.config/rofi/theme.rasi

ln -sf "$DOTS_DIR/alacritty/alacritty.toml" ~/.config/alacritty/config.toml

ln -sf "$DOTS_DIR/eww" ~/.config/eww

ln -sf "$DOTS_DIR/cava/config" ~/.config/cava/config

ln -sf "$DOTS_DIR/zsh/.zshrc" ~/.zshrc

ln -sf "$DOTS_DIR/neofetch/config.conf" ~/.config/neofetch/config.conf

echo "Done! Symlinks created."
echo ""
echo "To test:"
echo "  1. Log out"
echo "  2. Select 'Hyprland' from gear icon"
echo ""
echo "To rollback:"
echo "  1. Log out"
echo "  2. Select GNOME/Niri/etc"
