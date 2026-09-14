#!/usr/bin/env bash
set -euo pipefail

target="${1:-}"

if [[ -z "$target" ]]; then
  echo "usage: $0 <workspace>" >&2
  exit 1
fi

current="$(hyprctl activeworkspace -j | jq -r '.id')"

mapfile -t addresses < <(
  hyprctl clients -j |
    jq -r --argjson ws "$current" \
      '.[] | select(.workspace.id == $ws) | .address'
)

((${#addresses[@]})) || exit 0

commands=()

for addr in "${addresses[@]}"; do
  commands+=("dispatch movetoworkspacesilent $target,address:$addr")
done

hyprctl --batch "$(IFS=';'; echo "${commands[*]}")"
