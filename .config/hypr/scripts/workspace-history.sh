#!/usr/bin/env bash

set -euo pipefail

readonly action="${1:?Usage: workspace-history.sh next|prev|reset}"
readonly runtime_root="${XDG_RUNTIME_DIR:-/tmp}"
readonly state_prefix="${runtime_root}/hypr-workspace-history-${HYPRLAND_INSTANCE_SIGNATURE:-default}"
readonly cycle_file="${state_prefix}.cycle.json"
readonly old_history_file="${state_prefix}.json"
readonly lock_file="${state_prefix}.lock"
readonly consecutive_timeout_ms=450

case "$action" in
    next) direction=1 ;;
    prev) direction=-1 ;;
    reset)
        rm -f -- "$cycle_file" "$old_history_file"
        exit 0
        ;;
    *) exit 2 ;;
esac

exec 9>"$lock_file"
flock 9

current_workspace="$(hyprctl activeworkspace -j | jq -r '.id')"
now_ms="$(date +%s%3N)"

# A cycle is valid only for consecutive presses and while its selected
# workspace is still focused. Otherwise this press starts a new cycle.
if [[ -s "$cycle_file" ]]; then
    last_invoked_ms="$(jq -r '.last_invoked_ms // 0' "$cycle_file")"
    selected_workspace="$(jq -r '.workspaces[.index]' "$cycle_file")"

    if (( now_ms - last_invoked_ms > consecutive_timeout_ms )) \
        || [[ "$selected_workspace" != "$current_workspace" ]]; then
        rm -f -- "$cycle_file"
    fi
fi

if [[ ! -s "$cycle_file" ]]; then
    origin_workspace="$current_workspace"

    # The first press always uses Hyprland's own reliable previous-workspace
    # tracking. Custom history is needed only for the second press and later.
    hyprctl dispatch workspace previous >/dev/null
    target_workspace="$(hyprctl activeworkspace -j | jq -r '.id')"

    if [[ "$target_workspace" == "$origin_workspace" ]]; then
        exit 0
    fi

    clients="$(hyprctl clients -j)"
    active_workspaces="$(hyprctl workspaces -j)"

    jq -n \
        --argjson origin "$origin_workspace" \
        --argjson target "$target_workspace" \
        --argjson clients "$clients" \
        --argjson all_workspaces "$active_workspaces" \
        --argjson now "$now_ms" '
        def ordered_unique:
            reduce .[] as $item
                ([];
                 if index($item) == null then . + [$item] else . end);

        (
            $clients
            | map(select(.mapped and .workspace.id > 0))
            | sort_by(.workspace.id)
            | group_by(.workspace.id)
            | map({
                id: .[0].workspace.id,
                rank: (map(.focusHistoryID) | min)
            })
            | sort_by(.rank)
            | map(.id)
        ) as $recent
        | (
            $all_workspaces
            | map(select(.id > 0) | .id)
            | sort
        ) as $all
        | ([$origin, $target] + $recent + $all)
        | ordered_unique
        | {
            workspaces: .,
            index: 1,
            last_invoked_ms: $now
        }
    ' > "$cycle_file"

    exit 0
fi

workspace_count="$(jq '.workspaces | length' "$cycle_file")"
if (( workspace_count < 2 )); then
    exit 0
fi

jq \
    --argjson direction "$direction" \
    --argjson now "$now_ms" '
    (.index + $direction + (.workspaces | length))
        % (.workspaces | length) as $next
    | .index = $next
    | .last_invoked_ms = $now
' "$cycle_file" > "${cycle_file}.new"
mv -- "${cycle_file}.new" "$cycle_file"

target_workspace="$(jq -r '.workspaces[.index]' "$cycle_file")"
hyprctl dispatch workspace "$target_workspace" >/dev/null
