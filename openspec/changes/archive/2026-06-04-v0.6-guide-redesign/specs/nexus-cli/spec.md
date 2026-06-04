# Delta for nexus-cli

## MODIFIED Requirements

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
