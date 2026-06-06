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

The system MUST display redesigned professional help (per help-redesign spec) when invoked with `help`, `--help`, or no arguments.
(Previously: plain text heredoc with subcommand list)

#### Scenario: No arguments shows professional help

- GIVEN the user runs `nxai` with no arguments
- WHEN the script receives an empty `$1`
- THEN it MUST show the redesigned help with banner, usage, commands, quick start, and module targets
- AND exit with code 0

#### Scenario: Help flag is equivalent

- GIVEN the user runs `nxai --help`
- THEN output MUST match the no-arguments help exactly

### Requirement: Banner display

The system MUST call `show_banner()` before every command EXCEPT `dashboard` and `ui`. `show_help()` MUST include the banner as part of the redesigned help output. Banner MUST show NEXUS AI ASCII art in cyan with gray credits, using `gum style` when available or ANSI echo otherwise.
(Previously: banner excluded for help/--help/dashboard/ui)

#### Scenario: Banner on commands

- GIVEN user runs `nxai list`, `status`, `install`, `remove`, `agent add`, or `agent test`
- WHEN the command executes
- THEN `show_banner()` MUST display the ASCII art before any output

#### Scenario: Banner included in help

- GIVEN user runs `nxai help` or `nxai --help`
- WHEN `show_help()` executes
- THEN the banner MUST appear as part of the professional help output

#### Scenario: No banner on dashboard or ui

- GIVEN user runs `nxai dashboard` or `nxai ui`
- THEN output MUST NOT include the banner

### Requirement: Gum formatting with fallback

Each command MUST check `NEXUS_GUM_AVAILABLE` inline. When true, use gum features. When false, fall back to current ANSI output.
(Previously: list fallback showed only [INSTALADO]/[NO INSTALADO])

#### Scenario: install with gum confirm and spin

- GIVEN `NEXUS_GUM_AVAILABLE=true` and user runs `nxai install <agent>`
- WHEN banner shows
- THEN `gum confirm "Instalar <agent>?"` MUST prompt before install
- AND `gum spin` MUST show progress if confirmed, or abort on decline

#### Scenario: remove with mandatory gum confirm

- GIVEN `NEXUS_GUM_AVAILABLE=true` and user runs `nxai remove <agent>`
- WHEN banner shows
- THEN `gum confirm` MUST be mandatory before uninstalling
- AND `gum spin` MUST show progress during removal

#### Scenario: agent test with gum spin

- GIVEN `NEXUS_GUM_AVAILABLE=true` and user runs `nxai agent test <name>`
- WHEN banner shows
- THEN `gum spin` shows during test, output uses `gum style` green PASS / red FAIL

#### Scenario: list fallback without gum

- GIVEN `NEXUS_GUM_AVAILABLE=false`
- WHEN `nxai list` runs with banner
- THEN echo-based agent list with ANSI [INSTALADO]/[EXTERNO]/[NO INSTALADO] MUST display

### Requirement: Subcommand operations

The system MUST implement `install`, `remove`, `list`, `status`, `agent add`, `agent test`, `dashboard`, `ui`, `update`, and `help`. `dashboard`/`ui` MUST source `env.sh`, check `import textual`, and exec dashboard.py. Each command (except help/--help/dashboard/ui) MUST call `show_banner()`. When `NEXUS_GUM_AVAILABLE`, `list` uses `gum table` with three-state (INSTALADO/EXTERNO/NO INSTALADO) coloring, `status` uses `gum style`, `install`/`remove` use `gum confirm`+`gum spin`, `agent test` uses `gum spin`+styled PASS/FAIL — all with ANSI fallback.
(Previously: list had two-state INSTALADO/NO INSTALADO; install/remove did not sync manifest)

#### Scenario: Install all agents

- GIVEN the registry has 11 agents
- WHEN `nxai install --all` executes with banner
- THEN each agent's install.sh MUST execute
- AND agents with unknown methods MUST be stubbed without blocking

#### Scenario: Agent add creates skeleton

- GIVEN user runs `nxai agent add foo https://example.com/repo`
- WHEN agent-add runs with banner
- THEN `modules/foo/` MUST be created with metadata.sh, install.sh, test.sh, README.md

#### Scenario: List shows agent status with three states

- GIVEN some agents installed, some external, some not installed
- WHEN `nxai list` runs with banner
- THEN agents appear in gum table (gum available) or ANSI list (fallback)
- AND INSTALADO SHALL be green, EXTERNO SHALL be cyan, NO INSTALADO SHALL be yellow

#### Scenario: EXTERNO detection for PATH-only agents

- GIVEN an agent binary exists in PATH but is NOT in `installed.txt`
- WHEN `nxai list` runs with banner
- THEN the agent MUST show as EXTERNO with cyan color

#### Scenario: INSTALADO shows for manifest-tracked agents

- GIVEN an agent is listed in `installed.txt` and binary exists in PATH
- WHEN `nxai list` runs with banner
- THEN the agent MUST show as INSTALADO with green color

#### Scenario: Agent test reports PASS/FAIL

- GIVEN registered agent with test.sh
- WHEN `nxai agent test <name>` runs with banner
- THEN test.sh runs with gum spin (if available), PASS/FAIL styled or ANSI

#### Scenario: Status shows environment health

- GIVEN environment is configured
- WHEN `nxai status` runs with banner
- THEN it MUST show NEXUS_ENV, NEXUS_ARCH, and agent count
- AND format uses gum bordered panel or plain key:value

#### Scenario: Remove uninstalls an agent

- GIVEN an agent is installed
- WHEN `nxai remove <agent>` runs with banner
- THEN mandatory gum confirm (or prompt fallback) MUST precede removal
- AND entry in agents.log MUST be cleared
- AND agent MUST be removed from `installed.txt` manifest

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
