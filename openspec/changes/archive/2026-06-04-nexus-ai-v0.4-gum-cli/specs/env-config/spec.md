# Delta for env-config

## ADDED Requirements

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

The system MUST export `NEXUS_COLOR_PRIMARY` (cyan) and `NEXUS_COLOR_RESET` as the single source of ANSI color codes. The `_NEXUS_CYAN`, `_NEXUS_YELLOW`, `_NEXUS_RED`, and `_NEXUS_RESET` variables in `lib/nexus-log.sh` MUST be removed and replaced with references to the exports from `config/env.sh`.

#### Scenario: Color unification after change

- GIVEN `config/env.sh` is sourced
- WHEN checking color variables
- THEN `NEXUS_COLOR_PRIMARY` MUST contain cyan ANSI code `\033[0;36m`
- AND `_NEXUS_CYAN` MUST NOT be defined in nexus-log.sh
- AND all scripts MUST reference `NEXUS_COLOR_PRIMARY` instead of `_NEXUS_CYAN`

## MODIFIED Requirements

### Requirement: Required variable exports

The system MUST export `NEXUS_VERSION="0.2.0"`, `NEXUS_LANG="es"`, color escape codes in cyan (`NEXUS_COLOR_PRIMARY`) and reset (`NEXUS_COLOR_RESET`), `NEXUS_AGENTS_DIR` pointing to `modules/`, `NEXUS_MODULES_DIR` pointing to `modules/`, `NEXUS_REGISTRY` pointing to `config/agents.registry.sh`, `NEXUS_LOG_FILE` pointing to `logs/nexus.log`, and `NEXUS_GUM_AVAILABLE` set via `command -v gum` detection.
(Previously: no NEXUS_GUM_AVAILABLE, color vars used dual systems in env.sh and nexus-log.sh)

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
