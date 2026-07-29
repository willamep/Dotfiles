#!/usr/bin/env bash

set -euo pipefail

readonly action="${1:-}"
readonly config_root="${XDG_CONFIG_HOME:-${HOME}/.config}"
readonly rules_file="${config_root}/hypr/app-opacity.conf"
readonly default_opacity="0.78"
readonly step="0.05"
readonly min_opacity="0.20"
readonly max_opacity="1.00"

notify() {
    notify-send -a Hyprland -t 1500 "Прозрачность окна" "$1"
}

case "$action" in
    increase|decrease|reset) ;;
    *)
        notify "Неизвестное действие: ${action:-пусто}"
        exit 2
        ;;
esac

active_window="$(hyprctl activewindow -j)"
app_class="$(jq -r '.initialClass // .class // empty' <<< "$active_window")"

if [[ -z "$app_class" || "$app_class" == "null" ]]; then
    notify "Нет активного окна"
    exit 1
fi

mkdir -p "$(dirname "$rules_file")"
touch "$rules_file"

rule_id="$(printf '%s' "$app_class" | sha256sum | cut -d ' ' -f 1)"
marker="app-opacity:${rule_id}"
current="$(awk -v marker="$marker" '$2 == marker { print $3; exit }' "$rules_file")"
current="${current:-$default_opacity}"

temp_file="$(mktemp "${rules_file}.XXXXXX")"
trap 'rm -f "$temp_file"' EXIT

# Remove the previous marker and its rule. They are always stored as a pair.
awk -v marker="$marker" '
    skip { skip = 0; next }
    $2 == marker { skip = 1; next }
    { print }
' "$rules_file" > "$temp_file"

if [[ "$action" == "reset" ]]; then
    mv "$temp_file" "$rules_file"
    trap - EXIT
    hyprctl reload >/dev/null
    notify "${app_class}: по умолчанию"
    exit 0
fi

new_opacity="$(awk \
    -v current="$current" \
    -v step="$step" \
    -v min="$min_opacity" \
    -v max="$max_opacity" \
    -v action="$action" \
    'BEGIN {
        value = action == "increase" ? current + step : current - step
        if (value < min) value = min
        if (value > max) value = max
        printf "%.2f", value
    }')"

# Escape RE2 metacharacters and the comma used as Hyprland's rule separator.
escaped_class="$(printf '%s' "$app_class" \
    | sed -e 's/[][\\.^$*+?(){}|]/\\&/g' -e 's/,/\\x2C/g')"

printf '# %s %s\n' "$marker" "$new_opacity" >> "$temp_file"
printf 'windowrule = match:initial_class ^%s$, opacity %s override %s override 1.00 override\n' \
    "$escaped_class" "$new_opacity" "$new_opacity" >> "$temp_file"

mv "$temp_file" "$rules_file"
trap - EXIT
hyprctl reload >/dev/null
notify "${app_class}: ${new_opacity}"
