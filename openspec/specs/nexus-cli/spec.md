# nexus-cli Specification

## Purpose

Main CLI entry point for NEXUS AI. Routes subcommands via case/esac from a single `core/nexus.sh` file, symlinked to `$NEXUS_ROOT/bin/nexus`. All output in Spanish, pure ASCII only.

## Requirements

### Requirement: Global entry point

The system MUST register a `nexus` command via a symlink at `$NEXUS_ROOT/bin/nexus` pointing to `core/nexus.sh`. Subcommand routing MUST use a `case/esac` block on `$1`.

#### Scenario: Symlink resolves to core script

- GIVEN `bin/nexus` exists as a symlink
- WHEN `readlink -f bin/nexus` is executed
- THEN it MUST resolve to `core/nexus.sh`

#### Scenario: Unknown subcommand exits with error

- GIVEN the user types `nexus unknowncommand`
- WHEN `$1` does not match any case branch
- THEN the system MUST print "Comando desconocido"
- AND show help before exiting with code 1

### Requirement: Help display

The system MUST show usage information when invoked with `help`, `--help`, or no arguments.

#### Scenario: No arguments shows help

- GIVEN the user runs `nexus` with no arguments
- WHEN the script receives an empty `$1`
- THEN it MUST print the help text with all subcommands
- AND exit with code 0

#### Scenario: Help flag is equivalent

- GIVEN the user runs `nexus --help`
- THEN output MUST match the no-arguments help exactly

### Requirement: Subcommand operations

The system MUST implement `install`, `remove`, `list`, `status`, `agent add`, `agent test`, `update`, and `help`.

#### Scenario: Install all agents

- GIVEN the registry has 11 agents defined
- WHEN `nexus install --all` is executed
- THEN each agent's install.sh MUST execute
- AND agents with unknown methods MUST be stubbed without blocking

#### Scenario: Agent add creates skeleton

- GIVEN the user runs `nexus agent add foo https://example.com/repo`
- WHEN the agent-add routine executes
- THEN `modules/foo/` MUST be created with metadata.sh, install.sh, test.sh, README.md

#### Scenario: List shows agent status

- GIVEN some agents are installed and some are not
- WHEN `nexus list` is executed
- THEN each agent MUST appear with [INSTALADO] or [NO INSTALADO] tag

#### Scenario: Agent test reports PASS/FAIL

- GIVEN a registered agent with a test.sh script
- WHEN `nexus agent test <name>` is executed
- THEN test.sh MUST run
- AND the system MUST print PASS or FAIL accordingly

#### Scenario: Status shows environment health

- GIVEN the environment is configured
- WHEN `nexus status` is executed
- THEN it MUST show NEXUS_ENV, NEXUS_ARCH, and agent count

#### Scenario: Remove uninstalls an agent

- GIVEN an agent is currently installed
- WHEN `nexus remove --<agent>` is executed
- THEN the agent MUST be removed from the system
- AND its entry in agents.log MUST be cleared

### Requirement: Pure ASCII and Spanish locale

All user-facing output MUST be in Spanish and MUST NOT contain Unicode blocks or emoji.

#### Scenario: Help text in Spanish

- GIVEN the user runs `nexus help`
- THEN all descriptive text MUST be in Spanish
- AND contain only printable ASCII characters (32-126)

#### Scenario: Error messages in Spanish

- GIVEN any subcommand encounters an error
- THEN the error message MUST be in Spanish
- AND MUST NOT contain emoji or Unicode symbols
