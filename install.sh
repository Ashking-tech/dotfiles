#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/Ashking-tech/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"

cat << 'EOF'
   ┌─────────────────────────────────────────────┐
   │                    █████                     │
   │                   ██   ██                    │
   │                   ███████                    │
   │                   ██   ██                    │
   │                   ██   ██                    │
   │                                             │
   │    ██████  ███████  ████████ ███████         │
   │    ██   ██ ██          ██    ██              │
   │    ██   ██ █████       ██    █████           │
   │    ██   ██ ██          ██    ██              │
   │    ██████  ██          ██    ███████         │
   │                                             │
   │        Automated Environment Setup           │
   └─────────────────────────────────────────────┘
EOF

if ! command -v git &>/dev/null; then
    echo "ERROR: git is required. Please install it first."
    echo "  Fedora: sudo dnf install -y git"
    echo "  Debian: sudo apt install -y git"
    echo "  Arch:   sudo pacman -S git"
    exit 1
fi

if [ -d "$DOTFILES_DIR" ]; then
    echo "==> $DOTFILES_DIR already exists. Updating..."
    git -C "$DOTFILES_DIR" pull --ff-only
else
    echo "==> Cloning dotfiles repo..."
    git clone --depth=1 "$REPO_URL" "$DOTFILES_DIR"
fi

echo "==> Running bootstrap..."
exec "$DOTFILES_DIR/bootstrap.sh"
