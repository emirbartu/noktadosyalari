#!/bin/bash

# Renkler
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}:: macOS Kurulum Scripti Başlatılıyor...${NC}"

# --------------------------------------------------------------
# 1. Homebrew Kontrolü ve Kurulumu
# --------------------------------------------------------------
if ! command -v brew &> /dev/null; then
    echo -e "${YELLOW}:: Homebrew bulunamadı. Kuruluyor...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Apple Silicon (M1/M2/M3) için path eklemesi
    if [[ $(uname -m) == 'arm64' ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo -e "${GREEN}:: Homebrew zaten yüklü.${NC}"
fi

echo -e "${BLUE}:: Homebrew güncelleniyor...${NC}"
brew update

# --------------------------------------------------------------
# 2. Paket Listeleri
# --------------------------------------------------------------

# CLI Araçları (Formulae)
formulae=(
    "git"
    "wget"
    "curl"
    "rsync"
    "unzip"
    "jq"
    "fzf"              # Arama
    "neovim"           # Editör
    "htop"             # Sistem izleme
    "btop"             # Daha modern sistem izleme
    "eza"              # ls alternatifi
    "fastfetch"        # Sistem bilgisi (neofetch alternatifi)
    "figlet"           # ASCII yazı
    "gum"              # Script görselleştirme (orijinal scriptteki gibi)
    "python"
    "node"
    "zsh-autosuggestions"     # Brew üzerinden de kurulabilir ama manuel config yapacağız
    "zsh-syntax-highlighting"
    "imagemagick"
)

# GUI Uygulamaları (Casks)
casks=(
    "kitty"                 # Terminal
    "visual-studio-code"    # Editör
    "discord"               # İletişim
    "vlc"                   # Medya Oynatıcı
    "libreoffice"           # Ofis
    "docker"                # Docker Desktop
    "flatpak"               # macOS desteği sınırlıdır ama cask olarak eklenebilir (genelde gerekmez, isteğe bağlı)
    "font-fira-code-nerd-font" # Terminal için gerekli font
)

# --------------------------------------------------------------
# 3. Paketlerin Kurulumu
# --------------------------------------------------------------

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

# --------------------------------------------------------------
# 4. Zsh Konfigürasyonu (Otomatik)
# --------------------------------------------------------------

echo -e "${BLUE}:: Zsh Konfigürasyonu Yapılıyor...${NC}"

# Oh My Zsh Kurulumu (Eğer yoksa)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo -e "${YELLOW}:: Oh My Zsh kuruluyor...${NC}"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo -e "${GREEN}:: Oh My Zsh zaten kurulu.${NC}"
fi

# Zsh Eklentileri (Autosuggestions & Syntax Highlighting)
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo ":: zsh-autosuggestions indiriliyor..."
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo ":: zsh-syntax-highlighting indiriliyor..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting
fi

# .zshrc dosyasını oluşturma/güncelleme
ZSHRC="$HOME/.zshrc"
BACKUP_ZSHRC="$HOME/.zshrc.backup.$(date +%s)"

if [ -f "$ZSHRC" ]; then
    echo -e "${YELLOW}:: Mevcut .zshrc yedekleniyor: $BACKUP_ZSHRC${NC}"
    cp "$ZSHRC" "$BACKUP_ZSHRC"
fi

echo -e "${BLUE}:: Yeni .zshrc dosyası yazılıyor...${NC}"

cat <<EOT > "$ZSHRC"
# Path yapılandırması
export PATH=\$HOME/bin:/usr/local/bin:\$PATH
export ZSH="\$HOME/.oh-my-zsh"

# Tema (Basit ve şık bir tema: robbyrussell varsayılandır, agnoster popülerdir)
ZSH_THEME="robbyrussell"

# Eklentiler
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    brew
    docker
    vscode
    macos
)

source \$ZSH/oh-my-zsh.sh

# Kullanıcı Konfigürasyonları
alias ll="eza -l -g --icons"
alias ls="eza --icons"
alias v="nvim"
alias c="clear"
alias update="brew update && brew upgrade && brew cleanup"

# FZF Ayarları
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Fastfetch açılışta çalışsın
fastfetch

EOT

# --------------------------------------------------------------
# 5. Bitiş
# --------------------------------------------------------------

echo -e "${GREEN}--------------------------------------------------------------${NC}"
echo -e "${GREEN}:: Kurulum Tamamlandı!${NC}"
echo -e "${GREEN}:: Zsh ayarlarının aktif olması için terminali kapatıp açın${NC}"
echo -e "${GREEN}:: veya şu komutu çalıştırın: source ~/.zshrc${NC}"
echo -e "${GREEN}--------------------------------------------------------------${NC}"