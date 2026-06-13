# Delta for nexus-cli

## ADDED Requirements

### Requirement: Create subcommand

The system MUST add a `create` case branch to the subcommand router in `core/nexus.sh`. The branch MUST source the project scaffolding library via `nexus_require project-scaffolding`, verify npx availability, and delegate to `nxai create <type> <name>` handling. The `create` subcommand SHALL NOT call `show_banner()`.

#### Scenario: Create subcommand dispatches correctly

- GIVEN the user runs `nxai create vite my-app`
- WHEN the case branch matches `create`
- THEN it MUST source `lib/nexus-project-scaffolding.sh` via `nexus_require`
- AND delegate the arguments `vite my-app` to the scaffolding handler
- AND NOT call `show_banner()`

#### Scenario: Create without arguments shows usage

- GIVEN the user runs `nxai create` with no arguments
- WHEN no type or name is provided
- THEN the system MUST print usage: `nxai create <tipo> <nombre>`
- AND show available types
- AND exit with code 1
