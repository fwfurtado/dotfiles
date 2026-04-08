# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository purpose

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/). The repo is mid-migration from `dotter` to `chezmoi` (branch `feat/migrate-to-chezmoi`); `.dotter/` is being removed and chezmoi is the new source of truth.

## Common commands

Tasks are defined in `Taskfile.yaml` (run via `task <name>`):

- `task init` — initialize chezmoi on a new machine (`chezmoi init --source=<repo>/home`)
- `task deploy` — apply dotfiles to the current machine (`chezmoi apply`)
- `task diff` — show pending changes (`chezmoi diff`)

When editing files, prefer working directly in the source tree under `home/` and then run `task diff` / `task deploy` to apply. Do not edit the deployed files in `~` directly.

## Architecture

### chezmoi layout

- `.chezmoiroot` points to `home/`, so chezmoi treats `home/` as its source directory. All managed files live there.
- `home/.chezmoi.toml.tmpl` bootstraps per-machine config. It sets a `machineClass` data variable (one of `minipc`, `laptop`, `desktop`, `server`) — auto-detected for the `fw-minipc` host, otherwise prompted once. It also derives `background_opacity` from the class.
- `home/.chezmoiignore` is a template that uses `machineClass` to exclude config trees per machine. Key rules:
  - **minipc**: only git, fish, starship, wallpapers, ssh, scripts — excludes nvim, nushell, tmux, ghostty, oh-my-posh.
  - **server**: minimal set (git, fish, starship, ssh) — additionally excludes wallpapers and `remote-display.sh`.
  - **laptop/desktop**: full set.
  When adding a new tool's config, decide whether minipc/server should also receive it and update `.chezmoiignore` accordingly.
- chezmoi filename prefixes in use: `dot_` (→ `.`), `private_` (chmod 600), `executable_` (chmod +x), `exact_` (directory contents are authoritative — extras get removed). E.g. `home/dot_config/exact_nvim/` → `~/.config/nvim/` with strict contents; `home/private_dot_ssh/` → `~/.ssh/` (mode 600); `home/dot_local/private_bin/executable_remote-display.sh` → `~/.local/bin/remote-display.sh` (executable).

### Managed configs

Under `home/dot_config/`: `fish/` (with `completions/`, `conf.d/`, `config.fish`), `exact_nvim/`, `nushell/`, `tmux/`, `ghostty/`, `oh-my-posh/`, `git/`, `starship.toml`. Wallpapers are under `home/Pictures/wallpapers/{laptop,desktop,...}/`.

Note: `config/fish/conf.d/secrets.fish` is being removed in the migration — secrets should not be committed; source them from outside the repo or via 1Password (see the `aws` wrapper added in recent commits).

### OpenSpec workflow

`openspec/` holds specs and proposed changes managed via the OpenSpec workflow. The repo has skills/commands wired up for multiple AI tools (`.claude/`, `.codex/`, `.cursor/`, `.gemini/`) that all expose the same four operations: **explore**, **propose**, **apply**, **archive**. Use the `opsx:*` skills (or `openspec-*` skills) when the user asks to plan, implement, or archive a change. Specs live in `openspec/specs/`, in-flight proposals in `openspec/changes/`.

## Prerequisites

- [chezmoi](https://www.chezmoi.io/) (replaces dotter)
- [task](https://taskfile.dev/)
- The tools whose configs are managed here (fish, starship, nvim, etc.) for the relevant machine class.
