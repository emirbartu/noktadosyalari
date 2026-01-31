#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
yay_installed="false"
paru_installed="false"
aur_helper=""

# --------------------------------------------------------------
# Library
# --------------------------------------------------------------

source $SCRIPT_DIR/_lib.sh

# --------------------------------------------------------------
# General Packages
# --------------------------------------------------------------

source $SCRIPT_DIR/pkgs.sh

# --------------------------------------------------------------
# Distro related packages
# --------------------------------------------------------------

packages=(
    # Hyprland ve ekleri
    "hyprland"
    "hyprpaper"
    "hyprlock"
    "hypridle"
    "hyprpicker"
    "waybar"
    "rofi-wayland"
    "nwg-look"
    "nwg-dock-hyprland"
    "wlogout"
    "swaync"
    "hyprshade"
    "uwsm"
    "hyprshot-git"
    # Sistem araçları
    "xdg-user-dirs"
    "xdg-desktop-portal-gtk"
    "xdg-desktop-portal-hyprland"
    "libnotify"
    "polkit-gnome"
    "power-profiles-daemon"
    "brightnessctl"
    "blueman"
    "nm-connection-editor"
    "network-manager-applet"
    "tumbler"
    "gvfs"
    "pacman-contrib"
 	"qemu-full"
    "qemu-desktop"
    "dnsmasq" 
    "iptables-nft"
    "libvirt" 
    "bridge-utils"
    # Terminal, editör ve CLI araçlar
    "kitty"
    "zsh"
    "zsh-completions"
    "zsh-autosuggestions"
    "zsh-autocomplete"
    "fzf"
    "neovim"
    "htop"
    "eza"
    "fastfetch"
    "figlet"
    "rsync"
    "wget"
    "unzip"
    "jq"
    "xclip"
    "gum"
    "python-pip"
    "python-gobject"
    "python-screeninfo"
    "checkupdates-with-aur"

    # Ses / multimedya
    "pavucontrol"
    "vlc"

    # Temalar ve ikonlar
    "papirus-icon-theme"
    "breeze"
    "bibata-cursor-theme"  # yay’dan geliyor ama buraya ekledim

    # Fonts
    "otf-font-awesome"
    "ttf-fira-sans"
    "ttf-fira-code"
    "ttf-firacode-nerd"
    "ttf-dejavu"
    "noto-fonts"
    "noto-fonts-emoji"
    "noto-fonts-cjk"
    "noto-fonts-extra"

    # Görsel araçlar
    "waypaper"
    "imagemagick"
    "grim"
    "slurp"
    "cliphist"
    "loupe"
    "grimblast-git"

    # Uygulamalar
    "discord"
    "visual-studio-code-bin"
    "libreoffice-still"
    "virt-manager"
    "discover"
    "flatpak"
    "pacseek"
    "docker-desktop"
    "vicinae"
    # Ek Python / AUR araçları
    "python-pywalfox"

    # Wayland / QT destekleri
    "qt5-wayland"
    "qt6-wayland"
    
    # User Requested Apps
    "firefox"
    "dolphin"
    "gnome-calculator"
)

_isInstalled() {
    package="$1"
    check="$(sudo pacman -Qs --color always "${package}" | grep "local" | grep "${package} ")"
    if [ -n "${check}" ]; then
        echo 0
        return #true
    fi
    echo 1
    return #false
}

_installYay() {
    if [[ ! $(_isInstalled "base-devel") == 0 ]]; then
        sudo pacman --noconfirm -S "base-devel"
    fi
    if [[ ! $(_isInstalled "git") == 0 ]]; then
        sudo pacman --noconfirm -S "git"
    fi
    if [ -d $HOME/Downloads/yay-bin ]; then
        rm -rf $HOME/Downloads/yay-bin
    fi
    SCRIPT=$(realpath "$0")
    temp_path=$(dirname "$SCRIPT")
    git clone https://aur.archlinux.org/yay-bin.git $HOME/Downloads/yay-bin
    cd $HOME/Downloads/yay-bin
    makepkg -si --noconfirm
    cd $temp_path
    echo ":: yay has been installed successfully."
}

_checkAURHelper() {
    if [[ $(_checkCommandExists "yay") == 0 ]]; then
        echo ":: yay is installed"
        aur_helper="yay"
    else
        echo ":: yay is not installed. Installing..."
        _installYay
        aur_helper="yay"
    fi
}

_installPackages() {
    for pkg; do
        if [[ $(_isInstalled "${pkg}") == 0 ]]; then
            echo ":: ${pkg} is already installed."
            continue
        fi
        $aur_helper --noconfirm -S "${pkg}"
    done
}

# --------------------------------------------------------------
# Install Gum
# --------------------------------------------------------------

if [[ $(_checkCommandExists "gum") == 0 ]]; then
    echo ":: gum is already installed"
else
    echo ":: The installer requires gum. gum will be installed now"
    sudo pacman --noconfirm -S gum
fi

# --------------------------------------------------------------
# Header
# --------------------------------------------------------------

_writeHeader "Arch"

# --------------------------------------------------------------
# Install yay if needed
# --------------------------------------------------------------

_checkAURHelper

# --------------------------------------------------------------
# General
# --------------------------------------------------------------

_installPackages "${general[@]}"

# --------------------------------------------------------------
# Apps
# --------------------------------------------------------------

_installPackages "${apps[@]}"

# --------------------------------------------------------------
# Tools
# --------------------------------------------------------------

_installPackages "${tools[@]}"

# --------------------------------------------------------------
# Packages
# --------------------------------------------------------------

_installPackages "${packages[@]}"

# --------------------------------------------------------------
# Hyprland
# --------------------------------------------------------------

_installPackages "${hyprland[@]}"

# --------------------------------------------------------------
# Create .local/bin folder
# --------------------------------------------------------------

if [ ! -d $HOME/.local/bin ]; then
    mkdir -p $HOME/.local/bin
fi
# --------------------------------------------------------------
# Oh My Zsh & Plugins
# --------------------------------------------------------------

echo ":: Installing Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo ":: Oh My Zsh already installed"
fi

echo ":: Installing Oh My Zsh plugins..."
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# fast-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/fast-syntax-highlighting" ]; then
    git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git "$ZSH_CUSTOM/plugins/fast-syntax-highlighting"
fi

# --------------------------------------------------------------
# Oh My Posh
# --------------------------------------------------------------
echo ":: Installing Oh My Posh..."
curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin

# --------------------------------------------------------------
# UV
# --------------------------------------------------------------

curl -LsSf https://astral.sh/uv/install.sh | sh
# --------------------------------------------------------------
# Prebuilt Packages
# --------------------------------------------------------------

source $SCRIPT_DIR/_prebuilt.sh

# --------------------------------------------------------------
# ML4W Apps
# --------------------------------------------------------------

# source $SCRIPT_DIR/_ml4w-apps.sh

# --------------------------------------------------------------
# Flatpaks
# --------------------------------------------------------------

source $SCRIPT_DIR/_flatpaks.sh

# --------------------------------------------------------------
# Cursors
# --------------------------------------------------------------

source $SCRIPT_DIR/_cursors.sh

# --------------------------------------------------------------
# Fonts
# --------------------------------------------------------------

source $SCRIPT_DIR/_fonts.sh

# --------------------------------------------------------------
# Install dotfiles using GNU Stow
# --------------------------------------------------------------

echo ":: Installing dotfiles with GNU Stow..."

SOURCE_DOTFILES_DIR="$SCRIPT_DIR/../dotfiles"
DEST_DOTFILES_DIR="$HOME/.dotfiles"

# Backup existing dotfiles directory if it exists
if [ -d "$DEST_DOTFILES_DIR" ]; then
    echo ":: Backing up existing .dotfiles directory..."
    mv "$DEST_DOTFILES_DIR" "$DEST_DOTFILES_DIR.bak.$(date +%Y%m%d-%H%M%S)"
fi

# Copy dotfiles to home directory
echo ":: Copying dotfiles to $DEST_DOTFILES_DIR..."
cp -r "$SOURCE_DOTFILES_DIR" "$DEST_DOTFILES_DIR"

# Install dotfiles using Stow
if [ -d "$DEST_DOTFILES_DIR" ]; then
    cd "$DEST_DOTFILES_DIR"
    echo ":: Installing dotfiles from $DEST_DOTFILES_DIR"
    
    # Install .config directory
    if [ -d ".config" ]; then
        echo ":: Stowing .config"
        stow -t "$HOME/.config" .config
    fi
    
    # Link root files
    for file in .zshrc .Xresources .gtkrc-2.0; do
        if [ -f "$file" ]; then
            echo ":: Linking $file"
            ln -sf "$PWD/$file" "$HOME/$file"
        fi
    done

    echo ":: Dotfiles installation completed"
else
    echo ":: Warning: dotfiles directory not found at $DEST_DOTFILES_DIR"
fi

# --------------------------------------------------------------
# Icons
# --------------------------------------------------------------

source $SCRIPT_DIR/_icons.sh

git config --global user.name "emirbartu"
git config --global user.email "bartuekinci42@gmail.com"

# if [ -f "$DEST_DOTFILES_DIR/zshrc/.zshrc" ]; then
#     echo ":: Installing custom .zshrc..."
#     cp -f "$DEST_DOTFILES_DIR/zshrc/.zshrc" "$HOME/.zshrc"
# fi

echo ":: Configuration complete! Please run 'source ~/.zshrc' or restart your terminal."

# --------------------------------------------------------------
# Finish
# --------------------------------------------------------------

_finishMessage
