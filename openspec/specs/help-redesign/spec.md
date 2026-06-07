# help-redesign Specification

## Purpose

Professional help output for NEXUS AI CLI. Replaces legacy heredoc with formatted banner, "Usage:" section, "Available Commands:" list, "Quick Start:" examples, and "Module Targets:" categories with tools. Pure bash with printf + ANSI, zero external dependencies.

## Requirements

### Requirement: Professional help output

The system MUST display redesigned help when `nxai`, `nxai help`, or `nxai --help` is invoked. Output MUST include a NEXUS AI banner, "Usage:" section, "Available Commands:" grouped list, "Quick Start:" examples, and "Module Targets:" by category.

#### Scenario: No arguments shows professional help

- GIVEN the user runs `nxai` with no arguments
- THEN the redesigned help MUST display with all sections
- AND exit with code 0

#### Scenario: All invocation forms are equivalent

- GIVEN the user runs `nxai help` and `nxai --help`
- THEN output MUST be identical to the no-arguments help

### Requirement: Zero external dependencies

Help output MUST use only printf and ANSI escape codes. No Rich, no gum, no external tools.

#### Scenario: Minimal execution environment

- GIVEN no Rich or gum packages are available
- WHEN `nxai help` runs
- THEN formatting MUST use printf and ANSI codes only
- AND MUST NOT fail due to missing dependencies

### Requirement: Module targets by category

The "Module Targets:" section MUST list tools grouped by their 9 categories (ai, editor, shell, tools, language, db, node, ui, automation).

#### Scenario: All categories represented

- GIVEN all agent metadata.sh files have AGENT_CATEGORY set
- WHEN `nxai help` runs
- THEN each of the 9 categories MUST appear with its tools
- AND categories with zero tools MUST show as empty

### Requirement: Quick Start examples

The help output MUST include at least 3 Quick Start examples showing common workflows.

#### Scenario: Examples present and readable

- GIVEN the user runs `nxai help`
- THEN at least 3 Quick Start examples MUST display
- AND each example MUST show a command with a brief Spanish description
