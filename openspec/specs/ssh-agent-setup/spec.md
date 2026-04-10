## Purpose

Defines requirements for automatic SSH agent initialization in fish shell sessions, managed via chezmoi with per-machine-class exclusions.

## Requirements

### Requirement: SSH agent starts automatically on fish shell session
A fish `conf.d` file SHALL start `ssh-agent` automatically if no running agent is detected, making `SSH_AUTH_SOCK` available in every fish session.

#### Scenario: Agent is not running at shell startup
- **WHEN** a new fish shell session starts and no `SSH_AUTH_SOCK` points to a live agent
- **THEN** a new `ssh-agent` process is started and `SSH_AUTH_SOCK` and `SSH_AGENT_PID` are exported into the fish environment

#### Scenario: Agent is already running at shell startup
- **WHEN** a new fish shell session starts and a valid `SSH_AUTH_SOCK` already exists
- **THEN** the existing agent is reused and no new agent process is started

#### Scenario: Agent socket is persisted across sessions
- **WHEN** `ssh-agent` is started by the conf.d file
- **THEN** the socket path and PID are written to a known file (e.g., `~/.ssh/agent-env.fish`) so subsequent shell sessions can reconnect

---

### Requirement: SSH agent setup is managed by chezmoi
The `ssh-agent.fish` conf.d file SHALL be managed as a chezmoi source file under `home/dot_config/fish/conf.d/`.

#### Scenario: File is deployed by chezmoi
- **WHEN** chezmoi applies on a machine where the fish config is not excluded
- **THEN** `~/.config/fish/conf.d/ssh-agent.fish` is created with correct content

#### Scenario: File is excluded for server machine class
- **WHEN** chezmoi applies on a machine with `machineClass = server`
- **THEN** `ssh-agent.fish` is NOT deployed (servers manage SSH agent via other means)
