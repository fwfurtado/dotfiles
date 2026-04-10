## 1. Git Config — SSH Signing

- [x] 1.1 Confirm the 1Password item/field path for the GitHub signing public key
- [x] 1.2 Rename `home/dot_config/git/config` to `home/dot_config/git/config.tmpl`
- [x] 1.3 Remove the `[gpg "ssh"]` section (deletes the `op-ssh-sign` program entry)
- [x] 1.4 Replace the hardcoded `user.signingkey` with `{{ onepasswordRead "op://..." }}` using the confirmed path
- [x] 1.5 Add `allowedSignersFile = ~/.ssh/allowed_signers` under `[gpg "ssh"]`

## 2. Allowed Signers File

- [x] 2.1 Create `home/private_dot_ssh/allowed_signers.tmpl` with one entry: `{{ .chezmoi.sourceDir | ... }}` → `<email> namespaces="git" {{ onepasswordRead "op://..." }}`
- [x] 2.2 Verify the file uses the `private_` prefix (chezmoi deploys it as mode `600`)

## 3. SSH Agent Setup (fish)

- [x] 3.1 Create `home/dot_config/fish/conf.d/ssh-agent.fish` that:
  - checks if `SSH_AUTH_SOCK` points to a live agent socket
  - if not, starts `ssh-agent` and persists socket info to `~/.ssh/agent-env.fish`
  - sources `~/.ssh/agent-env.fish` to reconnect in subsequent sessions
- [x] 3.2 Add `ssh-agent.fish` to `.chezmoiignore` exclusion for `server` machine class

## 4. Verification

- [x] 4.1 Run `chezmoi diff` and confirm only expected files appear
- [x] 4.2 Run `chezmoi apply`
- [x] 4.3 Open a new fish shell and verify `SSH_AUTH_SOCK` is set
- [x] 4.4 Create an empty test commit: `git commit --allow-empty -m "test: verify ssh signing"`
- [x] 4.5 Run `git log --show-signature` and confirm the signature is reported as valid
- [x] 4.6 Confirm `~/.config/git/config` contains no hardcoded SSH public key string
