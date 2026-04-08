## Context

The dotfiles repo currently uses dotter to manage symlinks across machines. Dotter uses `global.toml` to define packages (nvim, fish, starship, etc.) with file mappings, and `local.toml` to select which packages are active on a given machine. Templates are limited to `{{variable}}` and `{{command_output "..."}}` syntax, used primarily for secrets via 1Password CLI.

The repo manages configs for: fish shell (with numbered loaders, aliases, completions), neovim, nushell, tmux, ghostty, starship, git, ssh, oh-my-posh, wallpapers, and utility scripts. 1Password is used for SSH signing, secret environment variables, atuin credentials, and AWS credential wrapping.

## Goals / Non-Goals

**Goals:**
- Replace dotter with chezmoi while preserving all current dotfile functionality
- Enable per-machine conditional configuration using chezmoi's template system (hostname, OS, distro)
- Integrate 1Password secrets via chezmoi's native `onepasswordRead` function
- Maintain a clear, discoverable source directory structure
- Support easy onboarding of new machines with `chezmoi init`

**Non-Goals:**
- Changing the actual content/behavior of managed configs (fish aliases, nvim plugins, etc.)
- Adding new dotfiles not currently managed
- Supporting non-Linux operating systems (macOS/Windows) unless trivially achievable
- Encrypting files with chezmoi's age/gpg — 1Password remains the sole secret backend

## Decisions

### 1. Source directory structure: flat `home/` layout

Use chezmoi's standard source directory at the repo root. Files map directly using chezmoi naming conventions:

```
home/                              # chezmoi source dir (set via .chezmoiroot)
├── .chezmoi.toml.tmpl             # machine config template
├── .chezmoiignore                 # template-based ignore
├── dot_config/
│   ├── fish/
│   │   └── conf.d/
│   │       ├── secrets.fish.tmpl  # 1Password template
│   │       └── ...
│   ├── exact_nvim/
│   ├── git/
│   ├── starship.toml
│   └── ...
├── private_dot_ssh/
│   └── config
└── dot_local/
    └── private_bin/
        └── remote-display.sh
```

**Rationale**: Using `.chezmoiroot` pointing to `home/` keeps the repo root clean for project files (Taskfile, openspec, README) while the chezmoi source lives in a subdirectory. This avoids cluttering the repo root with `dot_config/` prefixed directories.

**Alternative considered**: Repo root as chezmoi source — rejected because it mixes project meta-files with dotfile sources and makes the repo harder to navigate.

### 2. Machine profiles via `.chezmoidata.yaml` + template conditionals

Replace dotter's `local.toml` package selection with:
- A `.chezmoi.toml.tmpl` that prompts for or detects machine class (e.g., `laptop`, `desktop`, `server`)
- `.chezmoiignore` with template conditionals to exclude packages per machine

```
# .chezmoiignore example
{{ if ne .machineClass "desktop" }}
dot_config/nvim
{{ end }}
```

**Rationale**: This is chezmoi's idiomatic approach and supports both automatic detection (hostname) and manual override. It replaces dotter's explicit package lists with declarative ignore rules.

**Alternative considered**: Separate chezmoi data files per machine with `chezmoi init --data` — rejected as it requires maintaining separate data files outside the repo.

### 3. Secrets via `onepasswordRead` template function

Replace dotter's `{{command_output "op read '...'"}}` with chezmoi's native `{{ onepasswordRead "op://..." }}` in `.tmpl` files.

**Rationale**: `onepasswordRead` is chezmoi's built-in 1Password integration — it's more reliable, handles caching, and doesn't shell out for each secret. The vault reference paths (`op://development/...`) remain identical.

**Alternative considered**: Using chezmoi's generic `output` function to call `op read` — rejected because `onepasswordRead` is purpose-built and avoids shell escaping issues.

### 4. Template migration strategy

- Files with dotter `{{variable}}` syntax → chezmoi `.tmpl` files with `{{ .variable }}`
- Files with `{{command_output "..."}}` → chezmoi `.tmpl` files with appropriate template functions
- Currently only `secrets.fish` and `ghostty/config` use templates

**Rationale**: Minimal template surface area makes this low-risk. Only 2 files need template conversion.

### 5. Taskfile update

Replace dotter deploy/undeploy tasks:
- `task deploy` → `chezmoi apply`
- `task undeploy` → removed (chezmoi doesn't have an undeploy concept; use `chezmoi purge` if needed)
- Add `task diff` → `chezmoi diff`
- Add `task init` → `chezmoi init` for new machine setup

**Rationale**: Keeps the existing task-based workflow familiar while adapting to chezmoi's command model.

## Risks / Trade-offs

- **[Risk] Dotter cache/symlinks left behind** → Run `dotter undeploy` before first `chezmoi apply` to cleanly remove existing symlinks. Document this in migration steps.
- **[Risk] 1Password session timeout during apply** → `onepasswordRead` handles session management better than raw `op read`, but long applies with many secrets may still timeout. Mitigation: chezmoi caches template output, so secrets are only fetched on change.
- **[Risk] Large git diff from file renames** → The structural reorganization will produce a noisy diff. Mitigation: Do the migration in a single commit with clear commit message; use `git diff --stat` to verify completeness.
- **[Trade-off] No undeploy equivalent** → Chezmoi manages state forward, not backward. Removing a managed file requires deleting it from source and re-applying. This is acceptable since undeploy is rarely used.
- **[Trade-off] Learning curve** → Chezmoi's Go template syntax is more verbose than dotter's simple `{{variable}}`. However, it's also far more powerful and well-documented.
