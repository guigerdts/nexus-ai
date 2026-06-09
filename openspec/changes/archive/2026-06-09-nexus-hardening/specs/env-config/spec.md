# Delta for env-config

## ADDED Requirements

### Requirement: Centralized nexus.env config

The system MAY source `$NEXUS_ROOT/config/nexus.env` if it exists, AFTER setting all NEXUS_* variables. This file SHALL contain user-facing overrides like `NEXUS_LOG_FORMAT`. The system MUST NOT fail if `nexus.env` is absent — all defaults MUST work without it.

#### Scenario: nexus.env exists

- GIVEN `config/nexus.env` exists with `NEXUS_LOG_FORMAT=json`
- WHEN `env.sh` is sourced
- THEN `NEXUS_LOG_FORMAT` MUST be set to `json`
- AND the system SHALL use JSON log format thereafter

#### Scenario: nexus.env absent

- GIVEN `config/nexus.env` does NOT exist
- WHEN `env.sh` is sourced
- THEN no error MUST occur
- AND all defaults MUST remain in effect
