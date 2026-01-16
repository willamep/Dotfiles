#!/bin/bash
set -euo pipefail  # Exit on errors and undefined variables

# Wallpaper directory
WALLPAPER_DIR="$HOME/Images/wallpapers/walls"

# Error output function
error_exit() {
    echo "Error: $1" >&2
    exit 1
}

# Function to get wallpaper list
menu() {
    [[ ! -d "$WALLPAPER_DIR" ]] && error_exit "Directory $WALLPAPER_DIR does not exist"
    
    find "$WALLPAPER_DIR" -type f \
        \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) \
        -printf "img:%p\n"
}

# Update cava colors based on pywal scheme
update_cava_colors() {
    local cava_config="$HOME/.config/cava/config"
    local colors_sh="$HOME/.cache/wal/colors.sh"
    
    [[ ! -f "$colors_sh" ]] && return 1
    
    local color1 color2
    color1=$(awk 'match($0, /color2='\''(.*)'\''/, a) { print a[1] }' "$colors_sh")
    color2=$(awk 'match($0, /color3='\''(.*)'\''/, a) { print a[1] }' "$colors_sh")
    
    if [[ -f "$cava_config" && -n "$color1" && -n "$color2" ]]; then
        sed -i "s/^gradient_color_1 = .*/gradient_color_1 = '$color1'/" "$cava_config"
        sed -i "s/^gradient_color_2 = .*/gradient_color_2 = '$color2'/" "$cava_config"
        pkill -USR2 cava 2>/dev/null || true
    fi
}

# Main function
main() {
    local choice selected_wallpaper
    
    # Select wallpaper through wofi
    choice=$(menu | wofi \
        -c ~/.config/wofi/wallpaper \
        -s ~/.config/wofi/style-wallpaper.css \
        --show dmenu \
        --prompt "Select Wallpaper:" \
        -n) || exit 0  # Exit if selection cancelled
    
    [[ -z "$choice" ]] && exit 0
    
    # Extract file path
    selected_wallpaper="${choice#img:}"
    
    # Verify file exists and is safe
    [[ ! -f "$selected_wallpaper" ]] && error_exit "File does not exist: $selected_wallpaper"
    [[ ! "$selected_wallpaper" =~ ^$HOME ]] && error_exit "File outside HOME directory"
    
    # Set wallpaper using swww
    swww img "$selected_wallpaper" \
        --transition-type any \
        --transition-fps 60 \
        --transition-duration 0.5 || error_exit "Failed to set wallpaper"
    
    # Generate color scheme with pywal
    wal -i "$selected_wallpaper" -n --cols16 || error_exit "Pywal error"
    
    # Reload swaync
    swaync-client --reload-css 2>/dev/null || true
    
    # Update kitty theme
    if [[ -f "$HOME/.cache/wal/colors-kitty.conf" ]]; then
        cat "$HOME/.cache/wal/colors-kitty.conf" > "$HOME/.config/kitty/current-theme.conf"
    fi
    
    # Update pywalfox
    command -v pywalfox &>/dev/null && pywalfox update 2>/dev/null || true
    
    # Update cava colors
    update_cava_colors
    
    # Copy wallpaper (if wallpaper variable is defined in colors.sh)
    if [[ -f "$HOME/.cache/wal/colors.sh" ]]; then
        # shellcheck disable=SC1091
        source "$HOME/.cache/wal/colors.sh"
        if [[ -n "${wallpaper:-}" && -f "$wallpaper" ]]; then
            cp "$wallpaper" "$HOME/Images/wallpapers/pywallpaper.jpg"
        fi
    fi
}

main
