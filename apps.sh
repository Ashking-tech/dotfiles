#!/usr/bin/env bash
set -euo pipefail

shopt -s nullglob

LOG_FILE="$HOME/apps-install.log"

log() { echo "[$(date '+%H:%M:%S')] $*" | tee -a "$LOG_FILE"; }
warn() { log "WARNING: $*"; }

install_system_packages() {
    log "--- Installing system packages ---"
    local pkgs="kitty qbittorrent mpv"
    if command -v dnf &>/dev/null; then
        sudo dnf install -y $pkgs || warn "Some packages failed (may need sudo password)"
    elif command -v apt &>/dev/null; then
        sudo apt update && sudo apt install -y $pkgs || warn "Some packages failed (may need sudo password)"
    elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm $pkgs || warn "Some packages failed (may need sudo password)"
    else
        warn "Unknown package manager. Install manually: $pkgs"
    fi
}

install_vscode() {
    log "--- Installing VS Code ---"
    if command -v code &>/dev/null; then
        log "VS Code already installed"
        return
    fi
    if ! command -v rpm &>/dev/null; then
        warn "RPM not available. VS Code requires a Fedora/RHEL-based system."
        return
    fi
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc 2>/dev/null || true
    cat << 'EOF' | sudo tee /etc/yum.repos.d/vscode.repo >/dev/null
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
    if command -v dnf &>/dev/null; then
        sudo dnf install -y code || warn "VS Code install failed"
    elif command -v yum &>/dev/null; then
        sudo yum install -y code || warn "VS Code install failed"
    fi
    log "VS Code installed"
}

install_zed() {
    log "--- Installing Zed ---"
    if [ -f "$HOME/.local/bin/zed" ] || command -v zed &>/dev/null; then
        log "Zed already installed"
        return
    fi
    mkdir -p "$HOME/.local"
    curl -f https://zed.dev/install.sh 2>/dev/null | sh || warn "Zed install failed"
    log "Zed installed"
}

install_zen() {
    log "--- Installing Zen browser ---"
    if [ -f "$HOME/.local/bin/zen" ] || [ -d "$HOME/.tarball-installations/zen" ]; then
        log "Zen browser already installed"
        return
    fi
    mkdir -p "$HOME/.tarball-installations"
    curl -fsSL https://github.com/zen-browser/updates-server/raw/refs/heads/main/install.sh 2>/dev/null | sh || warn "Zen install failed"
    log "Zen browser installed"
}

main() {
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
    echo ""
    echo "  Log: $LOG_FILE"
    echo ""

    SECONDS=0

    install_system_packages
    install_vscode
    install_zed
    install_zen

    echo ""
    echo "  All apps installed in ${SECONDS}s"
    echo "  Log: $LOG_FILE"
    echo ""
    echo "Next steps:"
    echo "  - Log out and back in for app entries to appear"
    echo "  - Launch apps from your app launcher or terminal"
}

main
