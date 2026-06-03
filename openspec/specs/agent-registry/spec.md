# agent-registry Specification

## Purpose

Directory-based agent registry. Each agent lives in `modules/<name>/` with bash-sourced metadata. Any valid directory under `modules/` is automatically recognized as a registered agent. The registry index (`config/agents.registry.sh`) is auto-built from the filesystem.

## Requirements

### Requirement: Directory-based agent discovery

The system MUST recognize any directory under `$NEXUS_ROOT/modules/` as a registered agent. No central manifest SHALL be required for basic registration.

#### Scenario: Directory exists = agent registered

- GIVEN `modules/opencode/` exists with a valid `metadata.sh`
- WHEN the registry index is rebuilt
- THEN `opencode` MUST appear in the agent list
- AND its metadata MUST be available via `source`

#### Scenario: Empty modules directory

- GIVEN `modules/` exists but contains no subdirectories
- WHEN `nexus list` is executed
- THEN the system MUST show "No hay agentes registrados"
- AND NOT error

### Requirement: Required agent files

Each agent directory MUST contain at minimum `metadata.sh` (name, version, description, url, tier, install method), `install.sh` (install logic), `test.sh` (PASS/FAIL verification), and `README.md` (usage instructions in Spanish).

#### Scenario: Complete agent skeleton

- GIVEN `nexus agent add myagent <url>` is run
- WHEN the skeleton is created
- THEN `modules/myagent/` MUST contain all four required files
- AND `metadata.sh` MUST export AGENT_NAME, AGENT_VERSION, AGENT_DESC, AGENT_URL, AGENT_TIER, AGENT_METHOD

#### Scenario: Missing metadata file

- GIVEN a directory in `modules/` has no `metadata.sh`
- WHEN the registry index is built
- THEN the agent MUST be listed with status "INCOMPLETO"
- AND the user MUST be warned

### Requirement: Registry index auto-build

The system MUST auto-build an associative array in `config/agents.registry.sh` by iterating `modules/*/` and sourcing each `metadata.sh`.

#### Scenario: Index syncs with filesystem

- GIVEN a new agent directory is added to `modules/`
- WHEN `config/agents.registry.sh` is sourced
- THEN the new agent MUST appear in the registry array
- AND its metadata MUST be accessible

### Requirement: Stub modules for uncertain install

Agents whose install method is unknown MUST NOT block the install workflow. Their `install.sh` MUST print manual instructions and exit successfully.

#### Scenario: Stub agent install

- GIVEN an agent has `AGENT_METHOD="unknown"` in metadata.sh
- WHEN `nexus install --<agent>` is executed
- THEN the system MUST print manual installation instructions
- AND exit with code 0 without modifying the system
