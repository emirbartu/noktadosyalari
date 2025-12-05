#!/bin/bash

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=== Dotfiles Setup Test ===${NC}"
echo

# Test OS Detection
echo -e "${BLUE}Testing OS Detection...${NC}"
if [[ "$(uname -s)" == "Darwin" ]]; then
    echo -e "${GREEN}✓ Detected macOS${NC}"
    EXPECTED_SCRIPT="setup-macos.sh"
else
    echo -e "${GREEN}✓ Detected Linux${NC}"
    EXPECTED_SCRIPT="setup-arch.sh"
fi
echo

# Test Script Existence
echo -e "${BLUE}Testing Script Existence...${NC}"
if [ -f "setup/setup.sh" ]; then
    echo -e "${GREEN}✓ setup/setup.sh exists${NC}"
else
    echo -e "${RED}✗ setup/setup.sh not found${NC}"
fi

if [ -f "setup/setup-macos.sh" ]; then
    echo -e "${GREEN}✓ setup/setup-macos.sh exists${NC}"
else
    echo -e "${RED}✗ setup/setup-macos.sh not found${NC}"
fi

if [ -f "setup/setup-arch.sh" ]; then
    echo -e "${GREEN}✓ setup/setup-arch.sh exists${NC}"
else
    echo -e "${RED}✗ setup/setup-arch.sh not found${NC}"
fi
echo

# Test Dotfiles Directory Structure
echo -e "${BLUE}Testing Dotfiles Structure...${NC}"
if [ -d "dotfiles" ]; then
    echo -e "${GREEN}✓ dotfiles directory exists${NC}"
    if [ -f "dotfiles/.zshrc" ]; then
        echo -e "${GREEN}✓ dotfiles/.zshrc exists${NC}"
    else
        echo -e "${RED}✗ dotfiles/.zshrc not found${NC}"
    fi
    if [ -f "dotfiles/.Xresources" ]; then
        echo -e "${GREEN}✓ dotfiles/.Xresources exists${NC}"
    else
        echo -e "${RED}✗ dotfiles/.Xresources not found${NC}"
    fi
    if [ -f "dotfiles/.gtkrc-2.0" ]; then
        echo -e "${GREEN}✓ dotfiles/.gtkrc-2.0 exists${NC}"
    else
        echo -e "${RED}✗ dotfiles/.gtkrc-2.0 not found${NC}"
    fi
else
    echo -e "${RED}✗ dotfiles directory not found${NC}"
fi

if [ -d "macos/dotfiles" ]; then
    echo -e "${GREEN}✓ macos/dotfiles directory exists${NC}"
    if [ -f "macos/dotfiles/.zshrc" ]; then
        echo -e "${GREEN}✓ macos/dotfiles/.zshrc exists${NC}"
    else
        echo -e "${RED}✗ macos/dotfiles/.zshrc not found${NC}"
    fi
    if [ -f "macos/dotfiles/.tmux.conf" ]; then
        echo -e "${GREEN}✓ macos/dotfiles/.tmux.conf exists${NC}"
    else
        echo -e "${RED}✗ macos/dotfiles/.tmux.conf not found${NC}"
    fi
    if [ -f "macos/dotfiles/.stowrc" ]; then
        echo -e "${GREEN}✓ macos/dotfiles/.stowrc exists${NC}"
    else
        echo -e "${RED}✗ macos/dotfiles/.stowrc not found${NC}"
    fi
else
    echo -e "${RED}✗ macos/dotfiles directory not found${NC}"
fi
echo

# Test Homebrew Package Lists
echo -e "${BLUE}Testing Homebrew Package Lists...${NC}"
if [ -f "macos/dotfiles/homebrew/formulae.txt" ]; then
    echo -e "${GREEN}✓ formulae.txt exists${NC}"
    echo -e "${YELLOW}  Formulae count: $(wc -l < macos/dotfiles/homebrew/formulae.txt)${NC}"
else
    echo -e "${RED}✗ formulae.txt not found${NC}"
fi

if [ -f "macos/dotfiles/homebrew/casks.txt" ]; then
    echo -e "${GREEN}✓ casks.txt exists${NC}"
    echo -e "${YELLOW}  Casks count: $(wc -l < macos/dotfiles/homebrew/casks.txt)${NC}"
else
    echo -e "${RED}✗ casks.txt not found${NC}"
fi
echo

echo -e "${GREEN}=== Test Complete ===${NC}"
echo
echo -e "${BLUE}To run the setup, execute:${NC}"
echo -e "${YELLOW}  ./setup/setup.sh${NC}"
echo
echo -e "${BLUE}This will automatically detect your OS and run the appropriate setup script.${NC}"
