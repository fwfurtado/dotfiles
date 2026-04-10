## Why

Git commit signing currently depends on 1Password's `op-ssh-sign` binary and has the signing public key hardcoded in the git config. While 1Password remains in use as the chezmoi secret backend, signing commits should not require the 1Password desktop app or its SSH agent bridge. Switching to the system SSH agent decouples signing from the 1Password UI, and using chezmoi templates to read the key from 1Password eliminates the hardcoded public key.

## What Changes

- Remove `gpg.ssh.program = /opt/1Password/op-ssh-sign` entirely (git defaults to `ssh-keygen` when `gpg.format = ssh` and no program is specified)
- Convert `home/dot_config/git/config` to a chezmoi template so `user.signingkey` is read from 1Password at deploy time instead of being hardcoded
- Add `gpg.ssh.allowedSignersFile = ~/.ssh/allowed_signers` to git config for local signature verification
- Manage `~/.ssh/allowed_signers` via chezmoi, populated with the user's own signing key (also read from 1Password)
- Add a chezmoi `run_once` script that starts `ssh-agent` and loads keys from `~/.ssh/` via `ssh-add` (fish shell compatible)
- **Note**: This change assumes SSH keys are already present in `~/.ssh/`. Provisioning those keys from 1Password is out of scope and tracked as a separate change.

## Capabilities

### New Capabilities
- `git-ssh-signing`: Git commit signing via SSH agent using `ssh-keygen`, with signing key sourced from 1Password via chezmoi template and local verification via `allowed_signers`
- `ssh-agent-setup`: A chezmoi `run_once` script that initializes `ssh-agent` and loads keys from `~/.ssh/` on first run, compatible with fish shell

### Modified Capabilities
<!-- No existing specs cover git signing or SSH agent configuration -->

## Impact

- `home/dot_config/git/config` → becomes `home/dot_config/git/config.tmpl`: removes `[gpg "ssh"]` program override, adds `gpg.ssh.allowedSignersFile`, and templates `user.signingkey` from 1Password
- New chezmoi-managed `home/private_dot_ssh/allowed_signers.tmpl` (reads signing public key from 1Password)
- New chezmoi `run_once` script under `home/` for ssh-agent initialization (exact path TBD in design)
- Fish shell environment may need `SSH_AUTH_SOCK`/`SSH_AGENT_PID` exported — to be addressed in design
- 1Password continues to be used as chezmoi's secret backend; only `op-ssh-sign` is removed from the signing flow
- **Depends on**: A future "ssh-key-management" change that provisions SSH keys into `~/.ssh/` from 1Password
