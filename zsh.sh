#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
DOTFILES_DIR="$SCRIPT_DIR/dotfiles"
ZSHRC_SOURCE="$DOTFILES_DIR/.zshrc"

echo ":: ZSH RESET + REINSTALL STARTED"

# --------------------------------------------------
# Safety check
# --------------------------------------------------
if [[ ! -f "$ZSHRC_SOURCE" ]]; then
    echo "!! .zshrc not found at $ZSHRC_SOURCE"
    exit 1
fi

# --------------------------------------------------
# Reset phase
# --------------------------------------------------

echo ":: Removing zsh related configs"

# shell config
rm -f  ~/.zshrc
rm -rf ~/.zsh*
rm -rf ~/.oh-my-zsh
rm -rf ~/.cache/oh-my-posh
rm -rf ~/.config/oh-my-posh

# binaries
rm -f ~/.local/bin/oh-my-posh || true

# --------------------------------------------------
# Remove zsh packages
# --------------------------------------------------

echo ":: Removing zsh packages via pacman"

sudo pacman -Rns --noconfirm \
    zsh \
    zsh-completions \
    zsh-autosuggestions \
    zsh-autocomplete \
    2>/dev/null || true

# --------------------------------------------------
# Reinstall phase
# --------------------------------------------------

echo ":: Installing zsh packages"

sudo pacman -S --noconfirm \
    zsh \
    zsh-completions \
    zsh-autosuggestions \
    zsh-autocomplete

# --------------------------------------------------
# Ensure ~/.local/bin
# --------------------------------------------------

mkdir -p ~/.local/bin

# --------------------------------------------------
# Oh My Zsh
# --------------------------------------------------

echo ":: Installing Oh My Zsh (unattended)"

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# --------------------------------------------------
# Oh My Zsh plugins
# --------------------------------------------------

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

echo ":: Installing Oh My Zsh plugins"

git clone https://github.com/zsh-users/zsh-autosuggestions \
    "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
    "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git \
    "$ZSH_CUSTOM/plugins/fast-syntax-highlighting"

# --------------------------------------------------
# Oh My Posh
# --------------------------------------------------

echo ":: Installing Oh My Posh"

curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin

# --------------------------------------------------
# Install .zshrc
# --------------------------------------------------

echo ":: Installing custom .zshrc"

cp -f "$ZSHRC_SOURCE" "$HOME/.zshrc"

# --------------------------------------------------
# Set default shell
# --------------------------------------------------

if [[ "$SHELL" != "$(which zsh)" ]]; then
    echo ":: Setting zsh as default shell"
    chsh -s "$(which zsh)"
fi

# --------------------------------------------------
# Finish
# --------------------------------------------------

echo ":: ZSH RESET + REINSTALL COMPLETE"
echo ":: Run: source ~/.zshrc  (or logout/login)"
