## Context

Git commit signing is currently wired to 1Password's `op-ssh-sign` binary via `gpg.ssh.program`. The signing public key is also hardcoded in `home/dot_config/git/config`. The goal is to make signing work with any SSH agent (including, but not limited to, the 1Password agent), template the key from 1Password via chezmoi, add local signature verification support via `allowed_signers`, and provide an SSH agent initialization setup for fish shell.

Current state of relevant config:
- `gpg.format = ssh` — already set
- `gpg.ssh.program = /opt/1Password/op-ssh-sign` — to be removed
- `user.signingkey = ssh-ed25519 AAAA...` — to be templated
- No `gpg.ssh.allowedSignersFile` configured

## Goals / Non-Goals

**Goals:**
- Remove hard dependency on `op-ssh-sign` for commit signing
- Template `user.signingkey` from 1Password so the key is never hardcoded
- Add `~/.ssh/allowed_signers` for local signature verification, also populated from 1Password
- Provide SSH agent startup and key loading for fish shell sessions

**Non-Goals:**
- Provisioning SSH key files into `~/.ssh/` from 1Password (separate change)
- Managing multiple SSH keys or per-key purposes
- Changing the signing key itself

## Decisions

### 1. Remove `gpg.ssh.program` entirely (not replace with `ssh-keygen`)

When `gpg.format = ssh` is set and `gpg.ssh.program` is absent, git defaults to `ssh-keygen` internally. Removing the line is cleaner than an explicit redundant value.

**Rejected**: setting `gpg.ssh.program = ssh-keygen` — redundant noise in config.

---

### 2. Convert `git/config` to a chezmoi template

`home/dot_config/git/config` becomes `home/dot_config/git/config.tmpl`. The `user.signingkey` value is read from 1Password using chezmoi's `onepasswordRead` function:

```
[user]
    signingkey = {{ onepasswordRead "op://Personal/GitHub SSH Key/public key" }}
```

The exact 1Password item path is a placeholder — the real path must be confirmed during implementation.

**Rejected**: using `onepasswordItemFields` — more verbose; `onepasswordRead` is sufficient for a single field.

---

### 3. Manage `~/.ssh/allowed_signers` as a chezmoi template

`home/private_dot_ssh/allowed_signers.tmpl` is created with the format required by git's SSH signature verification:

```
{{ .email }} namespaces="git" {{ onepasswordRead "op://Personal/GitHub SSH Key/public key" }}
```

The `private_` prefix gives it `600` permissions, consistent with other files under `~/.ssh/`.

---

### 4. SSH agent setup via fish `conf.d` file, not a chezmoi `run_once` script

A chezmoi `run_once_` script runs once per unique content at `chezmoi apply` time — not at shell startup. Starting `ssh-agent` at apply time is useless because the agent process and its `SSH_AUTH_SOCK` would not be inherited by future shell sessions.

The correct approach for fish is a `conf.d` file that:
1. Checks if an agent is already running (via `SSH_AUTH_SOCK` / `SSH_AGENT_PID`)
2. If not, starts a new agent and persists the socket path to a known file (e.g., `~/.ssh/agent-env.fish`)
3. Sources that file in subsequent sessions to reconnect to the existing agent

**Option considered and rejected**: `systemd --user` socket activation for ssh-agent — correct for servers/desktops, but adds complexity and doesn't fit the `minipc`/`server` machine class model where chezmoi already excludes certain configs.

**Fish-specific note**: The conf.d file uses `set -gx` to export `SSH_AUTH_SOCK` and `SSH_AGENT_PID` into the fish environment. It should be added to `home/dot_config/fish/conf.d/`.

---

### 5. `ssh-add` is NOT automated in this change

Loading keys with `ssh-add` requires the keys to exist in `~/.ssh/`, which is out of scope here (tracked in the future `ssh-key-management` change). The agent setup script will only start the agent; key loading will be addressed when the keys are provisioned.

## Risks / Trade-offs

- **Agent not running at signing time** → `git commit` fails with a confusing error. Mitigation: the fish conf.d file starts the agent automatically on shell startup; document that the agent must be running.
- **1Password item path unknown until implementation** → template will have a placeholder. Mitigation: the implementer must confirm the path from the 1Password vault before deploying.
- **`allowed_signers` only covers self-verification** → verifying other contributors' commits requires their keys in the file too. This is a known limitation; expanding it is out of scope.
- **`minipc` machine class** → per `.chezmoiignore`, `minipc` gets git config. The ssh-agent conf.d file should also be included for `minipc` since it's a desktop-class machine.

## Migration Plan

1. Read current `git/config` and create `git/config.tmpl` with the templated key
2. Remove `home/dot_config/git/config` (plain file)
3. Create `home/private_dot_ssh/allowed_signers.tmpl`
4. Create `home/dot_config/fish/conf.d/ssh-agent.fish`
5. Run `chezmoi diff` to verify changes before applying
6. Run `chezmoi apply` and test with `git commit --allow-empty -m "test signing"`
7. Verify with `git log --show-signature`

**Rollback**: restore the original plain `git/config` with hardcoded key and remove the new files.

## Open Questions

- What is the exact 1Password item/field path for the GitHub signing key? (needed to finalize the template)
- Should `ssh-agent.fish` be excluded for `server` machine class? (servers likely use key-based auth differently; probably yes)
