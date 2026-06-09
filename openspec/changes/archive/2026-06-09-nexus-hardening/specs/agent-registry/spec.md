# Delta for agent-registry

## MODIFIED Requirements

### Requirement: Registry index auto-build

The system MUST auto-build an associative array in `config/agents.registry.sh` by iterating `modules/*/` and sourcing each `metadata.sh`. BEFORE sourcing each metadata.sh, the system MUST unset ALL AGENT_* variables to prevent cross-module leakage.
(Previously: loop iterates modules but does not unset AGENT_* variables before source)

#### Scenario: Index syncs with filesystem

- GIVEN `modules/minimax-cli/metadata.sh` exports `AGENT_DEPRECATED=true`
- AND the next module in iteration does NOT export `AGENT_DEPRECATED`
- WHEN the registry loop processes the next module
- THEN `AGENT_DEPRECATED` MUST be unset before source
- AND the next module's metadata MUST NOT inherit `AGENT_DEPRECATED=true`

#### Scenario: Incomplete metadata is isolated

- GIVEN a metadata.sh that only sets `AGENT_NAME`
- WHEN the loop processes it
- THEN all other `AGENT_*` variables MUST be empty/unset
- AND NOT leak values from the previous module

## ADDED Requirements

### Requirement: Registry metadata cache

The system SHOULD generate a cache file at `logs/registry.cache.sh` containing serialized `AGENTS` and `AGENT_ORDER` arrays. The cache MUST be invalidated when any `metadata.sh` is newer than the cache. Source cache instead of iterating 80+ modules on every `nxai` invocation when cache is valid.

#### Scenario: Cache hit speeds up load

- GIVEN the cache file exists
- AND all `modules/*/metadata.sh` are older than the cache
- WHEN `agents.registry.sh` is sourced
- THEN the system MUST source the cache file
- AND NOT iterate all module directories

#### Scenario: Cache invalidated on metadata change

- GIVEN a module's `metadata.sh` is newer than the cache
- WHEN `agents.registry.sh` is sourced
- THEN the system MUST rebuild the cache from scratch
- AND update `logs/registry.cache.sh` with fresh data

#### Scenario: No cache exists (first run)

- GIVEN `logs/registry.cache.sh` does not exist
- WHEN `agents.registry.sh` is sourced
- THEN the system MUST fall back to full module iteration
- AND create the cache file after building the registry
