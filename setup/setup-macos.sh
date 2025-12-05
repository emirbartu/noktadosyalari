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

echo -e "${BLUE}:: GNU Stow kuruluyor...${NC}"
if brew list --formula | grep -q "^stow$"; then
    echo -e "${GREEN}:: GNU Stow zaten yüklü.${NC}"
else
    echo -e "${YELLOW}:: GNU Stow kuruluyor...${NC}"
    brew install stow
fi

echo -e "${BLUE}:: Oh My Zsh kuruluyor...${NC}"
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo -e "${GREEN}:: Oh My Zsh zaten yüklü.${NC}"
else
    echo -e "${YELLOW}:: Oh My Zsh kuruluyor...${NC}"
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}:: Oh My Zsh başarıyla kuruldu.${NC}"
    else
        echo -e "${RED}:: Oh My Zsh kurulumu başarısız.${NC}"
    fi
fi

# Read formulae from file
formulae_file="$SCRIPT_DIR/../macos/dotfiles/homebrew/formulae.txt"
casks_file="$SCRIPT_DIR/../macos/dotfiles/homebrew/casks.txt"

echo -e "${BLUE}:: CLI Araçları Kuruluyor...${NC}"
if [ -f "$formulae_file" ]; then
    while IFS= read -r formula; do
        if [ -n "$formula" ]; then
            if brew list --formula | grep -q "^${formula}$"; then
                echo -e "${GREEN}:: $formula zaten yüklü.${NC}"
            else
                echo -e "${YELLOW}:: $formula kuruluyor...${NC}"
                brew install "$formula"
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}:: $formula başarıyla kuruldu.${NC}"
                else
                    echo -e "${RED}:: $formula kurulumu başarısız.${NC}"
                fi
            fi
        fi
    done < "$formulae_file"
else
    echo -e "${YELLOW}:: Formula dosyası bulunamadı: $formulae_file${NC}"
fi

echo -e "${BLUE}:: GUI Uygulamaları (Cask) Kuruluyor...${NC}"
if [ -f "$casks_file" ]; then
    while IFS= read -r cask; do
        if [ -n "$cask" ]; then
            if brew list --cask | grep -q "^${cask}$"; then
                echo -e "${GREEN}:: $cask zaten yüklü.${NC}"
            else
                echo -e "${YELLOW}:: $cask kuruluyor...${NC}"
                brew install --cask "$cask"
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}:: $cask başarıyla kuruldu.${NC}"
                else
                    echo -e "${RED}:: $cask kurulumu başarısız.${NC}"
                fi
            fi
        fi
    done < "$casks_file"
else
    echo -e "${YELLOW}:: Cask dosyası bulunamadı: $casks_file${NC}"
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR/../macos/dotfiles"

echo -e "${BLUE}:: GNU Stow ile dotfiles kuruluyor...${NC}"

if [ -d "$DOTFILES_DIR" ]; then
    cd "$DOTFILES_DIR"
    echo -e "${BLUE}:: Dotfiles kuruluyor: $DOTFILES_DIR${NC}"
    
    # Install each directory in macos/dotfiles
    for dir in */; do
        if [ -d "$dir" ]; then
            echo -e "${YELLOW}:: $dir kuruluyor...${NC}"
            stow -t ~ "$dir"
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}:: $dir başarıyla kuruldu.${NC}"
            else
                echo -e "${RED}:: $dir kurulumu başarısız.${NC}"
            fi
        fi
    done
    echo -e "${GREEN}:: Dotfiles kurulumu tamamlandı.${NC}"
else
    echo -e "${YELLOW}:: macos/dotfiles klasörü bulunamadı: $DOTFILES_DIR${NC}"
fi

echo -e "${GREEN}--------------------------------------------------------------${NC}"
echo -e "${GREEN}:: Kurulum Tamamlandı!${NC}"
echo -e "${GREEN}--------------------------------------------------------------${NC}"
