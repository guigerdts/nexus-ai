# Delta for nexus-cli

## ADDED Requirements

### Requirement: Banner display

The system MUST call `show_banner()` before every command EXCEPT `help`, `--help`, `dashboard`, `ui`. Banner MUST show NEXUS AI ASCII art in cyan with gray credits, using `gum style` when available or ANSI echo otherwise.

#### Scenario: Banner on commands

- GIVEN user runs `nxai list`, `status`, `install`, `remove`, `agent add`, or `agent test`
- WHEN the command executes
- THEN `show_banner()` MUST display the ASCII art before any output

#### Scenario: No banner on exceptions

- GIVEN user runs `nxai help`, `nxai --help`, `nxai dashboard`, or `nxai ui`
- THEN output MUST NOT include the banner

### Requirement: Gum formatting with fallback

Each command MUST check `NEXUS_GUM_AVAILABLE` inline. When true, use gum features. When false, fall back to current ANSI output.

#### Scenario: install with gum confirm and spin

- GIVEN `NEXUS_GUM_AVAILABLE=true` and user runs `nxai install --<agent>`
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
- THEN current echo-based agent list with ANSI [INSTALADO]/[NO INSTALADO] MUST display

## MODIFIED Requirements

### Requirement: Subcommand operations

The system MUST implement `install`, `remove`, `list`, `status`, `agent add`, `agent test`, `dashboard`, `ui`, `update`, and `help`. `dashboard`/`ui` MUST source `env.sh`, check `import textual`, and exec dashboard.py. Each command (except help/--help/dashboard/ui) MUST call `show_banner()`. When `GUM_AVAILABLE`, `list` uses `gum table`, `status` uses `gum style`, `install`/`remove` use `gum confirm`+`gum spin`, `agent test` uses `gum spin`+styled PASS/FAIL — all with ANSI fallback.
(Previously: no banner, no gum formatting, all output via raw echo/ANSI)

#### Scenario: Install all agents

- GIVEN the registry has 11 agents
- WHEN `nxai install --all` executes with banner
- THEN each agent's install.sh MUST execute, unknown methods stubbed

#### Scenario: Agent add creates skeleton

- GIVEN user runs `nxai agent add foo https://example.com/repo`
- WHEN agent-add runs with banner
- THEN `modules/foo/` MUST be created with metadata.sh, install.sh, test.sh, README.md

#### Scenario: List shows agent status

- GIVEN some agents installed, some not
- WHEN `nxai list` runs with banner
- THEN agents appear in gum table (gum available) or ANSI list (fallback)
- AND INSTALADO green, NO INSTALADO yellow

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

#### Scenario: Dashboard launches TUI (unchanged)

- GIVEN `textual` is importable
- WHEN `nxai dashboard` runs (no banner)
- THEN it MUST source env.sh, export NEXUS_ROOT, exec dashboard.py

#### Scenario: Dashboard --help shows usage (unchanged)

- GIVEN user runs `nxai dashboard --help`
- THEN usage info displays and exits with code 0

#### Scenario: UI alias is equivalent (unchanged)

- GIVEN user runs `nxai ui`
- THEN behavior MUST match `nxai dashboard`
