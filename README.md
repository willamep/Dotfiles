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

## 📦 Installation
> **Warning**: Back up your current configs before installing!
```bash
# Clone the repository
git clone https://github.com/willamep/your-repo.git ~/Dotfiles
cd ~/Dotfiles

# Install dependencies (Arch Linux)
sudo pacman -S hyprland kitty dunst xdg-desktop-portal-hyprland qt5-wayland qt6-wayland xorg-xwayland pipewire pipewire-pulse wireplumber waybar wofi swww python-pywal grim slurp wl-clipboard

# Copy configs
cp -r ~/Dotfiles/.config/* ~/.config/
# Or use stow/symlinks
