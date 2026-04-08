## ADDED Requirements

### Requirement: 1Password secrets via chezmoi templates
All secrets currently managed via dotter's `{{command_output "op read '...'"}}` SHALL be migrated to chezmoi template files using the `onepasswordRead` function.

#### Scenario: Environment variable secrets
- **WHEN** `secrets.fish.tmpl` is applied by chezmoi
- **THEN** it SHALL use `{{ onepasswordRead "op://development/GitHub Personal Access Token/token" }}` (and similar) to populate secret environment variables

#### Scenario: Consul secrets
- **WHEN** `secrets.fish.tmpl` is applied
- **THEN** it SHALL resolve `CONSUL_HTTP_ADDR` and `CONSUL_HTTP_TOKEN` from 1Password vault references using `onepasswordRead`

### Requirement: 1Password SSH agent integration preserved
The SSH agent socket configuration for 1Password SHALL continue to work after migration. The SSH config and git signing configuration SHALL remain functional.

#### Scenario: SSH agent socket
- **WHEN** chezmoi applies the SSH config
- **THEN** the `IdentityAgent` SHALL point to the 1Password agent socket path (`~/.1password/agent.sock`)

#### Scenario: Git commit signing
- **WHEN** chezmoi applies the git config
- **THEN** the `gpg.ssh.program` SHALL point to `/opt/1Password/op-ssh-sign`

### Requirement: Runtime 1Password calls preserved
Shell scripts that call `op read` at runtime (not at template render time) SHALL be migrated as plain files, not templates. Only files that embed secrets at deploy time SHALL use `.tmpl` extension.

#### Scenario: Atuin login script
- **WHEN** the atuin loader calls `op read` at shell startup
- **THEN** it SHALL remain a plain fish script (not a template) since it fetches credentials at runtime

#### Scenario: AWS 1Password wrapper
- **WHEN** the `awsop` function calls `op read` at invocation time
- **THEN** it SHALL remain a plain fish script since it fetches credentials on demand
