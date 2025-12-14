#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
yay_installed="false"
paru_installed="false"
aur_helper=""

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
    
    # Install each directory in dotfiles
    for dir in */; do
        if [ -d "$dir" ]; then
            echo ":: Stowing $dir"
            stow -t "$HOME/.config" -D "$dir" # Remove existing symlinks first
            stow -t "$HOME/.config" "$dir"
            if [ $? -eq 0 ]; then
                echo ":: Successfully installed $dir"
            else
                echo ":: Failed to install $dir"
            fi
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

if [ -f "$DEST_DOTFILES_DIR/zshrc/.zshrc" ]; then
    echo ":: Installing custom .zshrc..."
    cp -f "$DEST_DOTFILES_DIR/zshrc/.zshrc" "$HOME/.zshrc"
fi

echo ":: Configuration complete! Please run 'source ~/.zshrc' or restart your terminal."
