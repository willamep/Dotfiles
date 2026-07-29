# Hyprland Dotfiles
This is my fork and adaptation of a Hyprland configuration based on [Eli Fouts' dotfiles](https://github.com/elifouts/Dotfiles) and is licensed under GPL-3.0.

## ⚠️ Project Status
**Work in progress.** The configuration is functional but not yet fully customized to my needs. This is a learning project to understand how Hyprland rice configurations work.

## 🛠️ Main Components
This configuration uses the following stack:
- **WM**: Hyprland
- **Bar**: Waybar
- **Launcher**: Wofi
- **Terminal**: Kitty
- **Lock**: Hyprlock
- **Logout**: wlogout
- **Theme**: Pywal (dynamic color schemes)
- **Wallpaper**: swww + wallpaper selector script
- **Editor**: Neovim (with plugins)

## ⌨️ Keyboard layout

Hyprland uses the Macintosh variants of the English and Russian XKB
layouts:

- `Caps Lock` switches between English and Russian.
- `Right Alt` acts as `Option` and provides the additional macOS symbols.
- Punctuation in the Russian layout follows the macOS layout.

The settings are in `.config/hypr/hyprland.conf`:

```ini
kb_layout = us,ru
kb_variant = mac,mac
kb_options = grp:caps_toggle
```

## 📦 Installation
> **Warning**: Back up your current configs before installing!
```bash
# Clone the repository
git clone https://github.com/willamep/your-repo.git ~/Dotfiles

# Install dependencies (Arch Linux)
sudo pacman -S hyprland kitty dunst xdg-desktop-portal-hyprland qt5-wayland qt6-wayland xorg-xwayland pipewire pipewire-pulse wireplumber waybar wofi swww python-pywal grim slurp wl-clipboard

# Create back up your current configs and start script
chmod +x create_symlinks.sh && ./create_symlinks.sh
