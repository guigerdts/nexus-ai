# dashboard-tui Specification

## Purpose

Interactive Textual TUI for NEXUS AI. Unifies system monitoring and agent management (install/remove) in a 4-panel terminal dashboard. Spanish, ASCII-only.

## Requirements

### Requirement: TUI invocation

The system MUST launch a Textual App when invoked via `nxai dashboard` or `nxai ui`.

#### Scenario: Launch with textual installed

- GIVEN `textual` is installed in the Python environment
- WHEN the user runs `nxai dashboard`
- THEN a Textual App MUST render with 4 panels visible
- AND all text MUST be in Spanish, ASCII-only

#### Scenario: Launch without textual

- GIVEN `textual` is NOT installed
- WHEN the user runs `nxai dashboard`
- THEN the system MUST print "pip install textual" and exit code 1

### Requirement: Visual theme

The TUI MUST use cyan `#00BCD4` as primary, background `#1a1a2e`, and white text. MUST NOT use emoji or non-ASCII Unicode. All strings in Spanish.

#### Scenario: Theme applied

- GIVEN the TUI is running
- THEN the header, footer, and panels MUST use `#00BCD4` accent
- AND background MUST be `#1a1a2e`
- AND no emoji or characters outside ASCII 32-126 MUST appear

### Requirement: Quick Guide panel

The panel MUST display: "Que es NEXUS AI" description, install command, 2 uninstall commands, and a table of 6 commands (install, remove, list, status, agent, help).

#### Scenario: Guide content verified

- GIVEN the TUI is running
- WHEN the Quick Guide panel renders
- THEN it MUST show `curl -fsSL https://raw.githubusercontent.com/guigerdts/nexus-ai/main/install.sh | bash`
- AND `rm -rf ~/.nexus` and `rm -f ~/.local/bin/nxai`
- AND a 6-row command table

### Requirement: Agent panel with Install/Remove

The Agent Panel MUST list agents in a DataTable (Nombre, Tier, Estado, Descripcion). Each row MUST have Install and Remove buttons. Agent status from `shutil.which(AGENT_BINARY)` reading `modules/*/metadata.sh`.

#### Scenario: Agents listed with status

- GIVEN agents are registered in `modules/*/metadata.sh`
- WHEN the Agent Panel renders
- THEN all 12 agents MUST appear with Name, Tier, Status, Description
- AND status MUST show INSTALADO (cyan) or NO INSTALADO (yellow)

#### Scenario: Install button

- GIVEN an agent with NO INSTALADO status
- WHEN the user presses Install
- THEN `subprocess.run` MUST execute `{nexus_root}/bin/nxai install --{agent}`

#### Scenario: Remove button

- GIVEN an agent with INSTALADO status
- WHEN the user presses Remove
- THEN `subprocess.run` MUST execute `{nexus_root}/bin/nxai remove {agent}`

### Requirement: System Monitor panel

The panel MUST show: RAM from `/proc/meminfo`, storage from `shutil.disk_usage()`, `NEXUS_ENV`, architecture, and python/zsh/git versions. MUST NOT use psutil.

#### Scenario: System data displayed

- GIVEN the TUI is running
- WHEN the System Monitor panel renders
- THEN it MUST show RAM total/used, disk total/used
- AND NEXUS_ENV, arch, and Python/Zsh/Git versions
- AND NOT depend on psutil

### Requirement: History panel

The panel MUST show the last 20 entries from `logs/agents.log` (pipe-separated: date | action | agent | version). MUST NOT read `logs/nexus.log`.

#### Scenario: History with entries

- GIVEN `logs/agents.log` exists with pipe-separated entries
- WHEN the History panel renders
- THEN it MUST display up to 20 most recent lines
- AND each row MUST show date, action, agent, and version

#### Scenario: Empty log

- GIVEN `logs/agents.log` is empty or missing
- WHEN the History panel renders
- THEN it MUST show "No hay historial de operaciones"
