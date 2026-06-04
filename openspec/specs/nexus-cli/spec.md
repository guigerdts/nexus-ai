# nexus-cli Specification

## Purpose

Main CLI entry point for NEXUS AI. Routes subcommands via case/esac from a single `core/nexus.sh` file, symlinked to `$NEXUS_ROOT/bin/nxai` (relative symlink `../core/nexus.sh`). All output in Spanish, pure ASCII only.

## Requirements

### Requirement: Global entry point

The system MUST register a `nxai` command via a **relative** symlink at `$NEXUS_ROOT/bin/nxai` pointing to `../core/nexus.sh`. The symlink MUST be created with `ln -sf` (unconditional overwrite) in Step 8 of the installer. Subcommand routing MUST use a `case/esac` block on `$1`.

#### Scenario: Symlink resolves to core script

- GIVEN `bin/nxai` exists as a symlink
- WHEN `readlink bin/nxai` is executed
- THEN it MUST show `../core/nexus.sh` (relative path)
- AND `readlink -f bin/nxai` MUST resolve to `core/nexus.sh`

#### Scenario: Symlink recreated on re-install

- GIVEN the installer re-runs on an existing installation
- WHEN Step 8 executes
- THEN `ln -sf` MUST overwrite the existing symlink
- AND the target MUST remain the relative `../core/nexus.sh`
- AND the symlink MUST work correctly regardless of install directory (`--dir PATH`)

#### Scenario: Unknown subcommand exits with error

- GIVEN the user types `nxai unknowncommand`
- WHEN `$1` does not match any case branch
- THEN the system MUST print "Comando desconocido"
- AND show help before exiting with code 1

### Requirement: Help display

The system MUST show usage information when invoked with `help`, `--help`, or no arguments.

#### Scenario: No arguments shows help

- GIVEN the user runs `nxai` with no arguments
- WHEN the script receives an empty `$1`
- THEN it MUST print the help text with all subcommands
- AND exit with code 0

#### Scenario: Help flag is equivalent

- GIVEN the user runs `nxai --help`
- THEN output MUST match the no-arguments help exactly

### Requirement: Subcommand operations

The system MUST implement `install`, `remove`, `list`, `status`, `agent add`, `agent test`, `dashboard`, `ui`, `update`, and `help`. Commands `dashboard` and `ui` MUST source `config/env.sh`, export `NEXUS_ROOT`, check `python3 -c "import textual"`, and `exec python3 "$NEXUS_ROOT/tui/dashboard.py" "$@"`. They MUST support `--help` to show usage without launching the TUI.

#### Scenario: Install all agents

- GIVEN the registry has 11 agents defined
- WHEN `nxai install --all` is executed
- THEN each agent's install.sh MUST execute
- AND agents with unknown methods MUST be stubbed without blocking

#### Scenario: Agent add creates skeleton

- GIVEN the user runs `nxai agent add foo https://example.com/repo`
- WHEN the agent-add routine executes
- THEN `modules/foo/` MUST be created with metadata.sh, install.sh, test.sh, README.md

#### Scenario: List shows agent status

- GIVEN some agents are installed and some are not
- WHEN `nxai list` is executed
- THEN each agent MUST appear with [INSTALADO] or [NO INSTALADO] tag

#### Scenario: Agent test reports PASS/FAIL

- GIVEN a registered agent with a test.sh script
- WHEN `nxai agent test <name>` is executed
- THEN test.sh MUST run
- AND the system MUST print PASS or FAIL accordingly

#### Scenario: Status shows environment health

- GIVEN the environment is configured
- WHEN `nxai status` is executed
- THEN it MUST show NEXUS_ENV, NEXUS_ARCH, and agent count

#### Scenario: Remove uninstalls an agent

- GIVEN an agent is currently installed
- WHEN `nxai remove --<agent>` is executed
- THEN the agent MUST be removed from the system
- AND its entry in agents.log MUST be cleared

#### Scenario: Dashboard launches TUI

- GIVEN `textual` is installed and `python3 -c "import textual"` succeeds
- WHEN `nxai dashboard` is executed
- THEN the system MUST source config/env.sh
- AND export NEXUS_ROOT
- AND exec python3 "$NEXUS_ROOT/tui/dashboard.py" with any passed arguments

#### Scenario: Dashboard --help shows usage

- GIVEN the user runs `nxai dashboard --help`
- WHEN the `--help` flag is detected
- THEN the system MUST display usage information for the dashboard command
- AND exit with code 0 without launching the TUI

#### Scenario: UI alias is equivalent

- GIVEN the user runs `nxai ui`
- WHEN `ui` is matched as the command
- THEN the behavior MUST be identical to `nxai dashboard`

### Requirement: Dashboard dependency check

The system MUST verify that the `textual` Python package is importable before launching the dashboard TUI. If missing, MUST print installation instructions to stderr and exit with code 1.

#### Scenario: Textual available

- GIVEN `python3 -c "import textual"` succeeds
- WHEN the user runs `nxai dashboard` or `nxai ui`
- THEN the system MUST proceed to exec the TUI

#### Scenario: Textual missing

- GIVEN `python3 -c "import textual"` fails with ImportError
- WHEN the user runs `nxai dashboard` or `nxai ui`
- THEN the system MUST print "pip install textual" to stderr
- AND exit with code 1

### Requirement: Pure ASCII and Spanish locale

All user-facing output MUST be in Spanish and MUST NOT contain Unicode blocks or emoji.

#### Scenario: Help text in Spanish

- GIVEN the user runs `nxai help`
- THEN all descriptive text MUST be in Spanish
- AND contain only printable ASCII characters (32-126)

#### Scenario: Error messages in Spanish

- GIVEN any subcommand encounters an error
- THEN the error message MUST be in Spanish
- AND MUST NOT contain emoji or Unicode symbols
