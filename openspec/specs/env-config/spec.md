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

### Requirement: NEXUS_GUM_AVAILABLE detection

The system MUST export `NEXUS_GUM_AVAILABLE` set via `command -v gum &>/dev/null && echo true || echo false`. This detection MUST execute early in env.sh load time so all dependent scripts can read it without re-checking.

#### Scenario: Gum available detected

- GIVEN `gum` is installed and in PATH
- WHEN `config/env.sh` is sourced
- THEN `NEXUS_GUM_AVAILABLE` MUST be set to `"true"`

#### Scenario: Gum unavailable detected

- GIVEN `gum` is NOT installed or NOT in PATH
- WHEN `config/env.sh` is sourced
- THEN `NEXUS_GUM_AVAILABLE` MUST be set to `"false"`

### Requirement: Unified color system

The system MUST export `NEXUS_COLOR_CYAN`, `NEXUS_COLOR_YELLOW`, `NEXUS_COLOR_RED`, `NEXUS_COLOR_GREEN`, `NEXUS_COLOR_GRAY`, and `NEXUS_COLOR_RESET` as the single source of ANSI color codes. The pre-v0.4 `_NEXUS_CYAN`, `_NEXUS_YELLOW`, `_NEXUS_RED`, and `_NEXUS_RESET` variables in `lib/nexus-log.sh` MUST be removed and replaced with references to the exports from `config/env.sh`. `NEXUS_COLOR_PRIMARY` MUST be kept as an alias for `NEXUS_COLOR_CYAN` for backward compatibility.

#### Scenario: Color unification after change

- GIVEN `config/env.sh` is sourced
- WHEN checking color variables
- THEN `NEXUS_COLOR_PRIMARY` MUST contain cyan ANSI code `\033[0;36m`
- AND `NEXUS_COLOR_CYAN`, `NEXUS_COLOR_YELLOW`, `NEXUS_COLOR_RED`, `NEXUS_COLOR_GREEN`, `NEXUS_COLOR_GRAY` MUST all be exported
- AND `_NEXUS_CYAN` MUST NOT be defined in nexus-log.sh
- AND all scripts MUST reference `NEXUS_COLOR_*` instead of `_NEXUS_*`

### Requirement: Required variable exports

The system MUST export `NEXUS_VERSION="0.2.0"`, `NEXUS_LANG="es"`, color escape codes in cyan (`NEXUS_COLOR_PRIMARY`) and reset (`NEXUS_COLOR_RESET`), `NEXUS_AGENTS_DIR` pointing to `modules/`, `NEXUS_MODULES_DIR` pointing to `modules/`, `NEXUS_REGISTRY` pointing to `config/agents.registry.sh`, `NEXUS_LOG_FILE` pointing to `logs/nexus.log`, and `NEXUS_GUM_AVAILABLE` set via `command -v gum` detection.

#### Scenario: All variables defined after sourcing

- GIVEN `config/env.sh` is sourced
- WHEN checking the environment
- THEN `NEXUS_VERSION` MUST be `"0.2.0"`
- AND `NEXUS_LANG` MUST be `"es"`
- AND `NEXUS_GUM_AVAILABLE` MUST be `"true"` or `"false"` (boolean string)
- AND `NEXUS_AGENTS_DIR` MUST equal `$NEXUS_ROOT/modules`
- AND `NEXUS_MODULES_DIR` MUST equal `$NEXUS_ROOT/modules`
- AND `NEXUS_REGISTRY` MUST equal `$NEXUS_ROOT/config/agents.registry.sh`

#### Scenario: New vars are idempotent on re-source

- GIVEN `config/env.sh` is sourced once
- WHEN it is sourced a second time
- THEN no error MUST occur
- AND `NEXUS_GUM_AVAILABLE` MUST remain unchanged from first detection
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
