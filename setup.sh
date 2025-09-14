#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

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

    # Terminal, editör ve CLI araçlar
    "kitty"
    "zsh"
    "zsh-completions"
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

    # Uygulamalar
    "discord"
    "visual-studio-code-bin"
    "libreoffice-still"
    "virt-manager"
    "discover"
    "flatpak"
    "pacseek"

    # Ek Python / AUR araçları
    "python-pywalfox"
    "grimblast-git"
    "zsh-autosuggestions"
    "checkupdates-with-aur"
    "docker-desktop"
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
    makepkg -si
    cd $temp_path
    echo ":: yay has been installed successfully."
}

_installPackages() {
    for pkg; do
        if [[ $(_isInstalled "${pkg}") == 0 ]]; then
            echo ":: ${pkg} is already installed."
            continue
        fi
        yay --noconfirm -S "${pkg}"
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

if [[ $(_checkCommandExists "yay") == 0 ]]; then
    echo ":: yay is already installed"
else
    echo ":: The installer requires yay. yay will be installed now"
    _installYay
fi

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
# Oh My Posh
# --------------------------------------------------------------

curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin

# --------------------------------------------------------------
# Prebuilt Packages
# --------------------------------------------------------------

source $SCRIPT_DIR/_prebuilt.sh

# --------------------------------------------------------------
# ML4W Apps
# --------------------------------------------------------------

source $SCRIPT_DIR/_ml4w-apps.sh

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
# Finish
# --------------------------------------------------------------

_finishMessage
