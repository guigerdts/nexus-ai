# motd-display Specification

## Purpose

Welcome screen shown on every terminal open — displays the NEXUS AI brand in ASCII art, framework version, agent count, date, and a random tip in Spanish.

## Requirements

### Requirement: Execution on terminal open

The MOTD MUST execute automatically when a new terminal session starts. It MUST be sourced from both `.zshrc` and `.bashrc`.

#### Scenario: Zsh terminal open

- GIVEN the user opens a Zsh terminal
- WHEN the shell initializes
- THEN `shell/motd.sh` MUST execute

#### Scenario: Bash terminal open

- GIVEN the user opens a Bash terminal
- WHEN the shell initializes
- THEN `shell/motd.sh` MUST execute

### Requirement: ASCII art branding

The system MUST display "NEXUS AI" in large block-style ASCII art, colored cyan.

#### Scenario: Full-width terminal

- GIVEN the terminal is at least 60 columns wide
- WHEN the MOTD runs
- THEN the ASCII art "NEXUS AI" MUST render in block style with cyan color

### Requirement: Dynamic information display

Below the logo, the MOTD MUST show: current NEXUS AI version, count of installed agents (directories in `modules/`), current date and time, and a random tip of the day from a Spanish-language array.

#### Scenario: Info display with agents

- GIVEN `modules/` contains 3 agent directories
- WHEN the MOTD runs
- THEN it MUST display `"3"` as the agent count
- AND show a Spanish tip from the configured array

#### Scenario: No agents installed

- GIVEN `modules/` is empty
- WHEN the MOTD runs
- THEN the agent count MUST display `"0"`
- AND NOT show an error

### Requirement: Performance

The MOTD MUST complete execution in under 100ms.

#### Scenario: Performance check

- GIVEN a terminal session starts
- WHEN the MOTD finishes executing
- THEN the elapsed time MUST be under 100ms

### Requirement: Compact mode

If the terminal width is under 60 columns, the system MUST show a compact single-line version of the logo instead of block ASCII art.

#### Scenario: Narrow terminal

- GIVEN the terminal width is 50 columns
- WHEN the MOTD runs
- THEN a single-line compact logo MUST be shown
- AND the block ASCII art MUST be skipped
