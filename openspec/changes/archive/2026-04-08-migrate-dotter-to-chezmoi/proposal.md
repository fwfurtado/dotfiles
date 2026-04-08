## Why

Dotter lacks built-in support for machine-specific conditional configuration and has limited templating capabilities. As the dotfiles need to scale across multiple machines with different package selections, OS-level conditionals, and 1Password-managed secrets, chezmoi provides a more mature solution with native support for templates, machine-based conditionals, and external secret managers — reducing the need for shell-level workarounds.

## What Changes

- **BREAKING**: Replace dotter with chezmoi as the dotfiles manager — `.dotter/` config, `local.toml`, and `global.toml` will be removed
- Restructure the dotfiles source directory to follow chezmoi conventions (e.g., `dot_config/`, `private_dot_ssh/`)
- Convert dotter's package-based selection (`local.toml` packages) to chezmoi's template-based conditionals using `.chezmoidata.yaml` and `.chezmoiignore`
- Replace dotter's `{{command_output "op read ..."}}` template syntax with chezmoi's `onepasswordRead` template function for secrets (`secrets.fish`, atuin login)
- Replace dotter's `{{variable}}` templating (ghostty `background_opacity`) with chezmoi's Go template syntax
- Add `Taskfile` targets for chezmoi operations (init, apply, diff) replacing the current `deploy`/`undeploy` tasks
- Support per-machine configuration via `chezmoidata.yaml` and hostname/OS-based template conditionals

## Capabilities

### New Capabilities
- `chezmoi-source-layout`: Restructure the dotfiles repo into chezmoi's source directory format with proper naming conventions (`dot_`, `private_`, `exact_`)
- `chezmoi-machine-profiles`: Machine-aware conditional configuration using chezmoi data files, `.chezmoiignore` templates, and hostname/OS conditionals to replace dotter's `local.toml` package selection
- `chezmoi-secret-management`: 1Password integration via chezmoi's built-in `onepasswordRead` template function, replacing dotter's `command_output` templating for secrets
- `chezmoi-templates`: Convert existing dotter templates (variables and command_output) to chezmoi's Go text/template syntax

### Modified Capabilities
<!-- No existing specs to modify -->

## Impact

- **Files**: All dotfile sources under `config/`, `ssh/`, `scripts/`, `wallpapers/` will be reorganized into chezmoi source format
- **Dependencies**: Requires `chezmoi` installed on all target machines; `dotter` can be removed after migration
- **Tooling**: `Taskfile.yml` deploy/undeploy tasks need updating for chezmoi commands
- **Secrets**: 1Password CLI (`op`) remains required; template syntax changes but vault references stay the same
- **Git**: Large structural diff as files are moved/renamed to chezmoi conventions; recommend a single migration commit
