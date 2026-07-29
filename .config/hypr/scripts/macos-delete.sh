#!/usr/bin/env bash

set -euo pipefail

readonly action="${1:?Usage: macos-delete.sh word|line}"

active_window="$(hyprctl activewindow -j)"
app_class="$(jq -r '(.class // .initialClass // "") | ascii_downcase' <<< "$active_window")"

case "$app_class" in
    *kitty*|*alacritty*|*wezterm*|*foot*|*ghostty*)
        is_terminal=true
        ;;
    *)
        is_terminal=false
        ;;
esac

case "$action" in
    word)
        if "$is_terminal"; then
            # Readline/Zsh: delete the previous word.
            hyprctl dispatch sendshortcut "CTRL, W, activewindow" >/dev/null
        else
            # Standard GTK/Qt/browser shortcut: delete the previous word.
            hyprctl dispatch sendshortcut "CTRL, BackSpace, activewindow" >/dev/null
        fi
        ;;
    line)
        if "$is_terminal"; then
            # Readline/Zsh: delete from the cursor to the start of the line.
            hyprctl dispatch sendshortcut "CTRL, U, activewindow" >/dev/null
        else
            # macOS Command+Backspace semantics for regular text fields.
            hyprctl dispatch sendshortcut "SHIFT, Home, activewindow" >/dev/null
            hyprctl dispatch sendshortcut ", BackSpace, activewindow" >/dev/null
        fi
        ;;
    *)
        exit 2
        ;;
esac
