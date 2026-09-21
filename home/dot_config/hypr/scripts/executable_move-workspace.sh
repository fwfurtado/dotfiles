#!/usr/bin/env bash
set -euo pipefail

target="${1:-}"

notify() {
  local urgency="$1"
  local title="$2"
  local body="$3"

  command -v notify-send >/dev/null 2>&1 || return 0
  notify-send --urgency="$urgency" "$title" "$body" >/dev/null 2>&1 || true
}

on_error() {
  local status=$?

  notify critical "Erro ao mover workspace" \
    "Não foi possível mover as janelas para o workspace “$target”."
  exit "$status"
}

trap on_error ERR

if [[ -z "$target" ]]; then
  notify critical "Workspace não informado" "Informe o workspace de destino."
  echo "usage: $0 <workspace>" >&2
  exit 1
fi

current="$(hyprctl activeworkspace -j | jq -r '.id')"

clients_json="$(hyprctl clients -j)"
addresses_output="$(
  jq -r --argjson ws "$current" \
    '.[] | select(.workspace.id == $ws) | .address' <<<"$clients_json"
)"

addresses=()
if [[ -n "$addresses_output" ]]; then
  mapfile -t addresses <<<"$addresses_output"
fi

if ((${#addresses[@]} == 0)); then
  notify normal "Nenhuma janela movida" \
    "Não há janelas no workspace atual ($current)."
  exit 0
fi

commands=()

for addr in "${addresses[@]}"; do
  commands+=("dispatch movetoworkspacesilent $target,address:$addr")
done

hyprctl --batch "$(IFS=';'; echo "${commands[*]}")"
notify normal "Workspace alterado" \
  "${#addresses[@]} janela(s) movida(s) para o workspace $target."
