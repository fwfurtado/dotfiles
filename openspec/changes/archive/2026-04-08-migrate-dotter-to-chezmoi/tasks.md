## 1. Chezmoi Source Directory Setup

- [x] 1.1 Create `.chezmoiroot` file at repo root containing `home`
- [x] 1.2 Create `home/` directory with `.chezmoi.toml.tmpl` for machine class detection (hostname mapping + interactive fallback)
- [x] 1.3 Create `home/.chezmoiignore` with template conditionals to exclude packages per machine class

## 2. Migrate Config Files to Chezmoi Source Layout

- [x] 2.1 Migrate `config/fish/` → `home/dot_config/fish/` (preserve all subdirectories: conf.d, completions, functions)
- [x] 2.2 Migrate `config/nvim/` → `home/dot_config/exact_nvim/`
- [x] 2.3 Migrate `config/nushell/` → `home/dot_config/nushell/`
- [x] 2.4 Migrate `config/tmux/` → `home/dot_config/tmux/`
- [x] 2.5 Migrate `config/ghostty/` → `home/dot_config/ghostty/`
- [x] 2.6 Migrate `config/oh-my-posh/` → `home/dot_config/oh-my-posh/`
- [x] 2.7 Migrate `config/starship.toml` → `home/dot_config/starship.toml`
- [x] 2.8 Migrate `config/git/` → `home/dot_config/git/`
- [x] 2.9 Migrate `ssh/config` → `home/private_dot_ssh/config`
- [x] 2.10 Migrate `scripts/remote-display.sh` → `home/dot_local/private_bin/executable_remote-display.sh`
- [x] 2.11 Migrate `wallpapers/` → `home/Pictures/wallpapers/`

## 3. Convert Templates

- [x] 3.1 Convert `secrets.fish` to `secrets.fish.tmpl` — replace `{{command_output "op read '...'"}}` with `{{ onepasswordRead "op://..." }}`
- [x] 3.2 Convert ghostty `config` to `config.tmpl` — replace `{{ background_opacity }}` with `{{ .background_opacity }}`
- [x] 3.3 Verify atuin loader and awsop wrapper remain plain files (runtime `op read` calls, not templates)

## 4. Machine Profile Configuration

- [x] 4.1 Define machine class data in `.chezmoi.toml.tmpl` with hostname-to-class mapping and default variables (e.g., `background_opacity`)
- [x] 4.2 Populate `.chezmoiignore` with package exclusion rules per machine class matching current `local.toml` selections
- [x] 4.3 Verify that the current machine's package set (git, fish, starship, wallpapers, ssh, scripts) is correctly included

## 5. Taskfile and Cleanup

- [x] 5.1 Update `Taskfile.yml` — replace `dotter deploy`/`undeploy` with `chezmoi apply`, add `diff` and `init` tasks
- [x] 5.2 Remove `.dotter/` directory (`global.toml`, `local.toml`, `cache.toml`, `cache/`)
- [x] 5.3 Remove old `config/`, `ssh/`, `scripts/`, `wallpapers/` source directories (now in `home/`)

## 6. Validation

- [x] 6.1 Run `chezmoi diff` to verify all target files match expected state
- [x] 6.2 Verify 1Password secrets resolve correctly in `secrets.fish.tmpl` via `chezmoi cat`
- [x] 6.3 Verify machine-conditional ignore rules work by inspecting `chezmoi managed` output
