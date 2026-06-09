# Delta for shell-bootstrap

## ADDED Requirements

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
