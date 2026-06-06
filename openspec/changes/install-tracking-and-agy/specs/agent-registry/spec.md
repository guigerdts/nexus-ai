# Delta for agent-registry

## ADDED Requirements

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
