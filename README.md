# .dotfiles

## Install

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/alex-wass/dotfiles/HEAD/install.sh)
```

### Steps

| Step      | Description                                                  |
| --------- | ------------------------------------------------------------ |
| `cli`     | Install macOS Command Line Tools and accept Xcode license    |
| `touchid` | Add Touch ID support for sudo                                |
| `ssh`     | Generate SSH key and print/copy public key                   |
| `git`     | Setup global git configurations                              |
| `brew`    | Install Homebrew and packages                                |
| `shell`   | Copy shell config files                                      |
| `composer`| Install global composer packages                             |

### Flags

| Flag             | Description                           |
| ---------------- | ------------------------------------- |
| `--dry-run`, `-n`| Print actions without executing them  |
| `--force`, `-f`  | Run steps even if already configured  |

### Examples

```bash
# Dry run to preview changes
bash <(curl -fsSL ...) --dry-run

# Only configure git and touchid
bash <(curl -fsSL ...) git touchid

# Re-run a step even if already configured
bash <(curl -fsSL ...) --force git
```

### Clone instead

```bash
git clone git@github.com:alex-wass/dotfiles.git ~/.dotfiles
~/.dotfiles/install.sh
```

## Applications
- [ ] [1Password](https://1password.com/downloads/mac)
- [ ] [1Password for Safari](https://apps.apple.com/us/app/1password-for-safari/id1569813296)
- [ ] [Amphetamine](https://apps.apple.com/gb/app/amphetamine/id937984704)
- [ ] [Bear](https://apps.apple.com/gb/app/bear-markdown-notes/id1091189122)
- [ ] [Blackmagic Disk Speed Test](https://apps.apple.com/gb/app/blackmagic-disk-speed-test/id425264550)
- [ ] [Bruno](https://www.usebruno.com/downloads)
- [ ] [Burp Suite](https://portswigger.net/burp/releases/professional-community-2026-3-3?requestededition=community)
- [ ] [CopyClip](https://apps.apple.com/gb/app/copyclip-clipboard-history/id595191960)
- [ ] [Discord](https://discord.com/download)
- [ ] [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [ ] [Ghostty](https://ghostty.org/download)
- [ ] [Google Chrome](https://www.google.com/intl/en_uk/chrome/)
- [ ] [GPG Keychain](https://gpgtools.org/)
- [ ] [Handbrake](https://handbrake.fr/downloads.php)
- [ ] [HelpWire](https://www.helpwire.app/)
- [ ] [HTTP Toolkit](https://httptoolkit.com/http-toolkit-for-mac/)
- [ ] [Ice Menu Bar](https://github.com/jordanbaird/Ice)
- [ ] [Logi Options+](https://www.logitech.com/en-gb/software/logi-options-plus)
- [ ] [Local](https://localwp.com/)
- [ ] [Lunar](https://lunar.fyi/)
- [ ] [OpenCode Desktop](https://opencode.ai/download)
- [ ] [Paper](https://paper.design/)
- [ ] [ProtonVPN](https://protonvpn.com/download)
- [ ] [Raycast](https://www.raycast.com/)
- [ ] [Solo](https://soloterm.com/)
- [ ] [Spotify](https://www.spotify.com/uk/download/mac/)
- [ ] [Steam](https://store.steampowered.com/about/)
- [ ] [TablePlus](https://tableplus.com/download/)
- [ ] [Tailscale](https://tailscale.com/download)
- [ ] [Tunnelblick](https://tunnelblick.net/downloads.html)
- [ ] [uBlock Origin Lite](https://apps.apple.com/gb/app/ublock-origin-lite/id6745342698)
- [ ] [VS Code](https://code.visualstudio.com/download)
- [ ] [VLC](https://images.videolan.org/vlc/)
- [ ] [Xcode](https://apps.apple.com/gb/app/xcode/id497799835)
