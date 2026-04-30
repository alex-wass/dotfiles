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
DOTFILES_DIR=""
_DOTFILES_TMPDIR=""
declare -a SELECTED_STEPS=()
ALL_STEPS=(cli touchid ssh git brew shell composer)

usage() {
    cat <<EOF
Usage: $(basename "$0") [--dry-run|-n] [--force|-f] [--steps=cli,git] [step1 step2 ...]

Steps available:
    cli       Install macOS Command Line Tools and accept Xcode license
    touchid   Add Touch ID support for sudo
    ssh       Generate SSH key and print/copy public key
    git       Setup global git configurations
    brew      Install Homebrew and packages
    shell     Copy shell config files
    composer  Install Composer
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

resolve_dotfiles_dir() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)" || true

    if [[ -d "$script_dir/home" ]]; then
        DOTFILES_DIR="$script_dir"
        return
    fi

    step "Downloading dotfiles archive"

    _DOTFILES_TMPDIR=$(mktemp -d)
    trap cleanup_dotfiles EXIT

    run_cmd "curl -fsSL https://github.com/alex-wass/dotfiles/archive/refs/heads/master.zip -o $_DOTFILES_TMPDIR/repo.zip || error 'Failed to download dotfiles'"
    run_cmd "unzip -q $_DOTFILES_TMPDIR/repo.zip -d $_DOTFILES_TMPDIR || error 'Failed to extract dotfiles'"

    DOTFILES_DIR="$_DOTFILES_TMPDIR/dotfiles-master"

    success "Download complete"
}

cleanup_dotfiles() {
    if [[ -n "$_DOTFILES_TMPDIR" && -d "$_DOTFILES_TMPDIR" ]]; then
        rm -rf "$_DOTFILES_TMPDIR"
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

resolve_dotfiles_dir

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

########################################
# Setup a new SSH key
########################################
step_ssh() {
    step "Setting up SSH"

    local key="$HOME/.ssh/id_ed25519"
    local config="$HOME/.ssh/config"
    local comment
    comment="$(printf 'alex+%02d%02d@wass.sh' $(date +%m) $(date +%y))"

    if [[ -f "$key" && $FORCE -eq 0 ]]; then
        success "SSH key already exists; skipping"
    else
        run_cmd "rm -f \"$key\" \"${key}.pub\""
        run_cmd "ssh-keygen -t ed25519 -N \"\" -C \"$comment\" -f \"$key\" >/dev/null 2>&1"

        if [[ -f "${key}.pub" ]]; then
            if command -v pbcopy >/dev/null 2>&1; then
                run_cmd "pbcopy < \"${key}.pub\""
                success "Public key copied to clipboard"
            else
                cat "${key}.pub"
            fi
        fi

        success "SSH key generated"
    fi

    if [[ -f "$config" && $FORCE -eq 0 ]]; then
        success "SSH config already exists; skipping"
    else
        run_cmd "cp \"$DOTFILES_DIR/home/.ssh/config\" \"$config\""
        success "SSH config copied"
    fi
}

########################################
# Git
########################################
step_git() {
    step "Configuring Git"

    local src="$DOTFILES_DIR/home/.gitconfig"
    local dest="$HOME/.gitconfig"

    if [[ -f "$dest" && $FORCE -eq 0 ]]; then
        success "Git already configured; skipping"
        return 0
    fi

    run_cmd "cp \"$src\" \"$dest\""

    success "Git configured"
}

########################################
# Homebrew
########################################
step_brew() {
    step "Installing Homebrew"

    if command -v /opt/homebrew/bin/brew >/dev/null 2>&1; then
        if [[ $FORCE -eq 0 ]]; then
            success "Homebrew already installed; skipping"
            return 0
        fi
    fi

    run_cmd 'NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" >/dev/null 2>&1'

    run_cmd "/opt/homebrew/bin/brew bundle check --file \"$DOTFILES_DIR/Brewfile\" >/dev/null 2>&1 || /opt/homebrew/bin/brew bundle install --file \"$DOTFILES_DIR/Brewfile\" >/dev/null 2>&1"

    success "Homebrew and packages installed"
}

########################################
# Shell
########################################
step_shell() {
    step "Configuring shell"

    # Remove "Last login" message in new terminal windows and new tabs
    touch ~/.hushlogin

    local files=(.zshenv .zshrc .p10k.zsh .tmux.conf)

    for f in "${files[@]}"; do
        if [[ -f "$HOME/$f" && $FORCE -eq 0 ]]; then
            success "$f already exists; skipping"
        else
            run_cmd "cp \"$DOTFILES_DIR/home/$f\" \"$HOME/$f\""
            success "$f copied"
        fi
    done

    while IFS= read -r -d '' f; do
        local rel="${f#$DOTFILES_DIR/home/.config/}"
        local dest="$HOME/.config/$rel"

        if [[ -e "$dest" && $FORCE -eq 0 ]]; then
            success ".config/$rel already exists; skipping"
        else
            run_cmd "mkdir -p \"$(dirname "$dest")\""
            run_cmd "cp -R \"$f\" \"$dest\""
            success ".config/$rel copied"
        fi
    done < <(find "$DOTFILES_DIR/home/.config" -type f -print0)

    run_cmd "/opt/homebrew/bin/tmux source-file \"$HOME/.tmux.conf\" >/dev/null 2>&1 || true"

    success "Shell configured"
    warn "Restart your terminal or run: exec zsh"
}

########################################
# Composer
########################################
step_composer() {
    step "Installing Composer"

    if command -v /usr/local/bin/composer >/dev/null 2>&1; then
        if [[ $FORCE -eq 0 ]]; then
            success "Composer already installed; skipping"
            return 0
        fi
    fi

    local expected_sha
    expected_sha="$(curl -fsSL https://composer.github.io/installer.sig)"
    run_cmd "curl -fsSL https://getcomposer.org/installer -o /tmp/composer-setup.php"
    run_cmd "echo '$expected_sha  /tmp/composer-setup.php' | shasum -a 384 -c - >/dev/null 2>&1"
    run_sudo_cmd "php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer >/dev/null 2>&1"
    run_cmd "rm -f /tmp/composer-setup.php"

    success "Composer installed"
}

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

for s in "${ALL_STEPS[@]}"; do
    run_step_if_selected "$s"
done

echo ""
success "Installation complete!"
echo ""