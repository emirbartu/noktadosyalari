#!/usr/bin/env bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

echo ":: Installing dotfiles with GNU Stow..."

SOURCE_DOTFILES_DIR="$SCRIPT_DIR/../dotfiles"

if [ ! -d "$SOURCE_DOTFILES_DIR" ]; then
    echo ":: Error: Source dotfiles directory not found at $SOURCE_DOTFILES_DIR"
    exit 1
fi

# Create backup directory with timestamp
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

echo ":: Backing up conflicting files to $BACKUP_DIR..."
cd "$SOURCE_DOTFILES_DIR"

# Find all files/dirs that would conflict
for item in $(find . -maxdepth 1 ! -path . ! -path ./.git ! -path './.git/*'); do
    item_name=$(basename "$item")
    target="$HOME/$item_name"
    
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        echo ":: Backing up $item_name"
        mkdir -p "$BACKUP_DIR"
        cp -a "$target" "$BACKUP_DIR/"
        rm -rf "$target"
    fi
done

# Also check .config subdirectories
if [ -d ".config" ]; then
    for item in .config/*; do
        item_name=$(basename "$item")
        target="$HOME/.config/$item_name"
        
        if [ -e "$target" ] && [ ! -L "$target" ]; then
            echo ":: Backing up .config/$item_name"
            mkdir -p "$BACKUP_DIR/.config"
            cp -a "$target" "$BACKUP_DIR/.config/"
            rm -rf "$target"
        fi
    done
fi

# Now stow everything cleanly
echo ":: Stowing dotfiles..."
stow -v -t "$HOME" .

if [ $? -eq 0 ]; then
    echo ":: Successfully stowed all dotfiles"
    if [ -d "$BACKUP_DIR" ]; then
        echo ":: Backups saved to: $BACKUP_DIR"
    fi
else
    echo ":: Failed to stow dotfiles"
    exit 1
fi

echo ""
echo ":: ✓ Dotfiles installation completed"
echo ":: ✓ Symlinks created from: $SOURCE_DOTFILES_DIR"
if [ -d "$BACKUP_DIR" ]; then
    echo ":: ✓ Old files backed up to: $BACKUP_DIR"
fi

echo ""
echo ":: Configuration complete!"
echo ":: Run 'source ~/.zshrc' or restart your terminal."