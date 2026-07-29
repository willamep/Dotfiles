#!/usr/bin/env bash

set -euo pipefail

readonly key="${1:?Usage: forward-control.sh KEY}"

active_window="$(hyprctl activewindow -j)"
app_class="$(jq -r '(.class // .initialClass // "") | ascii_downcase' <<< "$active_window")"

# Kitty already translates Super back to terminal Control. Other applications,
# including the embedded PyCharm terminal, expect an actual Control modifier.
if [[ "$app_class" == *kitty* ]]; then
    target_modifier="SUPER"
else
    target_modifier="CTRL"
fi

hyprctl dispatch sendshortcut "${target_modifier}, ${key}, activewindow" >/dev/null
