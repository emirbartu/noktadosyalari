export EDITOR=nvim
export ZSH="$HOME/.oh-my-zsh"
export PATH=$PATH:~/.cargo/bin/
export PATH=$PATH:~/.local/bin/

POSH=agnoster
ZSH_THEME="avit"
plugins=(
    git
    sudo
    web-search
    archlinux
    zsh-autosuggestions
    zsh-syntax-highlighting
    fast-syntax-highlighting
    copyfile
    copybuffer
    dirhistory
)

source $ZSH/oh-my-zsh.sh
source /usr/share/zsh/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh

source <(fzf --zsh)

# zsh history
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/zen.toml)"

alias c='clear'
alias ff='fastfetch'
alias ls='eza -a --icons=always'
alias ll='eza -al --icons=always'
alias lt='eza -a --tree --level=1 --icons=always'
alias shutdown='systemctl poweroff'
alias ts='~/.config/ml4w/scripts/arch/snapshot.sh'
alias wifi='nmtui'
alias cleanup='~/.config/ml4w/scripts/arch/cleanup.sh'
alias fuzzy='fzf --preview="cat {}" | xargs -r nvim'
alias git-keygen='ssh-keygen -t ed25519 -C "bartuekinci42@gmail.com"'
alias desk="cd ~/Desktop"

alias Qtile='startx'
# Hyprland with Hyprland

# -----------------------------------------------------
# System
# -----------------------------------------------------
alias update-grub='sudo grub-mkconfig -o /boot/grub/grub.cfg'

# -----------------------------------------------------
# Qtile
# -----------------------------------------------------
alias res1='xrandr --output DisplayPort-0 --mode 2560x1440 --rate 120'
alias res2='xrandr --output DisplayPort-0 --mode 1920x1080 --rate 120'
alias setkb='setxkbmap de;echo "Keyboard set back to de."'

# -----------------------------------------------------
# AUTOSTART
# -----------------------------------------------------

# -----------------------------------------------------
# Fastfetch
# -----------------------------------------------------
if [[ $(tty) == *"pts"* ]]; then
    fastfetch
fi
