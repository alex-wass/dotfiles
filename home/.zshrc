# Personal Zsh configuration file. It is strongly recommended to keep all
# shell customization and configuration (including exported environment
# variables such as PATH) in this file or in files sourced from it.
#
# Documentation: https://github.com/romkatv/zsh4humans/blob/v5/README.md.

# Periodic auto-update on Zsh startup: 'ask' or 'no'.
# You can manually run `z4h update` to update everything.
zstyle ':z4h:' auto-update      'no'
# Ask whether to auto-update this often; has no effect if auto-update is 'no'.
zstyle ':z4h:' auto-update-days '28'

# Keyboard type: 'mac' or 'pc'.
zstyle ':z4h:bindkey' keyboard  'mac'

# Start tmux if not already in tmux.
zstyle ':z4h:' start-tmux command tmux -u new -A -D -t z4h

# Fix new tabs/windows in the same directory
zstyle ':z4h:' propagate-cwd yes

# Whether to move prompt to the bottom when zsh starts and on Ctrl+L.
zstyle ':z4h:' prompt-at-bottom 'no'

# Mark up shell's output with semantic information.
zstyle ':z4h:' term-shell-integration 'yes'

# Right-arrow key accepts one character ('partial-accept') from
# command autosuggestions or the whole thing ('accept')?
zstyle ':z4h:autosuggestions' forward-char 'accept'

# Recursively traverse directories when TAB-completing files.
zstyle ':z4h:fzf-complete' recurse-dirs 'no'

# Enable direnv to automatically source .envrc files.
zstyle ':z4h:direnv'         enable 'no'
# Show "loading" and "unloading" notifications from direnv.
zstyle ':z4h:direnv:success' notify 'yes'

# Enable ('yes') or disable ('no') automatic teleportation of z4h over
# SSH when connecting to these hosts.
zstyle ':z4h:ssh:example-hostname1'   enable 'yes'
zstyle ':z4h:ssh:*.example-hostname2' enable 'no'
# The default value if none of the overrides above match the hostname.
zstyle ':z4h:ssh:*'                   enable 'no'

# Send these files over to the remote host when connecting over SSH to the
# enabled hosts.
zstyle ':z4h:ssh:*' send-extra-files '~/.nanorc' '~/.env.zsh'

# Clone additional Git repositories from GitHub.
#
# This doesn't do anything apart from cloning the repository and keeping it
# up-to-date. Cloned files can be used after `z4h init`. This is just an
# example. If you don't plan to use Oh My Zsh, delete this line.
# z4h install ohmyzsh/ohmyzsh || return

# Install or update core components (fzf, zsh-autosuggestions, etc.) and
# initialize Zsh. After this point console I/O is unavailable until Zsh
# is fully initialized. Everything that requires user interaction or can
# perform network I/O must be done above. Everything else is best done below.
z4h init || return

# Extend PATH.
path=(~/bin $path)

# Export environment variables.
export GPG_TTY=$TTY

# Source additional local files if they exist.
z4h source ~/.env.zsh

# Use additional Git repositories pulled in with `z4h install`.
#
# This is just an example that you should delete. It does nothing useful.
#z4h source ohmyzsh/ohmyzsh/lib/diagnostics.zsh  # source an individual file
#z4h load   ohmyzsh/ohmyzsh/plugins/emoji-clock  # load a plugin

# Define key bindings.
z4h bindkey undo Ctrl+/   Shift+Tab  # undo the last command line change
z4h bindkey redo Option+/            # redo the last undone command line change

z4h bindkey z4h-cd-back    Shift+Left   # cd into the previous directory
z4h bindkey z4h-cd-forward Shift+Right  # cd into the next directory
z4h bindkey z4h-cd-up      Shift+Up     # cd into the parent directory
z4h bindkey z4h-cd-down    Shift+Down   # cd into a child directory

# Autoload functions.
autoload -Uz zmv

# Define functions and completions.
function md() { [[ $# == 1 ]] && mkdir -p -- "$1" && cd -- "$1" }
compdef _directories md

# Define named directories: ~w <=> Windows home directory on WSL.
[[ -z $z4h_win_home ]] || hash -d w=$z4h_win_home


# =============================================================================
# Exports
# =============================================================================

# Java
export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home

# Android SDK
export ANDROID_HOME=$HOME/Library/Android/sdk

# Don't clear the screen after quitting a manual page
export MANPAGER="less -X"

# Don't auto-update Homebrew on every command
export HOMEBREW_NO_AUTO_UPDATE=1

# Larger history (32³ entries; default is 500)
export HISTSIZE=32768
export HISTFILESIZE=$HISTSIZE
export HISTCONTROL=ignoredups

# ZSH equivalent of HISTIGNORE
export HISTORY_IGNORE="(ls|cd|cd -|pwd|exit|date|* --help)"


# =============================================================================
# PATH
# =============================================================================

export PATH=$HOME/bin:$PATH

# Composer vendor binaries
export PATH=$HOME/.config/composer/vendor/bin:$PATH

# Homebrew MySQL client
export PATH=/opt/homebrew/opt/mysql-client/bin:$PATH

# Metasploit Framework
export PATH=/opt/metasploit-framework/bin:$PATH
export PATH=/usr/local/bin:$PATH

# Homebrew texinfo
export PATH=/opt/homebrew/opt/texinfo/bin:$PATH

# Homebrew bash
export PATH=/opt/homebrew/Cellar/bash/5.2.15/bin/bash:$PATH

# Rust / Cargo
export PATH=$PATH:$HOME/.cargo/bin

# Custom scripts
export PATH=$PATH:$HOME/.local/scripts

# Android emulator and platform tools
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools

# opencode CLI
export PATH=/Users/alex/.opencode/bin:$PATH


# =============================================================================
# Shell Options
# =============================================================================

# No special treatment for file names with a leading dot
setopt glob_dots

# Require an extra TAB press to open the completion menu
setopt no_auto_menu

# Share history between terminal sessions
setopt share_history


# =============================================================================
# Aliases
# =============================================================================

# Show hidden files in directory listings
alias ls="${aliases[ls]:-ls} -A"

# List all files colorized in long format
alias ll="ls -laF"

# Show hidden files but skip .git directories
alias tree='tree -a -I .git'

# Replace cat with bat if available
if command -v bat &> /dev/null; then
    alias cat="bat --style=plain"
fi

# Replace grep with ripgrep if available
if command -v rg &> /dev/null; then
    alias grep="rg"
fi

# Nuke all uncommitted changes
alias nah='git reset --hard;git clean -df'

# Laravel
alias sail='bash vendor/bin/sail'
alias pint='php vendor/bin/pint'
alias stan='php ./vendor/bin/phpstan analyse --memory-limit=2G'
alias sa='sail artisan'
alias mfs='sail artisan migrate:fresh --seed'

# Show/hide hidden files in Finder
alias show="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"

# Get public IP
alias ip="curl ifconfig.me/ip ; echo"

# Flush DNS cache
alias flushdns="sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"

# Launch a debug Chrome for agents
alias chrome-dev="/Applications/Google\\ Chrome.app/Contents/MacOS/Google\\ Chrome --remote-debugging-port=9222 --user-data-dir=/tmp/chrome-profile-stable"

# Open current directory in VS Code
alias vs='code "`pwd`"'

# Copy SSH public key to clipboard
alias copykey='command cat ~/.ssh/id_ed25519.pub 2>/dev/null || command cat ~/.ssh/id_rsa.pub 2>/dev/null | pbcopy'


# =============================================================================
# Tool Setup
# =============================================================================

# fnm — Node.js version manager
if command -v fnm &> /dev/null; then
    eval "$(fnm env --use-on-cd --shell zsh)"
    alias nvm='fnm'
fi


# =============================================================================
# Functions
# =============================================================================

# Show latest available version for a Composer package
csl() { composer2 show -l "$1" }

# Switch between Homebrew PHP versions (e.g. switch-php 8.2)
switch-php() { brew unlink php && brew link php@"$1" }


# =============================================================================
# Startup
# =============================================================================

neofetch
