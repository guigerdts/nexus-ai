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

### Requirement: Install status detection

The system MUST determine agent install status using a two-layer check: (1) agent name present in `installed.txt` manifest, (2) agent binary found via `command -v`. The status MUST be one of:

- **INSTALADO**: name found in manifest AND binary found in PATH
- **EXTERNO**: name NOT in manifest but binary found in PATH
- **NO INSTALADO**: neither manifest nor PATH

#### Scenario: Manifest-tracked agent shows INSTALADO

- GIVEN agent name exists in `installed.txt`
- AND binary is present in PATH
- WHEN status is checked
- THEN the agent MUST be INSTALADO

#### Scenario: PATH-only agent shows EXTERNO

- GIVEN agent name does NOT exist in `installed.txt`
- BUT binary IS present in PATH
- WHEN status is checked
- THEN the agent MUST be EXTERNO

#### Scenario: Neither manifest nor PATH shows NO INSTALADO

- GIVEN agent name does NOT exist in `installed.txt`
- AND binary is NOT found in PATH
- WHEN status is checked
- THEN the agent MUST be NO INSTALADO

#### Scenario: Stale manifest entry without binary

- GIVEN agent name exists in `installed.txt`
- BUT binary is NOT present in PATH
- WHEN status is checked
- THEN the agent MUST be NO INSTALADO

### Requirement: Required agent files

Each agent directory MUST contain `metadata.sh` (8 fields), `install.sh`, `test.sh`, and `README.md`. The `metadata.sh` MUST export 8 fields: AGENT_NAME, AGENT_VERSION, AGENT_DESC, AGENT_URL, AGENT_TIER, AGENT_CATEGORY, AGENT_METHOD, AGENT_BINARY.

#### Scenario: Complete agent skeleton

- GIVEN `nexus agent add myagent <url>` is run
- WHEN the skeleton is created
- THEN `modules/myagent/` MUST contain all four required files
- AND `metadata.sh` MUST export all 8 fields

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

Agents whose install method is "stub" MUST NOT block install. Their `install.sh` MUST print clear manual instructions with official URL and exit with code 0. `test.sh` MUST verify the binary exists via `command -v`.

#### Scenario: Stub agent install

- GIVEN an agent has `AGENT_METHOD="stub"` in metadata.sh
- WHEN `nexus install --<agent>` is executed
- THEN the system MUST print manual instructions with official URL
- AND exit with code 0 without modifying the system

### Requirement: Agent quality tiers

Agents MUST be classified as REAL or STUB via AGENT_METHOD. REAL agents (npm, pkg, curl, binary) MUST install via package manager or binary download — no source compilation, no Rust deps on ARM64, MUST be proven on Android ARM64. STUB agents MUST NOT show cryptic errors. `README.md` MUST include instructions for both Termux and proot-Ubuntu environments.

#### Scenario: REAL agent install succeeds

- GIVEN an agent with `AGENT_METHOD="pkg"` and proven ARM64 support
- WHEN `install.sh` runs on Termux ARM64
- THEN the binary MUST be installed and `test.sh` MUST pass

#### Scenario: STUB agent shows clear instructions

- GIVEN an agent with `AGENT_METHOD="stub"`
- WHEN `install.sh` runs
- THEN it MUST print official URL and manual commands
- AND MUST NOT show any error or crash
