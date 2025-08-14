#!/bin/bash
clear

# -----------------------------------------------------
# Repository
# -----------------------------------------------------
repo="mylinuxforwork/dotfiles"
repo2="emirbartu/noktadosyalari"

# -----------------------------------------------------
# Download Folder
# -----------------------------------------------------
download_folder="$HOME/.ml4w"

# Create download_folder if not exists
if [ ! -d $download_folder ]; then
    mkdir -p $download_folder
fi

# -----------------------------------------------------
# Color definitions
# -----------------------------------------------------
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# -----------------------------------------------------
# Logging functions
# -----------------------------------------------------
log() {
    echo -e "${BLUE}[SETUP]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warn() {
    echo -e "${BLUE}[WARNING]${NC} $1"
}

# -----------------------------------------------------
# Copy dotfiles and home files
# -----------------------------------------------------
copy_dotfiles() {
    log "Copying dotfiles to ~/.config"
    # Create ~/.config if it doesn't exist
    mkdir -p "$HOME/.config"
    
    # Copy contents of dotfilesfolder to ~/.config
    if [ -d "dotfilesfolder" ]; then
        cp -r dotfilesfolder/* "$HOME/.config/"
        success "Dotfiles copied to ~/.config"
    else
        warn "dotfilesfolder not found, skipping dotfiles copy"
    fi
    
    log "Copying home files to $HOME"
    # Copy contents of homefolder directly to home directory
    if [ -d "homefolder" ]; then
        cp -r homefolder/.* "$HOME/" 2>/dev/null || true
        cp -r homefolder/* "$HOME/" 2>/dev/null || true
        success "Home files copied to $HOME"
    else
        warn "homefolder not found, skipping home files copy"
    fi
}

# Get latest tag from GitHub
get_latest_release() {
    curl --silent "https://api.github.com/repos/$repo/releases/latest" |
        grep '"tag_name":' |
        sed -E 's/.*"([^"]+)".*/\1/'
}

# Check if package is installed
_isInstalled() {
    package="$1"
    check="$(sudo pacman -Qs --color always "${package}" | grep "local" | grep "${package} ")"
    if [ -n "${check}" ]; then
        echo 0
        return
    fi
    echo 1
    return
}

# Check if command exists
_checkCommandExists() {
    package="$1"
    if ! command -v $package >/dev/null; then
        return 1
    else
        return 0
    fi
}

# Install required packages
_installPackages() {
    toInstall=()
    for pkg; do
        if [[ $(_isInstalled "${pkg}") == 0 ]]; then
            log "${pkg} is already installed."
            continue
        fi
        toInstall+=("${pkg}")
    done
    if [[ "${toInstall[@]}" == "" ]]; then
        return
    fi
    log "Installing packages: ${toInstall[*]}"
    sudo pacman --noconfirm -S "${toInstall[@]}"
}

# install yay if needed
_installYay() {
    _installPackages "base-devel"
    SCRIPT=$(realpath "$0")
    temp_path=$(dirname "$SCRIPT")
    git clone https://aur.archlinux.org/yay.git $download_folder/yay
    cd $download_folder/yay
    makepkg -si
    cd $temp_path
    success "yay has been installed successfully."
}

# Install yay packages
_installYayPackages() {
    toInstall=()
    for pkg in "${yay_packages[@]}"; do
        if yay -Q "$pkg" &>/dev/null; then
            log "${pkg} is already installed (yay)."
        else
            toInstall+=("$pkg")
        fi
    done

    if [[ "${#toInstall[@]}" -eq 0 ]]; then
        log "All yay packages already installed."
        return
    fi

    log "Installing yay packages: ${toInstall[*]}"
    yay --noconfirm -S "${toInstall[@]}"
}

# Required pacman packages for the installer
packages=(
    "wget"
    "unzip"
    "gum"
    "rsync"
    "git"
    "wget"
    "figlet"
    "xdg-user-dirs"    
    "hyprland"
    "hyprpaper"
    "hyprlock"
    "hypridle"
    "hyprpicker"
    "noto-fonts"
    "noto-fonts-emoji"
    "noto-fonts-cjk"
    "noto-fonts-extra"
    "xdg-desktop-portal-gtk"
    "xdg-desktop-portal-hyprland"
    "libnotify"
    "kitty"
    "qt5-wayland"
    "qt6-wayland"
    "fastfetch"
    "eza"
    "python-pip"
    "python-gobject"
    "python-screeninfo"
    "tumbler"
    "brightnessctl"
    "nm-connection-editor"
    "network-manager-applet"
    "imagemagick"
    "jq"
    "xclip"
    "kitty"
    "neovim"
    "htop"
    "blueman"
    "grim"
    "slurp"
    "cliphist"
    "nwg-look"
    "qt6ct"
    "waybar"
    "rofi-wayland"
    "polkit-gnome"
    "zsh"
    "zsh-completions"
    "fzf"
    "pavucontrol"
    "papirus-icon-theme"
    "breeze"
    "flatpak"
    "swaync"
    "gvfs"
    "wlogout"
    "waypaper"
    "grimblast-git"
    "bibata-cursor-theme"
    "pacseek"
    "otf-font-awesome"
    "ttf-fira-sans"
    "ttf-fira-code"
    "ttf-firacode-nerd"
    "ttf-dejavu"
    "nwg-dock-hyprland"
    "power-profiles-daemon"
    "python-pywalfox"
    "vlc"
)

# Required yay packages
yay_packages=(
    "git"
    "python"
    "nvidia"
    "discord"
    "vlc"
    "kitty"
    "zsh"
    "discover"
    "flatpak"
    "neovim"
    "virt-manager"
    "libreoffice-still"
    "visual-studio-code-bin"
)

latest_version=$(get_latest_release)

# Main setup function
main() {
    echo -e "${GREEN}"
    cat <<"EOF"

EOF
    echo -e "${NC}"
    log "Starting unified setup process..."
    
    # Ask user to confirm installation
    while true; do
        read -p "DO YOU WANT TO START THE INSTALLATION NOW? (Yy/Nn): " yn
        case $yn in
            [Yy]*)
                log "Installation started."
                echo
                break
                ;;
            [Nn]*)
                log "Installation canceled"
                exit
                break
                ;;
            *)
                log "Please answer yes or no."
                ;;
        esac
    done
    
    # Setup main project (dotfiles) with package installation
    setup_main_project
    
    # Setup personal dotfiles
    setup_personal_dotfiles
    
    success "Setup completed successfully!"
    log "You can now start Hyprland with 'Hyprland' command"
}

# Setup main project (dotfiles) with package installation
setup_main_project() {
    log "Setting up main project (dotfiles)..."
    
    # Remove existing download folder and zip files
    rm -rf $download_folder/dotfiles* $download_folder/yay

    # Synchronize package databases
    sudo pacman -Sy

    # Install required pacman packages
    log "Checking that required packages are installed..."
    _installPackages "${packages[@]}"

    # Install yay if needed
    if _checkCommandExists "yay"; then
        log "yay is already installed"
    else
        log "The installer requires yay. yay will be installed now"
        _installYay
    fi

    # Install yay packages
    log "Installing AUR packages using yay..."
    _installYayPackages

    # Select the dotfiles version
    log "Please choose between: "
    log "- ML4W Dotfiles for Hyprland $latest_version (latest stable release)"
    log "- ML4W Dotfiles for Hyprland Rolling Release (main branch including the latest commits)"
    echo
    version=$(gum choose "main-release" "rolling-release" "cancel")
    if [ "$version" == "main-release" ]; then
        log "Installing Main Release"
        git clone --branch $latest_version --depth 1 https://github.com/$repo.git $download_folder/dotfiles
    elif [ "$version" == "rolling-release" ]; then
        log "Installing Rolling Release"
        git clone --depth 1 https://github.com/$repo.git $download_folder/dotfiles
    elif [ "$version" == "cancel" ]; then
        log "Setup canceled"
        exit 130
    else
        log "Setup canceled"
        exit 130
    fi

    # Clone extra config repository
    log "Cloning extra config repository ($repo2)..."
    git clone https://github.com/$repo2.git $download_folder/noktadosyalari

    log "Download complete."

    # Copy dotfiles and home files
    copy_dotfiles

    cd $download_folder/dotfiles/bin/

    gum spin --spinner dot --title "Starting the installation now..." -- sleep 3
    ./ml4w-hyprland-setup -m install

    gum spin --spinner dot --title "Starting the setup now..." -- sleep 3
    ./ml4w-hyprland-setup -p arch
    
    success "Main project setup completed"
}

# Setup personal dotfiles
setup_personal_dotfiles() {
    log "Setting up personal dotfiles..."
    
    # Copy dotfilesfolder contents to ~/.config
    if [ -d "dotfilesfolder" ]; then
        log "Copying dotfilesfolder to ~/.config..."
        mkdir -p ~/.config
        cp -r dotfilesfolder/* ~/.config/ 2>/dev/null || true
        success "Dotfilesfolder contents copied to ~/.config"
    else
        warn "dotfilesfolder not found"
    fi
    
    # Copy homefolder contents to ~
    if [ -d "homefolder" ]; then
        log "Copying homefolder to home directory..."
        # Copy hidden files (starting with .)
        cp -r homefolder/.* ~/ 2>/dev/null || true
        # Copy regular files
        cp -r homefolder/* ~/ 2>/dev/null || true
        success "Homefolder contents copied to home directory"
    else
        warn "homefolder not found"
    fi
    
    success "Personal dotfiles setup completed"
}

# Run main function
main "$@"