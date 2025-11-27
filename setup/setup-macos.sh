#!/bin/bash

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}:: macOS Kurulum Scripti Başlatılıyor...${NC}"

if ! command -v brew &> /dev/null; then
    echo -e "${YELLOW}:: Homebrew bulunamadı. Kuruluyor...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [[ $(uname -m) == 'arm64' ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo -e "${GREEN}:: Homebrew zaten yüklü.${NC}"
fi

echo -e "${BLUE}:: Homebrew güncelleniyor...${NC}"
brew update

formulae=(
    "git"
    "wget"
    "curl"
    "rsync"
    "unzip"
    "jq"
    "fzf"
    "neovim"
    "htop"
    "btop"
    "eza"
    "fastfetch"
    "figlet"
    "gum"
    "python"
    "node"
    "imagemagick"
)

casks=(
    "kitty"
    "visual-studio-code"
    "discord"
    "vlc"
    "docker"
    "font-fira-code-nerd-font"
)

echo -e "${BLUE}:: CLI Araçları Kuruluyor...${NC}"
for formula in "${formulae[@]}"; do
    if brew list --formula | grep -q "^${formula}$"; then
        echo -e "${GREEN}:: $formula zaten yüklü.${NC}"
    else
        echo -e "${YELLOW}:: $formula kuruluyor...${NC}"
        brew install "$formula"
    fi
done

echo -e "${BLUE}:: GUI Uygulamaları (Cask) Kuruluyor...${NC}"
for cask in "${casks[@]}"; do
    if brew list --cask | grep -q "^${cask}$"; then
        echo -e "${GREEN}:: $cask zaten yüklü.${NC}"
    else
        echo -e "${YELLOW}:: $cask kuruluyor...${NC}"
        brew install --cask "$cask"
    fi
done

echo -e "${BLUE}:: GNU Stow ile dotfiles kuruluyor...${NC}"
if [ -d "$HOME/macos-dotfiles" ]; then
    cd "$HOME/macos-dotfiles"
    for dir in */; do
        stow -v "$dir"
    done
else
    echo -e "${YELLOW}:: macos-dotfiles klasörü bulunamadı.${NC}"
fi

echo -e "${GREEN}--------------------------------------------------------------${NC}"
echo -e "${GREEN}:: Kurulum Tamamlandı!${NC}"
echo -e "${GREEN}--------------------------------------------------------------${NC}"
