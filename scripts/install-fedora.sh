#!/bin/bash
# ──────────────────────────────────────────────────────────────────────────────
#  Fedora 43 - Dionysus Dotfiles Installation Script
#  Run as: bash scripts/install-fedora.sh
# ──────────────────────────────────────────────────────────────────────────────

set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║         Dionysus Dotfiles - Fedora 43 Installation            ║"
echo "╚════════════════════════════════════════════════════════════════╝"

# Check if running as root (for dnf install)
if [ "$EUID" -eq 0 ]; then
    echo "[ERROR] Run as regular user, not root. Use sudo for dnf commands."
    exit 1
fi

# ──────────────────────────────────────────────────────────────────────────
# Enable COPR repos for packages not in Fedora repos
# ──────────────────────────────────────────────────────────────────────────
echo "[1/7] Enabling COPR repositories..."

# Enable Hyprland COPR (if available) or use Copr for latest
sudo dnf copr enable -y ghz/hyprland 2>/dev/null || true
sudo dnf copr enable -y xd009642/tlaunch 2>/dev/null || true

# ──────────────────────────────────────────────────────────────────────────
# Install Core Packages
# ──────────────────────────────────────────────────────────────────────────
echo "[2/7] Installing core packages..."

sudo dnf install -y \
    hyprland \
    waybar \
    rofi \
    rofi-emoji \
    alacritty \
    thunar \
    thunar-archive-plugin \
    firefox \
    grim \
    slurp \
    wl-clipboard \
    playerctl \
    brightnessctl \
    upower \
    jq \
    lm_sensors \
    curl \
    wget \
    git \
    zsh \
    python3 \
    python3-pip \
    NetworkManager \
    NetworkManager-wifi \
    bluez \
    bluez-tools \
    pulsemixer \
    pamixer \
    brightnessctl \
    libpulse \
    pipewire \
    pipewire-pulseaudio \
    wireplumber \
    gdm \
    kitty 2>/dev/null || true

# ──────────────────────────────────────────────────────────────────────────
# Install Cava (may need COPR)
# ──────────────────────────────────────────────────────────────────────────
echo "[3/7] Installing Cava..."

# Try to install from COPR, fallback to building
if ! sudo dnf install -y cava 2>/dev/null; then
    echo "    Cava not in repos. Install from source or COPR:"
    echo "    sudo dnf copr enable -y luktom/cava"
    echo "    sudo dnf install -y cava"
fi

# ──────────────────────────────────────────────────────────────────────────
# Install EWW (Elkowar's Wacky Widgets) - Build from source
# ──────────────────────────────────────────────────────────────────────────
echo "[4/7] Installing EWW..."

if ! command -v eww &> /dev/null; then
    echo "    EWW not in repos. Building from source..."
    echo "    See: https://github.com/elkowar/eww"
    echo "    Recommended: use eww-unwrapped from AUR or build manually"
fi

# ──────────────────────────────────────────────────────────────────────────
# Install Fonts
# ──────────────────────────────────────────────────────────────────────────
echo "[5/7] Installing fonts..."

sudo dnf install -y \
    jetbrains-mono-fonts \
    fontawesome-fonts \
    && mkdir -p ~/.local/share/fonts

# Download and install GohuFont
if [ ! -d "$HOME/.local/share/fonts/GohuFont" ]; then
    echo "    Installing GohuFont..."
    mkdir -p ~/.local/share/fonts/GohuFont
    wget -q https://github.com/St摆摆/GohuFont/releases/download/2024.11.24_11.35_27/GohuFont.tar.gz -O /tmp/gohufont.tar.gz
    tar -xzf /tmp/gohufont.tar.gz -C ~/.local/share/fonts/GohuFont
    rm /tmp/gohufont.tar.gz
fi

# Download and install Nerd Fonts (JetBrains Mono)
if [ ! -d "$HOME/.local/share/fonts/JetBrainsMonoNerdFont" ]; then
    echo "    Installing JetBrains Mono Nerd Font..."
    mkdir -p ~/.local/share/fonts/JetBrainsMonoNerdFont
    wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip -O /tmp/jb.zip
    unzip -q /tmp/jb.zip -d ~/.local/share/fonts/JetBrainsMonoNerdFont
    rm /tmp/jb.zip
fi

fc-cache -f -v > /dev/null 2>&1

# ──────────────────────────────────────────────────────────────────────────
# Install Oh-My-Zsh
# ──────────────────────────────────────────────────────────────────────────
echo "[6/7] Installing Oh-My-Zsh..."

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" -- --unattended
fi

# Install plugins
mkdir -p ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
mkdir -p ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

if [ ! -f ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh ]; then
    git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
fi

if [ ! -f ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh ]; then
    git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
fi

# ──────────────────────────────────────────────────────────────────────────
# Setup Dotfiles
# ──────────────────────────────────────────────────────────────────────────
echo "[7/7] Setting up dotfiles..."

# Create config directories
mkdir -p ~/.config/hypr
mkdir -p ~/.config/waybar
mkdir -p ~/.config/rofi
mkdir -p ~/.config/alacritty
mkdir -p ~/.config/eww
mkdir -p ~/.config/cava
mkdir -p ~/.config/zsh
mkdir -p ~/.config/neofetch
mkdir -p ~/.local/share/applications

# Link dotfiles
ln -sf "$(pwd)/dotfiles/hypr/hyprland.conf" ~/.config/hypr/config
ln -sf "$(pwd)/dotfiles/hypr/hyprpaper.conf" ~/.config/hypr/hyprpaper.conf
ln -sf "$(pwd)/dotfiles/hypr/scripts" ~/.config/hypr/scripts
ln -sf "$(pwd)/dotfiles/hypr/extras" ~/.config/hypr/extras
ln -sf "$(pwd)/dotfiles/hypr/shaders" ~/.config/hypr/shaders
ln -sf "$(pwd)/dotfiles/hypr/wallpapers" ~/.config/hypr/wallpapers

ln -sf "$(pwd)/dotfiles/waybar/config" ~/.config/waybar/config
ln -sf "$(pwd)/dotfiles/waybar/scripts" ~/.config/waybar/scripts
ln -sf "$(pwd)/dotfiles/waybar/style.css" ~/.config/waybar/style.css

ln -sf "$(pwd)/dotfiles/rofi/config.rasi" ~/.config/rofi/config.rasi
ln -sf "$(pwd)/dotfiles/rofi/theme.rasi" ~/.config/rofi/theme.rasi

ln -sf "$(pwd)/dotfiles/alacritty/alacritty.toml" ~/.config/alacritty/config.toml

ln -sf "$(pwd)/dotfiles/eww" ~/.config/eww

ln -sf "$(pwd)/dotfiles/cava/config" ~/.config/cava/config

ln -sf "$(pwd)/dotfiles/zsh/.zshrc" ~/.zshrc

ln -sf "$(pwd)/dotfiles/neofetch/config.conf" ~/.config/neofetch/config.conf

# ──────────────────────────────────────────────────────────────────────────
# Configure sudo for keyboard scripts (ASUS laptops)
# ──────────────────────────────────────────────────────────────────────────
echo ""
echo "════════════════════════════════════════════════════════════════"
echo "  Post-Installation Setup Required:"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "1. Configure passwordless sudo for keyboard scripts:"
echo "   Run: sudo visudo"
echo "   Add: $USER ALL=(ALL) NOPASSWD: /usr/bin/tee /sys/class/leds/asus::kbd_backlight/*"
echo ""
echo "2. Set default shell to zsh:"
echo "   chsh -s /bin/zsh"
echo ""
echo "3. For NVIDIA GPU:"
echo "   sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda"
echo ""
echo "4. Reboot and select Hyprland from GDM login"
echo ""
echo "════════════════════════════════════════════════════════════════"
echo "  Installation Complete!"
echo "════════════════════════════════════════════════════════════════"
