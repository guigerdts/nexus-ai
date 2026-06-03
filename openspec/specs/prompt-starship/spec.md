# prompt-starship Specification

## Purpose

Dual-level prompt system for NEXUS AI. Primary: Starship with a cyan/black palette. Fallback: Zsh native `vcs_info` when Starship is unavailable (e.g., ARM64 targets without a prebuilt binary).

## Requirements

### Requirement: Config location

The Starship configuration MUST live at `$NEXUS_ROOT/shell/starship.toml`.

#### Scenario: Default config load

- GIVEN Starship binary is available
- WHEN the shell initializes
- THEN Starship MUST read its config from `$NEXUS_ROOT/shell/starship.toml`
- AND NOT from `~/.config/starship.toml`

### Requirement: User config preservation

The installer MUST NOT overwrite an existing `~/.config/starship.toml`. If one exists, the installer SHOULD skip or ask before replacing.

#### Scenario: Existing user Starship config

- GIVEN the user has `~/.config/starship.toml`
- WHEN the NEXUS installer runs
- THEN the existing file MUST remain untouched
- AND a message SHOULD inform the user that their config was preserved

### Requirement: Color palette

The prompt MUST use cyan `#00BCD4` for the path, white for general text, green for clean git status, and red for dirty git status.

#### Scenario: Git clean state

- GIVEN the current directory is a git repo with no uncommitted changes
- WHEN the prompt renders
- THEN the git indicator MUST appear in green

#### Scenario: Git dirty state

- GIVEN the current directory has uncommitted changes
- WHEN the prompt renders
- THEN the git indicator MUST appear in red

### Requirement: Prompt elements

The prompt MUST display: `username@host`, current directory, git branch with clean/dirty status, and command execution time.

#### Scenario: Full prompt display

- GIVEN the shell is ready
- WHEN the prompt renders
- THEN it MUST show `user@host`, the working directory path, the git branch if in a repo, and execution time for the previous command

### Requirement: Starship fallback

If the Starship binary fails to install or run on ARM64, the system MUST auto-activate Level 1 fallback using Zsh native `vcs_info` with zero external dependencies.

#### Scenario: Starship unavailable

- GIVEN the Starship binary is not found or fails to execute
- WHEN the shell initializes
- THEN the system MUST fall back to `vcs_info` for git status
- AND NOT show any Starship-related errors to the user

#### Scenario: Starship available after install

- GIVEN the installer successfully downloads Starship for the target architecture
- WHEN the shell initializes
- THEN Starship MUST be the active prompt provider
- AND `vcs_info` MUST remain unused
