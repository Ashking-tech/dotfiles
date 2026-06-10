# Ashking's Dotfiles

Personal configuration files for a KDE Plasma 6 + Kitty + Zed + Zen browser setup.

## Quick Start

### Full environment setup (dotfiles + configs)
```bash
curl -fsSL https://raw.githubusercontent.com/Ashking-tech/dotfiles/main/install.sh | bash
```

### Apps installer (standalone)
```bash
curl -fsSL https://raw.githubusercontent.com/Ashking-tech/dotfiles/main/apps.sh | bash
```

Or manually:

```bash
git clone git@github.com:Ashking-tech/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh   # dotfiles + configs
./apps.sh        # applications
```

## What's Included

| Category | Contents |
|----------|----------|
| **Shell** | `.zshrc` (Oh My Zsh + Powerlevel10k), `.bashrc`, `.p10k.zsh`, `.profile` |
| **Git** | `.gitconfig` (user Ashking, email Ashking21@proton.me) |
| **Terminal** | Kitty config with Base2Tone Lavender Dark theme, 80% opacity, blur |
| **Editor** | Zed with Catppuccin Mocha dark theme, Vim mode, 16px font |
| **GTK** | Dark Breeze theme, Colloid-Grey-Dark icons, WhiteSur cursors |
| **KDE** | Krohnkite tiling (HJKL), Layan window decorations, custom shortcuts |
| **Fonts** | JetBrains Mono (32 variants) |
| **Wallpapers** | Collection of dark wallpapers |

## Apps

| App | Installed by |
|-----|-------------|
| **Kitty** | `apps.sh` (system package) |
| **qBittorrent** | `apps.sh` (system package) |
| **mpv** | `apps.sh` (system package) |
| **VS Code** | `apps.sh` (RPM repo) |
| **Zed** | `apps.sh` (official installer) |
| **Zen browser** | `apps.sh` (official installer) |

## Repo Structure

```
dotfiles/
├── install.sh             # Curl-friendly entry point
├── bootstrap.sh           # Full setup script
├── apps.sh                # App installer
├── home/                  # ~/ dotfiles (symlink targets)
├── config/                # ~/.config/ directory mirror
├── kde/                   # KDE Plasma configs
├── aurorae/               # Window decoration themes
├── wallpapers/            # Wallpaper collection
└── fonts/                 # Font files
```

## Manual Steps After Bootstrap

1. Restart your shell or run: `exec zsh`
2. Log out and back in for KDE changes to apply
3. Rebuild KDE panels manually (hardware-specific)
