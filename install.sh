#!/bin/bash

set -e  # Exit on error (but we use || true for optional steps)

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Helpers
step() { echo ""; echo -e "${BLUE}➜${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; exit 1; }

echo ""
read -p "Continue? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    step "Cancelled"
    echo ""
    exit 0
fi

echo ""
sudo -v

# Git

# Shell

# tmux

# Homebrew

# Node

# Composer

# Configs

# Done
echo ""
success "Installation complete!"
echo ""