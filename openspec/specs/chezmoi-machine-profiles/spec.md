# chezmoi-machine-profiles Specification

## Purpose
TBD - created by archiving change migrate-dotter-to-chezmoi. Update Purpose after archive.
## Requirements
### Requirement: Machine class detection
Chezmoi SHALL support identifying the current machine's class (e.g., `laptop`, `desktop`, `server`) to drive conditional configuration. The machine class SHALL be configurable via `.chezmoi.toml.tmpl` using hostname detection or interactive prompt.

#### Scenario: Automatic detection by hostname
- **WHEN** chezmoi initializes on a machine with a known hostname
- **THEN** the `.chezmoi.toml.tmpl` SHALL map the hostname to a machine class stored in `.machineClass`

#### Scenario: Unknown hostname fallback
- **WHEN** chezmoi initializes on a machine with an unrecognized hostname
- **THEN** it SHALL prompt the user to select a machine class interactively

### Requirement: Package selection via ignore templates
The `.chezmoiignore` file SHALL use Go template conditionals to include or exclude directories based on machine class, replacing dotter's `local.toml` package selection.

#### Scenario: Excluding a package from a machine
- **WHEN** a machine class does not require a package (e.g., server does not need wallpapers)
- **THEN** the `.chezmoiignore` SHALL contain a conditional that excludes that package's source directory for that machine class

#### Scenario: Including all packages for a machine
- **WHEN** a machine class requires all packages
- **THEN** no entries in `.chezmoiignore` SHALL exclude any package directories for that machine class

### Requirement: Per-machine variable overrides
Machine-specific variables (e.g., ghostty `background_opacity`) SHALL be configurable per machine class using chezmoi data in `.chezmoi.toml.tmpl`.

#### Scenario: Machine-specific variable value
- **WHEN** a template file references a machine-specific variable
- **THEN** chezmoi SHALL resolve the variable from the machine's data section in the chezmoi config

#### Scenario: Default variable values
- **WHEN** a variable is not overridden for a machine class
- **THEN** a sensible default value SHALL be used in the template

