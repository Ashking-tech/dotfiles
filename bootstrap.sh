#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
LOG_FILE="$DOTFILES_DIR/bootstrap.log"

log() { echo "[$(date '+%H:%M:%S')] $*" | tee -a "$LOG_FILE"; }
warn() { log "WARNING: $*"; }
err()  { log "ERROR: $*"; exit 1; }

link_file() {
    local src="$1" dst="$2"
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        if [ "$(readlink -f "$dst")" = "$src" ]; then
            log "SKIP: $dst already linked to repo"
            return
        fi
        mkdir -p "$BACKUP_DIR"
        mv "$dst" "$BACKUP_DIR/"
        log "BACKED UP: $dst -> $BACKUP_DIR/"
    fi
    mkdir -p "$(dirname "$dst")"
    ln -sf "$src" "$dst"
    log "LINKED: $src -> $dst"
}

copy_file() {
    local src="$1" dst="$2"
    if [ -f "$dst" ] || [ -L "$dst" ]; then
        if diff -q "$src" "$dst" &>/dev/null; then
            log "SKIP: $dst already matches repo"
            return
        fi
        mkdir -p "$BACKUP_DIR"
        cp "$dst" "$BACKUP_DIR/"
        log "BACKED UP: $dst -> $BACKUP_DIR/"
    fi
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    log "COPIED: $src -> $dst"
}

install_shell_configs() {
    log "--- Setting up shell configs ---"
    for f in .zshrc .bashrc .bash_profile .profile .gitconfig .gtkrc-2.0 .npmrc .p10k.zsh; do
        if [ -f "$DOTFILES_DIR/home/$f" ]; then
            link_file "$DOTFILES_DIR/home/$f" "$HOME/$f"
        fi
    done
    if [ -f "$DOTFILES_DIR/home/cargo_env" ]; then
        link_file "$DOTFILES_DIR/home/cargo_env" "$HOME/.cargo/env"
    fi
}

install_omz() {
    log "--- Installing Oh My Zsh ---"
    if [ -d "$HOME/.oh-my-zsh" ]; then
        log "Oh My Zsh already installed"
    else
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || true
    fi
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
        log "Installed Powerlevel10k"
    fi
    for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
        if [ ! -d "$ZSH_CUSTOM/plugins/$plugin" ]; then
            git clone --depth=1 "https://github.com/zsh-users/$plugin.git" "$ZSH_CUSTOM/plugins/$plugin"
            log "Installed $plugin"
        fi
    done
}

install_kitty() {
    log "--- Setting up Kitty ---"
    if [ -d "$DOTFILES_DIR/config/kitty" ]; then
        for f in kitty.conf current-theme.conf; do
            [ -f "$DOTFILES_DIR/config/kitty/$f" ] && link_file "$DOTFILES_DIR/config/kitty/$f" "$HOME/.config/kitty/$f"
        done
    fi
}

install_zed() {
    log "--- Setting up Zed ---"
    if [ -f "$DOTFILES_DIR/config/zed/settings.json" ] && command -v zed &>/dev/null; then
        link_file "$DOTFILES_DIR/config/zed/settings.json" "$HOME/.config/zed/settings.json"
    fi
}

install_gtk() {
    log "--- Setting up GTK ---"
    for ver in gtk-3.0 gtk-4.0; do
        if [ -d "$DOTFILES_DIR/config/$ver" ]; then
            for f in settings.ini gtk.css colors.css window_decorations.css; do
                [ -f "$DOTFILES_DIR/config/$ver/$f" ] && copy_file "$DOTFILES_DIR/config/$ver/$f" "$HOME/.config/$ver/$f"
            done
            if [ -d "$DOTFILES_DIR/config/$ver/assets" ]; then
                mkdir -p "$HOME/.config/$ver/assets"
                cp -rn "$DOTFILES_DIR/config/$ver/assets/"* "$HOME/.config/$ver/assets/" 2>/dev/null || true
            fi
        fi
    done
}

install_kde() {
    log "--- Setting up KDE configs ---"
    if [ -d "$DOTFILES_DIR/kde" ]; then
        for f in kdeglobals kwinrc kglobalshortcutsrc dolphinrc konsolerc baloofilerc kcminputrc systemsettingsrc; do
            [ -f "$DOTFILES_DIR/kde/$f" ] && copy_file "$DOTFILES_DIR/kde/$f" "$HOME/.config/$f"
        done
    fi
    if [ -f "$DOTFILES_DIR/kde/plasma-localerc" ]; then
        copy_file "$DOTFILES_DIR/kde/plasma-localerc" "$HOME/.config/plasma-localerc"
    fi
}

install_aurorae() {
    log "--- Installing Layan window decoration ---"
    if [ -d "$DOTFILES_DIR/aurorae" ]; then
        for theme_dir in "$DOTFILES_DIR/aurorae/"*/; do
            theme_name="$(basename "$theme_dir")"
            target="$HOME/.local/share/aurorae/themes/$theme_name"
            if [ -d "$target" ]; then
                log "SKIP: Aurorae theme $theme_name already installed"
            else
                mkdir -p "$target"
                cp -r "$theme_dir"* "$target/"
                log "Installed aurorae theme: $theme_name"
            fi
        done
    fi
}

install_krohnkite() {
    log "--- Installing Krohnkite KWin script ---"
    local kwin_scripts="$HOME/.local/share/kwin/scripts"
    if [ -d "$kwin_scripts/krohnkite" ]; then
        log "Krohnkite already installed"
    else
        mkdir -p "$kwin_scripts"
        git clone --depth=1 https://github.com/esjeon/krohnkite.git "$kwin_scripts/krohnkite" 2>/dev/null || \
            warn "Could not clone Krohnkite. Install manually from https://github.com/esjeon/krohnkite"
        log "Installed Krohnkite"
    fi
}

install_fonts() {
    log "--- Installing fonts ---"
    if [ -d "$DOTFILES_DIR/fonts" ]; then
        local font_dir="$HOME/.local/share/fonts"
        mkdir -p "$font_dir"
        local count=0
        for f in "$DOTFILES_DIR/fonts/"*.ttf; do
            if [ -f "$f" ]; then
                base="$(basename "$f")"
                if [ ! -f "$font_dir/$base" ]; then
                    cp "$f" "$font_dir/"
                    count=$((count + 1))
                fi
            fi
        done
        if [ "$count" -gt 0 ]; then
            fc-cache -f "$font_dir" 2>/dev/null || true
            log "Installed $count font files"
        else
            log "All fonts already installed"
        fi
    fi
}

install_wallpaper() {
    log "--- Setting up wallpapers ---"
    if [ -d "$DOTFILES_DIR/wallpapers" ]; then
        local wp_dir="$HOME/Pictures/Wallpapers"
        mkdir -p "$wp_dir"
        for f in "$DOTFILES_DIR/wallpapers/"*; do
            if [ -f "$f" ]; then
                base="$(basename "$f")"
                [ ! -f "$wp_dir/$base" ] && cp "$f" "$wp_dir/"
            fi
        done
        local first_wp
        first_wp="$(ls "$DOTFILES_DIR/wallpapers/"* | head -1)"
        if [ -n "$first_wp" ] && command -v plasma-apply-wallpaperimage &>/dev/null; then
            plasma-apply-wallpaperimage "$first_wp" 2>/dev/null && log "Applied wallpaper" || warn "Could not set wallpaper"
        fi
    fi
}

install_fontconfig() {
    log "--- Setting up fontconfig ---"
    if [ -f "$DOTFILES_DIR/config/fontconfig/fonts.conf" ]; then
        copy_file "$DOTFILES_DIR/config/fontconfig/fonts.conf" "$HOME/.config/fontconfig/fonts.conf"
    fi
}

install_bottom() {
    log "--- Setting up bottom ---"
    if [ -f "$DOTFILES_DIR/config/bottom/bottom.toml" ]; then
        link_file "$DOTFILES_DIR/config/bottom/bottom.toml" "$HOME/.config/bottom/bottom.toml"
    fi
}

install_qbittorrent() {
    log "--- Setting up qBittorrent ---"
    if [ -f "$DOTFILES_DIR/config/qBittorrent/qBittorrent.conf" ]; then
        copy_file "$DOTFILES_DIR/config/qBittorrent/qBittorrent.conf" "$HOME/.config/qBittorrent/qBittorrent.conf"
    fi
}

install_chrome() {
    log "--- Setting up Firefox chrome ---"
    if [ -d "$DOTFILES_DIR/chrome" ]; then
        local chrome_dir="$HOME/.mozilla/firefox"
        if ls "$chrome_dir/"*.default-release*/chrome/ 1>/dev/null 2>&1; then
            for profile in "$chrome_dir/"*.default*; do
                if [ -d "$profile" ]; then
                    target="$profile/chrome"
                    if [ -L "$target" ] && [ "$(readlink -f "$target")" = "$(readlink -f "$DOTFILES_DIR/chrome")" ]; then
                        log "SKIP: chrome already linked for $(basename "$profile")"
                    else
                        if [ -d "$target" ]; then
                            mkdir -p "$BACKUP_DIR"
                            mv "$target" "$BACKUP_DIR/chrome-$(basename "$profile")"
                        fi
                        ln -sf "$DOTFILES_DIR/chrome" "$target"
                        log "LINKED chrome for $(basename "$profile")"
                    fi
                fi
            done
        else
            warn "No Firefox profile found. Skipping chrome theme."
        fi
    fi
}

install_packages() {
    log "--- Installing system packages ---"
    if command -v dnf &>/dev/null; then
        sudo dnf install -y zsh git curl kitty 2>/dev/null || warn "Some packages failed to install"
    elif command -v apt &>/dev/null; then
        sudo apt update && sudo apt install -y zsh git curl kitty 2>/dev/null || warn "Some packages failed to install"
    elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm zsh git curl kitty 2>/dev/null || warn "Some packages failed to install"
    else
        warn "Unknown package manager. Install zsh, git, curl, kitty manually."
    fi
}

main() {
    echo "======================================"
    echo "  Ashking's Dotfiles Bootstrap"
    echo "======================================"
    echo "Repo: $DOTFILES_DIR"
    echo "Log:  $LOG_FILE"
    echo ""

    SECONDS=0

    install_packages
    install_omz
    install_shell_configs
    install_kitty
    install_zed
    install_gtk
    install_kde
    install_aurorae
    install_krohnkite
    install_fonts
    install_wallpaper
    install_fontconfig
    install_bottom
    install_qbittorrent
    install_chrome

    echo ""
    echo "======================================"
    echo "  Bootstrap complete in ${SECONDS}s"
    echo "======================================"
    echo ""
    echo "Next steps:"
    echo "  1. Restart your shell or run: exec zsh"
    echo "  2. Log out and back in for KDE changes"
    echo "  3. Rebuild KDE panels manually (hardware-specific)"
    echo "  4. Backups saved to: $BACKUP_DIR"
}

main
