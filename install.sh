#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/Ashking-tech/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"

cat << 'EOF'
              _     _    _             
    /\       | |   | |  (_)            
   /  \   ___| |__ | | ___ _ __   __ _ 
  / /\ \ / __| '_ \| |/ / | '_ \ / _` |
 / ____ \\__ \ | | |   <| | | | | (_| |
/_/    \_\___/_| |_|_|\_\_|_| |_|\__, |
                                  __/ |
                                 |___/ 

 _      _                     _____      _               
| |    (_)                   / ____|    | |              
| |     _ _ __  _   ___  __ | (___   ___| |_ _   _ _ __  
| |    | | '_ \| | | \ \/ /  \___ \ / _ \ __| | | | '_ \ 
| |____| | | | | |_| |>  <   ____) |  __/ |_| |_| | |_) |
|______|_|_| |_|\__,_/_/\_\ |_____/ \___|\__|\__,_| .__/ 
                                                  | |    
                                                  |_|    
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

echo "==> Installing apps..."
"$DOTFILES_DIR/apps.sh" || echo "WARNING: Some apps failed to install, continuing..."

echo "==> Running bootstrap..."
exec "$DOTFILES_DIR/bootstrap.sh"
