## ADDED Requirements

### Requirement: Chezmoi source directory structure
The repository SHALL use a `home/` directory as the chezmoi source root, configured via `.chezmoiroot`. All managed dotfiles SHALL reside under `home/` using chezmoi naming conventions (`dot_`, `private_`, `exact_`, `symlink_`).

#### Scenario: Source root configuration
- **WHEN** chezmoi reads the repository
- **THEN** it SHALL find a `.chezmoiroot` file at the repo root containing `home` and use `home/` as the source directory

#### Scenario: Config directory mapping
- **WHEN** a config directory exists at `config/<name>` in the current dotter layout
- **THEN** it SHALL be migrated to `home/dot_config/<name>/` with appropriate chezmoi prefixes

#### Scenario: Private file handling
- **WHEN** a file requires restricted permissions (e.g., SSH config)
- **THEN** it SHALL use the `private_` prefix in the chezmoi source (e.g., `home/private_dot_ssh/config`)

#### Scenario: Symlink handling
- **WHEN** a file was configured as `type = "symbolic"` in dotter (oh-my-posh, ssh/config, scripts)
- **THEN** it SHALL use chezmoi's `symlink_` prefix or be converted to a regular managed file, whichever is more appropriate for the target

### Requirement: All current dotter packages mapped
Every package defined in `.dotter/global.toml` SHALL have a corresponding entry in the chezmoi source directory. No managed files SHALL be lost during migration.

#### Scenario: Complete package coverage
- **WHEN** comparing the dotter `global.toml` packages (nvim, fish, nushell, tmux, ghostty, oh-my-posh, starship, wallpapers, git, ssh, scripts)
- **THEN** every file mapping in each package SHALL have a corresponding file in the chezmoi `home/` directory

#### Scenario: Wallpapers directory
- **WHEN** wallpapers are managed (currently `wallpapers` → `~/Pictures/wallpapers/`)
- **THEN** they SHALL be placed at `home/Pictures/wallpapers/` in the chezmoi source

### Requirement: Dotter configuration removal
After migration, dotter-specific files SHALL be removed from the repository.

#### Scenario: Cleanup of dotter files
- **WHEN** the migration is complete
- **THEN** `.dotter/global.toml`, `.dotter/local.toml`, `.dotter/cache.toml`, and `.dotter/cache/` SHALL be removed from the repository
