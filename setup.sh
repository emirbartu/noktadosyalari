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
RED='\033[0;31m'
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

error() {
    echo -e "${RED}[ERROR]${NC} $1"
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
    failed_packages=()
    
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
    
    # Try to install packages one by one to identify problematic ones
    for pkg in "${toInstall[@]}"; do
        if ! sudo pacman --noconfirm -S "${pkg}" 2>/dev/null; then
            warn "Failed to install ${pkg}, skipping..."
            failed_packages+=("${pkg}")
        else
            success "Installed ${pkg}"
        fi
    done
    
    if [[ "${#failed_packages[@]}" -gt 0 ]]; then
        warn "Failed to install the following packages: ${failed_packages[*]}"
        warn "You may need to install these manually or from AUR"
    fi
}

# install yay if needed
_installYay() {
    log "Installing build dependencies..."
    _installPackages "base-devel" "git"
    
    SCRIPT=$(realpath "$0")
    temp_path=$(dirname "$SCRIPT")
    
    # Clean up any existing yay directory
    rm -rf "$download_folder/yay"
    
    log "Cloning yay repository..."
    if ! git clone https://aur.archlinux.org/yay.git "$download_folder/yay"; then
        error "Failed to clone yay repository. Checking network connectivity..."
        if ! ping -c 1 google.com >/dev/null 2>&1; then
            error "No internet connection detected. Please check your network."
            exit 1
        fi
        error "Network appears to be working but git clone failed. Trying alternative method..."
        
        # Try wget as fallback
        cd "$download_folder"
        if ! wget https://aur.archlinux.org/cgit/aur.git/snapshot/yay.tar.gz; then
            error "Failed to download yay. Please check your internet connection."
            exit 1
        fi
        tar -xzf yay.tar.gz
        mv yay-* yay
        rm yay.tar.gz
    fi
    
    cd "$download_folder/yay"
    if ! makepkg -si --noconfirm; then
        error "Failed to build yay. Please check the error messages above."
        exit 1
    fi
    cd "$temp_path"
    success "yay has been installed successfully."
}

# Install yay packages
_installYayPackages() {
    if ! _checkCommandExists "yay"; then
        error "yay is not available. Cannot install AUR packages."
        return 1
    fi
    
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
    
    # Install packages one by one to handle failures gracefully
    for pkg in "${toInstall[@]}"; do
        if ! yay --noconfirm -S "$pkg"; then
            warn "Failed to install ${pkg} from AUR, skipping..."
        else
            success "Installed ${pkg} from AUR"
        fi
    done
}

# Required pacman packages for the installer (removed problematic ones)
packages=(
    "wget"
    "unzip"
    "gum"
    "rsync"
    "git"
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
    "otf-font-awesome"
    "ttf-fira-sans"
    "ttf-fira-code"
    "ttf-firacode-nerd"
    "ttf-dejavu"
    "nwg-dock-hyprland"
    "power-profiles-daemon"
    "vlc"
)

# Required yay packages (moved problematic pacman packages here)
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
    "bibata-cursor-theme"
    "pacseek"
    "python-pywalfox"
    "grimblast-git"
)

# Simple choice function as fallback for gum
simple_choice() {
    local prompt="$1"
    shift
    local options=("$@")
    
    echo "$prompt"
    for i in "${!options[@]}"; do
        echo "$((i+1)). ${options[i]}"
    done
    
    while true; do
        read -p "Enter your choice (1-${#options[@]}): " choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#options[@]}" ]; then
            echo "${options[$((choice-1))]}"
            return
        else
            echo "Invalid choice. Please enter a number between 1 and ${#options[@]}."
        fi
    done
}

# Main setup function
main() {
    echo -e "${GREEN}"
    cat <<"EOF"
╔═══════════════════════════════════════╗
║     ML4W Dotfiles Setup Script       ║
║     Fixed for CachyOS                 ║
╚═══════════════════════════════════════╝
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
    
    # Check internet connectivity
    log "Checking internet connectivity..."
    if ! ping -c 1 google.com >/dev/null 2>&1; then
        error "No internet connection detected. Please check your network and try again."
        exit 1
    fi
    success "Internet connection verified"
    
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
    log "Updating package databases..."
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

    # Get latest version
    latest_version=$(get_latest_release)
    if [ -z "$latest_version" ]; then
        warn "Could not fetch latest version, using fallback"
        latest_version="2.9.9"
    fi

    # Select the dotfiles version
    log "Please choose between: "
    log "- ML4W Dotfiles for Hyprland $latest_version (latest stable release)"
    log "- ML4W Dotfiles for Hyprland Rolling Release (main branch including the latest commits)"
    echo
    
    if _checkCommandExists "gum"; then
        version=$(gum choose "main-release" "rolling-release" "cancel")
    else
        warn "gum not available, using fallback selection"
        version=$(simple_choice "Choose version:" "main-release" "rolling-release" "cancel")
    fi
    
    case "$version" in
        "main-release")
            log "Installing Main Release ($latest_version)"
            if ! git clone --branch $latest_version --depth 1 https://github.com/$repo.git $download_folder/dotfiles; then
                error "Failed to clone main release, trying without specific tag"
                git clone --depth 1 https://github.com/$repo.git $download_folder/dotfiles
            fi
            ;;
        "rolling-release")
            log "Installing Rolling Release"
            git clone --depth 1 https://github.com/$repo.git $download_folder/dotfiles
            ;;
        "cancel")
            log "Setup canceled"
            exit 130
            ;;
        *)
            log "Setup canceled"
            exit 130
            ;;
    esac

    # Clone extra config repository
    log "Cloning extra config repository ($repo2)..."
    if ! git clone https://github.com/$repo2.git $download_folder/noktadosyalari; then
        warn "Failed to clone extra config repository, continuing..."
    fi

    log "Download complete."

    # Copy dotfiles and home files
    copy_dotfiles

    if [ -d "$download_folder/dotfiles/bin/" ]; then
        cd $download_folder/dotfiles/bin/

        # Check if ml4w-hyprland-setup exists
        if [ -f "./ml4w-hyprland-setup" ]; then
            if _checkCommandExists "gum"; then
                gum spin --spinner dot --title "Starting the installation now..." -- sleep 3
            else
                log "Starting the installation now..."
                sleep 3
            fi
            
            ./ml4w-hyprland-setup -m install

            if _checkCommandExists "gum"; then
                gum spin --spinner dot --title "Starting the setup now..." -- sleep 3
            else
                log "Starting the setup now..."
                sleep 3
            fi
            
            ./ml4w-hyprland-setup -p arch
        else
            warn "ml4w-hyprland-setup not found, skipping ML4W setup"
        fi
    else
        warn "dotfiles/bin directory not found, skipping ML4W setup"
    fi
    
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