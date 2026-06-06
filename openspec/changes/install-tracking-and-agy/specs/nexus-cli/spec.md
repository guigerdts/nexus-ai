# Delta for nexus-cli

## MODIFIED Requirements

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
