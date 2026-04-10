## Purpose

Defines requirements for git commit signing using the SSH agent, with keys sourced from 1Password via chezmoi templates and local signature verification via `allowed_signers`.

## Requirements

### Requirement: Git signs commits via SSH agent
Git SHALL use `ssh-keygen` (via the SSH agent) to sign commits, with no dependency on the 1Password `op-ssh-sign` binary. The `[gpg "ssh"]` program override SHALL be absent from the git config.

#### Scenario: Commit is signed without 1Password running
- **WHEN** the user creates a git commit and the SSH agent has the signing key loaded
- **THEN** the commit is signed successfully without requiring the 1Password desktop app

#### Scenario: No program override in git config
- **WHEN** chezmoi applies the git config template
- **THEN** the rendered `~/.config/git/config` MUST NOT contain a `gpg.ssh.program` entry

---

### Requirement: Signing key is sourced from 1Password at deploy time
The `user.signingkey` value in the git config SHALL be read from 1Password via a chezmoi template, not hardcoded in the source file.

#### Scenario: Key is templated correctly
- **WHEN** chezmoi applies the git config template
- **THEN** the rendered `~/.config/git/config` contains the correct SSH public key retrieved from 1Password

#### Scenario: Source file contains no hardcoded key material
- **WHEN** the git config source file is inspected in the dotfiles repo
- **THEN** no SSH public key string is present — only the chezmoi template expression

---

### Requirement: Local signature verification via allowed_signers
Git SHALL be configured with `gpg.ssh.allowedSignersFile` pointing to `~/.ssh/allowed_signers`, enabling local verification of signed commits.

#### Scenario: Allowed signers file is referenced in git config
- **WHEN** chezmoi applies the git config template
- **THEN** the rendered config contains `allowedSignersFile = ~/.ssh/allowed_signers`

#### Scenario: Allowed signers file contains the user's own key
- **WHEN** chezmoi applies the allowed_signers template
- **THEN** `~/.ssh/allowed_signers` contains one entry in the format `<email> namespaces="git" <public-key>`, with the key read from 1Password

#### Scenario: Self-signed commit is verifiable
- **WHEN** the user runs `git log --show-signature` on a commit they signed
- **THEN** git reports the signature as valid
