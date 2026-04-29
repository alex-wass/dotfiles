# .dotfiles

## Install

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/alex-wass/dotfiles/main/install.sh)
```

### Steps

| Step     | Description                                                  |
| -------- | ------------------------------------------------------------ |
| `cli`    | Install macOS Command Line Tools and accept Xcode license    |
| `git`    | Setup global git configurations.                             |
| `touchid`| Enable Touch ID for sudo                                     |

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
