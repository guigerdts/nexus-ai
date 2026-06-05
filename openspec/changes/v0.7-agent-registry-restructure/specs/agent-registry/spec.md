# Delta for agent-registry

## MODIFIED Requirements

### Requirement: Required agent files

Each agent directory MUST contain `metadata.sh` (8 fields), `install.sh`, `test.sh`, and `README.md`. The `metadata.sh` MUST export 8 fields: AGENT_NAME, AGENT_VERSION, AGENT_DESC, AGENT_URL, AGENT_TIER, AGENT_CATEGORY, AGENT_METHOD, AGENT_BINARY.
(Previously: 6 fields, no AGENT_CATEGORY or AGENT_BINARY)

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

### Requirement: Stub modules for uncertain install

Agents whose install method is "stub" MUST NOT block install. Their `install.sh` MUST print clear manual instructions with official URL and exit with code 0. `test.sh` MUST verify the binary exists via `command -v`.
(Previously: AGENT_METHOD="unknown" triggered stub; now AGENT_METHOD="stub". test.sh verification added.)

#### Scenario: Stub agent install

- GIVEN an agent has `AGENT_METHOD="stub"` in metadata.sh
- WHEN `nexus install --<agent>` is executed
- THEN the system MUST print manual instructions with official URL
- AND exit with code 0 without modifying the system

## ADDED Requirements

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
