# Delta for env-config

## MODIFIED Requirements

### Requirement: Required variable exports

The system MUST export `NEXUS_VERSION="0.2.0"`, `NEXUS_LANG="es"`, color escape codes in cyan (`NEXUS_COLOR_PRIMARY`) and reset (`NEXUS_COLOR_RESET`), `NEXUS_AGENTS_DIR` pointing to `modules/`, `NEXUS_MODULES_DIR` pointing to `modules/`, `NEXUS_REGISTRY` pointing to `config/agents.registry.sh`, and `NEXUS_LOG_FILE` pointing to `logs/nexus.log`.
(Previously: exported NEXUS_VERSION="0.1.0", NEXUS_AGENTS_DIR, NEXUS_LOG_FILE; no NEXUS_MODULES_DIR or NEXUS_REGISTRY)

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
