# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Overview

This repository contains a fork of the ML4W (My Linux for Work) dotfiles for Hyprland, customized with personal preferences. It provides an advanced configuration for the dynamic tiling window manager Hyprland, designed for Arch Linux, Fedora, and openSuse distributions.

## Installation and Setup

### Dotfiles Installer

The recommended installation method is using the Dotfiles Installer from Flathub:

```bash
# Stable release URL
https://raw.githubusercontent.com/emirbartu/noktodosyalari/main/hyprland-dotfiles.dotinst
```

### Running Setup Scripts

For manual installation or dependency setup:

```bash
# Run setup script (auto-detects distribution)
./setup/setup.sh

# Run distribution-specific setup
./setup/setup-arch.sh
./setup/setup-fedora.sh
./setup/setup-opensuse.sh
```

### Core Components

- `dotfiles/` - The actual configuration files that will be installed
  - `.config/hypr/` - Hyprland window manager configuration
  - `.config/hypr/conf/` - Modular configuration files (keybindings, decorations, etc.)
  - `.config/waybar/` - Status bar configuration
  - `.config/kitty/` - Terminal configuration
  - `.config/ml4w/` - ML4W-specific apps and settings
  - `.zshrc`, `.bashrc` - Shell configurations

- `setup/` - Installation scripts for different distributions
  - `setup.sh` - Main setup script (distribution auto-detection)
  - `setup-arch.sh` - Arch Linux specific setup
  - `setup-fedora.sh` - Fedora specific setup
  - `setup-opensuse.sh` - openSUSE specific setup
  - Helper scripts for fonts, icons, themes, and applications

- `hyprland-dotfiles.dotinst` - Configuration file for the Dotfiles Installer

## Configuration Management

The dotfiles are organized modularly, with key components in separate files:
- Keyboard configuration: `.config/hypr/conf/keyboard.conf`
- Monitor settings: `.config/hypr/conf/monitor.conf`
- Keybindings: `.config/hypr/conf/keybinding.conf`
- Window rules: `.config/hypr/conf/windowrule.conf`
- Environment variables: `.config/hypr/conf/environment.conf`
- Custom configuration: `.config/hypr/conf/custom.conf`

## System Dependencies

The setup scripts install numerous packages for a complete Hyprland environment:
- Hyprland and associated tools (hyprpaper, hyprlock, hypridle)
- Wayland-compatible applications
- Theming and appearance packages
- Development tools
- Fonts

The full list is in `setup/setup-arch.sh` (and corresponding distribution-specific files).

## Dotfiles Installer Configuration

The `.dotinst` file defines:
- Installer metadata (name, version, author)
- Source repository location
- Which configuration files to preserve during updates
- Initial settings that users can configure during installation