#!/usr/bin/env bash

set -euo pipefail

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

DRY_RUN=0
FORCE=0
declare -a SELECTED_STEPS=()
ALL_STEPS=(cli touchid)

usage() {
    cat <<EOF
Usage: $(basename "$0") [--dry-run|-n] [--force|-f] [--steps=cli,touchid] [step1 step2 ...]

Steps available:
    cli       Install macOS Command Line Tools and accept Xcode license
    touchid   Add Touch ID (fingerprint) support to sudo (/etc/pam.d/sudo)
    all       Run all steps (default)

Flags:
    --dry-run, -n   Print actions but do not perform them
    --force, -f     Force actions even if already configured
EOF
}

run_cmd() {
    if [[ $DRY_RUN -eq 0 ]]; then
        eval "$@"
    else
        echo "$ $*"
    fi
}

run_sudo_cmd() {
    if [[ $DRY_RUN -eq 0 ]]; then
        sudo bash -c "$*"
    else
        echo "$ sudo $*"
    fi
}

has_selected() {
    local name=$1
    if [[ ${#SELECTED_STEPS[@]} -eq 0 ]]; then
        return 0
    fi
    for s in "${SELECTED_STEPS[@]}"; do
        if [[ "$s" == "all" || "$s" == "$name" ]]; then
            return 0
        fi
    done
    return 1
}

# Parse args
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run|-n)
            DRY_RUN=1; shift;;
        --force|-f)
            FORCE=1; shift;;
        --steps=*)
            IFS=',' read -r -a SELECTED_STEPS <<< "${1#*=}"; shift;;
        --help|-h)
            usage; exit 0;;
        --)
            shift; break;;
        -* )
            echo "Unknown option: $1"; usage; exit 1;;
        * )
            SELECTED_STEPS+=("$1"); shift;;
    esac
done

if [[ $DRY_RUN -eq 1 ]]; then
    echo ""
    warn "Running in dry-run mode, no changes will be made"
fi

echo ""
read -p "Continue? (y/n) " -n 1 -r

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo ""
    error "Cancelled"
fi

echo ""
sudo -v

########################################
# CLI tools
########################################
step_cli() {
    step "Install macOS Command Line Tools"
    if command -v xcode-select >/dev/null 2>&1 && xcode-select -p >/dev/null 2>&1; then
        if [[ $FORCE -eq 0 ]]; then
            success "Command Line Tools already installed; skipping"
            return 0
        fi
    fi

    run_cmd "xcode-select --install || true"

    if [[ $DRY_RUN -eq 0 ]]; then
        # Wait for install to complete
        echo "Waiting for Command Line Tools to install..."
        local max_wait=600
        local waited=0
        while [[ $waited -lt $max_wait ]]; do
            if xcode-select -p >/dev/null 2>&1; then
                success "Command Line Tools are installed"
                break
            fi
            sleep 2
            waited=$((waited+2))
        done
        if [[ $waited -ge $max_wait ]]; then
            warn "Timed out waiting for Command Line Tools; continue manually if required"
        fi
    fi

    # Accept license if necessary
    run_sudo_cmd "xcodebuild -license accept || true"

    success "macOS Command Line Tools installed"
}

########################################
# Enable Touch ID for sudo
########################################
step_touchid() {
    step "Enable Touch ID for sudo"
    local pamfile=/etc/pam.d/sudo
    if grep -q pam_tid.so "$pamfile" 2>/dev/null; then
        if [[ $FORCE -eq 0 ]]; then
            success "Touch ID already enabled for sudo; skipping"
            return 0
        fi
    fi

    run_sudo_cmd "cp -a $pamfile ${pamfile}.bak.$(date +%s)"
    run_cmd "echo 'auth       sufficient     pam_tid.so' > /tmp/sudo.tmp"
    run_cmd "sed -e '/pam_tid.so/d' $pamfile >> /tmp/sudo.tmp"
    run_sudo_cmd "mv /tmp/sudo.tmp $pamfile"
    success "Touch ID configured"
}

# Git

# Shell

# tmux

# Homebrew

# Node

# Composer
## Laravel Installer
## Github key

# Configs

# Cloudflared

########################################
# Plan and run selected steps
########################################

run_step_if_selected() {
    local name=$1; shift
    if has_selected "$name"; then
        "step_${name}" "$@"
    else
        step "Skipped: $name"
    fi
}

# If nothing selected, default to all
if [[ ${#SELECTED_STEPS[@]} -eq 0 ]]; then
    SELECTED_STEPS=(all)
fi

# Remove "Last login" message in new terminal windows and new tabs
touch ~/.hushlogin

for s in "${ALL_STEPS[@]}"; do
    run_step_if_selected "$s"
done

echo ""
success "Installation complete!"
echo ""