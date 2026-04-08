# chezmoi-templates Specification

## Purpose
TBD - created by archiving change migrate-dotter-to-chezmoi. Update Purpose after archive.
## Requirements
### Requirement: Dotter variable templates converted to Go templates
Files using dotter's `{{variable}}` syntax SHALL be converted to chezmoi `.tmpl` files using Go template syntax `{{ .variable }}`.

#### Scenario: Ghostty config template
- **WHEN** the ghostty config file uses `{{ background_opacity }}` in dotter
- **THEN** it SHALL be migrated to `config.tmpl` using `{{ .background_opacity }}` with the value sourced from chezmoi data

### Requirement: Dotter command_output templates converted to chezmoi functions
Files using dotter's `{{command_output "..."}}` syntax SHALL be converted to chezmoi `.tmpl` files using the appropriate chezmoi template function.

#### Scenario: 1Password command_output to onepasswordRead
- **WHEN** a dotter template uses `{{command_output "op read 'op://...'"}}` 
- **THEN** it SHALL be converted to `{{ onepasswordRead "op://..." }}` in the chezmoi template

### Requirement: Template files use .tmpl extension
All files that contain chezmoi template directives SHALL have the `.tmpl` suffix appended to their source filename.

#### Scenario: Template file naming
- **WHEN** `secrets.fish` contains template directives
- **THEN** it SHALL be named `secrets.fish.tmpl` in the chezmoi source directory

#### Scenario: Non-template files unchanged
- **WHEN** a file contains no template directives (e.g., `01-envs.fish`)
- **THEN** it SHALL NOT have a `.tmpl` suffix and SHALL be copied verbatim by chezmoi

