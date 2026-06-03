# env-config Specification

## Purpose

Environment configuration layer for NEXUS AI — auto-detects the installation root, exports canonical variables, and detects the runtime environment. Sourced by every script in the framework.

## Requirements

### Requirement: NEXUS_ROOT auto-detection

The system MUST derive `NEXUS_ROOT` from `SCRIPT_DIR` using `BASH_SOURCE[0]` resolution. No path SHALL be hardcoded.

#### Scenario: Normal sourcing from config/env.sh

- GIVEN `config/env.sh` is sourced from any script within the project
- WHEN the script executes `SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)`
- THEN `NEXUS_ROOT` MUST equal the parent directory of `config/`

#### Scenario: Symlinked script detection

- GIVEN `config/env.sh` is accessed through a symbolic link
- WHEN `readlink -f` resolves the symlink
- THEN `NEXUS_ROOT` MUST resolve to the real (canonical) project root, not the symlink directory

### Requirement: Required variable exports

The system MUST export `NEXUS_VERSION="0.2.0"`, `NEXUS_LANG="es"`, color escape codes in cyan (`NEXUS_COLOR_PRIMARY`) and reset (`NEXUS_COLOR_RESET`), `NEXUS_AGENTS_DIR` pointing to `modules/`, `NEXUS_MODULES_DIR` pointing to `modules/`, `NEXUS_REGISTRY` pointing to `config/agents.registry.sh`, and `NEXUS_LOG_FILE` pointing to `logs/nexus.log`.

#### Scenario: All variables defined after sourcing

- GIVEN `config/env.sh` is sourced
- WHEN checking the environment
- THEN `NEXUS_VERSION` MUST be `"0.2.0"`
- AND `NEXUS_LANG` MUST be `"es"`
- AND `NEXUS_AGENTS_DIR` MUST equal `$NEXUS_ROOT/modules`
- AND `NEXUS_MODULES_DIR` MUST equal `$NEXUS_ROOT/modules`
- AND `NEXUS_REGISTRY` MUST equal `$NEXUS_ROOT/config/agents.registry.sh`

#### Scenario: New vars are idempotent on re-source

- GIVEN `config/env.sh` is sourced once
- WHEN it is sourced a second time
- THEN no error MUST occur
- AND `NEXUS_MODULES_DIR` MUST remain unchanged
- AND `NEXUS_REGISTRY` MUST remain unchanged

### Requirement: Environment detection

The system MUST detect and export `NEXUS_ENV` as one of `"termux"`, `"proot-ubuntu"`, or `"linux"`, and `NEXUS_ARCH` as `"arm64"` or `"x86_64"`.

#### Scenario: Termux native detection

- GIVEN the script runs inside Termux (where `$PREFIX` exists)
- WHEN environment detection runs
- THEN `NEXUS_ENV` MUST be `"termux"`

#### Scenario: Unrecognized Linux environment

- GIVEN the script runs on a standard Linux with no `$PREFIX` or proot markers
- WHEN environment detection runs
- THEN `NEXUS_ENV` MUST be `"linux"`

### Requirement: Idempotent sourcing

The system MUST be safe to source multiple times — no duplicate variable overwrites SHALL cause side effects.

#### Scenario: Double sourcing

- GIVEN `config/env.sh` is sourced once
- WHEN it is sourced a second time in the same shell session
- THEN no error MUST occur
- AND `NEXUS_ROOT` MUST remain unchanged
