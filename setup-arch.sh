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
# Copy dotfiles and home files
# -----------------------------------------------------
copy_dotfiles() {
    echo ":: Copying dotfiles to ~/.config"
    # Create ~/.config if it doesn't exist
    mkdir -p "$HOME/.config"
    
    # Copy contents of dotfilesfolder to ~/.config
    if [ -d "dotfilesfolder" ]; then
        cp -r dotfilesfolder/* "$HOME/.config/"
        echo ":: Dotfiles copied to ~/.config"
    else
        echo ":: dotfilesfolder not found, skipping dotfiles copy"
    fi
    
    echo ":: Copying home files to $HOME"
    # Copy contents of homefolder directly to home directory
    if [ -d "homefolder" ]; then
        cp -r homefolder/.* "$HOME/" 2>/dev/null || true
        cp -r homefolder/* "$HOME/" 2>/dev/null || true
        echo ":: Home files copied to $HOME"
    else
        echo ":: homefolder not found, skipping home files copy"
    fi
}

# Get latest tag from GitHub
get_latest_release() {
    curl --silent "https://api.github.com/repos/$repo/releases/latest" |
        grep '"tag_name":' |
        sed -E 's/.*"([^"]+)".*/\1/'
}

# Get latest zip from GitHub
get_latest_zip() {
    curl --silent "https://api.github.com/repos/$repo/releases/latest" |
        grep '"zipball_url":' |
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
            echo ":: ${pkg} is already installed."
            continue
        fi
        toInstall+=("${pkg}")
    done
    if [[ "${toInstall[@]}" == "" ]]; then
        return
    fi
    printf "Package not installed:\n%s\n" "${toInstall[@]}"
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
    echo ":: yay has been installed successfully."
}

# Install yay packages
_installYayPackages() {
    toInstall=()
    for pkg in "${yay_packages[@]}"; do
        if yay -Q "$pkg" &>/dev/null; then
            echo ":: ${pkg} is already installed (yay)."
        else
            toInstall+=("$pkg")
        fi
    done

    if [[ "${#toInstall[@]}" -eq 0 ]]; then
        echo ":: All yay packages already installed."
        return
    fi

    echo ":: Installing yay packages:"
    printf "%s\n" "${toInstall[@]}"
    yay --noconfirm -S "${toInstall[@]}"
}

# Required pacman packages for the installer
packages=(
    "wget"
    "unzip"
    "gum"
    "rsync"
    "git"
)

# Required yay packages
yay_packages=(
    git
    python
    nvidia
    visual-studio-code-bin
    spotify
    discord
    vlc
    kitty
    zsh
    discover
    flatpak
    neovim
    virt-manager
    oh-my-zsh-git
    zsh-theme-powerlevel10k-git
)

latest_version=$(get_latest_release)

# Some colors
GREEN='\033[0;32m'
NONE='\033[0m'

# Header
echo -e "${GREEN}"
cat <<"EOF"
   ____         __       ____
  /  _/__  ___ / /____ _/ / /__ ____
 _/ // _ \(_-</ __/ _ `/ / / -_) __/
/___/_//_/___/\__/\_,_/_/_/\__/_/
EOF
echo "ML4W Dotfiles for Hyprland"
echo -e "${NONE}"

while true; do
    read -p "DO YOU WANT TO START THE INSTALLATION NOW? (Yy/Nn): " yn
    case $yn in
        [Yy]*)
            echo ":: Installation started."
            echo
            break
            ;;
        [Nn]*)
            echo ":: Installation canceled"
            exit
            break
            ;;
        *)
            echo ":: Please answer yes or no."
            ;;
    esac
done

# Remove existing download folder and zip files
rm -rf $download_folder/dotfiles* $download_folder/yay

# Synchronize package databases
sudo pacman -Sy

# Install required pacman packages
echo ":: Checking that required packages are installed..."
_installPackages "${packages[@]}"

# Install yay if needed
if _checkCommandExists "yay"; then
    echo ":: yay is already installed"
else
    echo ":: The installer requires yay. yay will be installed now"
    _installYay
fi

# Install yay packages
echo
echo ":: Installing AUR packages using yay..."
_installYayPackages

# Select the dotfiles version
echo "Please choose between: "
echo "- ML4W Dotfiles for Hyprland $latest_version (latest stable release)"
echo "- ML4W Dotfiles for Hyprland Rolling Release (main branch including the latest commits)"
echo
version=$(gum choose "main-release" "rolling-release" "cancel")
if [ "$version" == "main-release" ]; then
    echo ":: Installing Main Release"
    git clone --branch $latest_version --depth 1 https://github.com/$repo.git $download_folder/dotfiles
elif [ "$version" == "rolling-release" ]; then
    echo ":: Installing Rolling Release"
    git clone --depth 1 https://github.com/$repo.git $download_folder/dotfiles
elif [ "$version" == "cancel" ]; then
    echo ":: Setup canceled"
    exit 130
else
    echo ":: Setup canceled"
    exit 130
fi

# Clone extra config repository
echo ":: Cloning extra config repository ($repo2)..."
git clone https://github.com/$repo2.git $download_folder/noktadosyalari

echo ":: Download complete."

# Copy dotfiles and home files
copy_dotfiles

cd $download_folder/dotfiles/bin/

gum spin --spinner dot --title "Starting the installation now..." -- sleep 3
./ml4w-hyprland-setup -m install

gum spin --spinner dot --title "Starting the setup now..." -- sleep 3
./ml4w-hyprland-setup -p arch