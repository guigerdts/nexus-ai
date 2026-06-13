# shell-bootstrap Specification

## Purpose

Shell configs (`.bashrc`, `.zshrc`) that set up PATH for interactive NEXUS AI usage. Must include Termux bind-mount PATH entries when running inside proot-Ubuntu with Termux accessible.

## Requirements

### Requirement: Termux PATH in shell configs

Both `shell/.bashrc` and `shell/.zshrc` MUST prepend Termux bind-mount bin directories to PATH when `/data/data/com.termux/files/usr/bin` exists. Each entry SHALL be guarded by `[ -d "$dir" ]`.

| Scenario | Condition | Behavior |
|----------|-----------|----------|
| .bashrc with Termux | `/data/data/com.termux/files/usr/bin` exists | Prepend `TERMUX_BIN` and `TERMUX_PREFIX/local/bin` to PATH |
| .zshrc with Termux | Same dir exists | Same PATH entries as .bashrc |
| No Termux | Dir does not exist | No PATH changes, no errors |

### Requirement: Sourced nexus.env config

The shell RC files (`.bashrc`, `.zshrc`) SHOULD source `$NEXUS_ROOT/config/nexus.env` after determining `NEXUS_ROOT`. This replaces the hardcoded inline PATH blocks and simplifies maintenance. If `nexus.env` does not exist, the existing inline PATH logic SHALL remain as backward-compatible fallback. The installer SHOULD create `nexus.env` during installation.

#### Scenario: bashrc sources nexus.env

- GIVEN `config/nexus.env` exists
- WHEN `.bashrc` is sourced
- THEN it MUST source `$NEXUS_ROOT/config/nexus.env`
- AND the centralized PATH exports from nexus.env MUST take effect

#### Scenario: nexus.env absent in bashrc (backward compat)

- GIVEN `config/nexus.env` does NOT exist
- WHEN `.bashrc` is sourced
- THEN the existing inline PATH block MUST be used
- AND the user MUST NOT see any error

#### Scenario: zshrc sources nexus.env

- GIVEN `config/nexus.env` exists
- WHEN `.zshrc` is sourced
- THEN it MUST source `$NEXUS_ROOT/config/nexus.env`
- AND the Termux bind-mount PATH MUST be set via nexus.env

### Requirement: Starship update indicator module

The system SHOULD include an optional custom module in `shell/starship.toml` that shows an update indicator in the shell prompt. The module SHALL check for the existence of `$NEXUS_ROOT/logs/update-available.txt`. If the marker exists, the prompt SHALL display `⬆` (or a text equivalent if ASCII-only mode is preferred) in a configurable format and color. The module MUST be commented out by default and MAY be enabled by the user.

#### Scenario: Marker exists, module enabled

- GIVEN `logs/update-available.txt` contains `v0.5.0`
- AND the Starship module is enabled (uncommented)
- WHEN the Starship prompt renders
- THEN the prompt MUST show the update indicator
- AND the indicator MUST be styled per the module configuration

#### Scenario: Marker absent, module enabled

- GIVEN `logs/update-available.txt` does NOT exist
- AND the Starship module is enabled
- WHEN the Starship prompt renders
- THEN the indicator MUST NOT appear
- AND the prompt SHALL render normally

#### Scenario: Module commented out (default)

- GIVEN the module is commented out in `starship.toml`
- WHEN the Starship prompt renders
- THEN no update indicator SHALL appear
- AND the module configuration SHALL NOT be loaded
