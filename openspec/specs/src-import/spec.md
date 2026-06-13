# src-import Specification

## Purpose

Centralized sourcing system with `declare -A` redeclaration guards. Eliminates duplicate sourcing and guarantees env var availability before dependent libs load.

## Requirements

### Requirement: `nexus_require()` guard

The system MUST provide `nexus_require()` as the single entry point for sourcing NEXUS AI library files. The function MUST register each sourced file in a `declare -A NEXUS_SOURCED` associative array and SHALL return immediately if the file is already sourced (redeclaration guard).

#### Scenario: First source loads the file

- GIVEN a library file has NOT been sourced yet
- WHEN `nexus_require env` is called
- THEN the file MUST be sourced
- AND `NEXUS_SOURCED[env]` MUST be set to 1

#### Scenario: Duplicate source is no-op

- GIVEN `nexus_require env` has already been called
- WHEN `nexus_require env` is called again
- THEN the function MUST NOT source the file again
- AND MUST return immediately

#### Scenario: Missing file raises error

- GIVEN a library file does not exist at `$NEXUS_ROOT/lib/<name>.sh`
- WHEN `nexus_require nonexistent` is called
- THEN the system MUST print an error message to stderr
- AND exit with code 1

### Requirement: NEXUS_ROOT auto-detection

The system MUST auto-detect `NEXUS_ROOT` from `BASH_SOURCE[0]` resolution when loaded for the first time. If `NEXUS_ROOT` is already set, it MUST NOT be overwritten.

#### Scenario: NEXUS_ROOT unset at load

- GIVEN `NEXUS_ROOT` is not set
- WHEN `nexus-src.sh` is sourced
- THEN `NEXUS_ROOT` MUST be derived from `BASH_SOURCE[0]` directory traversal
- AND export `NEXUS_ROOT` before returning

#### Scenario: NEXUS_ROOT already set

- GIVEN `NEXUS_ROOT` is already exported
- WHEN `nexus-src.sh` is sourced
- THEN the existing value MUST be preserved
- AND NOT be overwritten

### Requirement: Environment load guarantee

The system MUST load `config/nexus.env` (or `config/env.sh`) before any library that depends on `NEXUS_COLOR_*` or `NEXUS_GUM_AVAILABLE` variables. `nexus_require env` SHALL be called implicitly by `nexus_require` when it detects a dependent library is being loaded first.

#### Scenario: Env loaded before color-dependent lib

- GIVEN `nexus_require ui` is called and `env` has not been loaded
- WHEN the function checks the dependency chain
- THEN it MUST call `nexus_require env` first
- AND source the requested lib only after env is confirmed loaded

#### Scenario: Env already loaded skips implicit call

- GIVEN `nexus_require env` was already called
- WHEN any other `nexus_require` call runs
- THEN no implicit env reload SHALL occur
