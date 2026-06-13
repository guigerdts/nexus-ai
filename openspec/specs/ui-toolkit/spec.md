# ui-toolkit Specification

## Purpose

Reusable shell UI component library with gum-backed implementations and native bash fallbacks. All functions respect terminal TTY detection for ANSI safety.

## Requirements

### Requirement: Spinner animation

The system MUST provide `ui_spinner_start <message>` and `ui_spinner_stop` for indeterminate progress indication. When gum is available, MUST delegate to `gum spin`. Otherwise, MUST implement an animated spinner using `printf` with rotating glyphs in a background subshell.

#### Scenario: Spinner with gum

- GIVEN `NEXUS_GUM_AVAILABLE` is true
- WHEN `ui_spinner_start "Loading"` is called
- THEN it MUST run `gum spin --spinner dot --title "Loading"` under the hood
- AND block until `ui_spinner_stop` is called

#### Scenario: Spinner fallback without gum

- GIVEN `NEXUS_GUM_AVAILABLE` is false AND `[ -t 1 ]` is true
- WHEN `ui_spinner_start "Loading"` is called
- THEN a rotating character (-\|/) MUST animate in place
- AND NOT leave visible artifacts on stop

#### Scenario: Spinner suppressed on non-TTY

- GIVEN `[ -t 1 ]` is false (piped or redirected output)
- WHEN `ui_spinner_start` is called
- THEN no animation glyphs SHALL be emitted
- AND the message MAY be printed once

### Requirement: Progress bar

The system MUST provide `ui_progress_bar <current> <total>` that renders a proportional bar. Width SHALL adapt to terminal columns. On non-TTY, SHALL output `[current/total]` text instead.

#### Scenario: TTY renders bar

- GIVEN `[ -t 1 ]` is true and terminal is 80 columns
- WHEN `ui_progress_bar 5 10` is called
- THEN a `[=====     ]` style bar MUST render at ~80% of terminal width
- AND overwrite the same line on next call

#### Scenario: Non-TTY output

- GIVEN `[ -t 1 ]` is false
- WHEN `ui_progress_bar 5 10` is called
- THEN the output MUST be `[5/10]` without bar characters

### Requirement: Table renderer

The system MUST provide `ui_table <header_row> [data_rows...]` that renders aligned columns. When gum is available, MUST delegate to `gum table`. Otherwise, MUST render using `column -t -s $'\t'`.

#### Scenario: Table with gum

- GIVEN `NEXUS_GUM_AVAILABLE` is true
- WHEN `ui_table` is called with 3 columns of data
- THEN it MUST pass data as tab-separated lines to `gum table`

#### Scenario: Table fallback

- GIVEN `NEXUS_GUM_AVAILABLE` is false
- WHEN `ui_table` is called with the same data
- THEN it MUST pipe tab-separated lines to `column -t -s $'\t'`

### Requirement: Box and confirm

The system MUST provide `ui_box <text>` for bordered display and `ui_confirm <prompt>` for yes/no prompts. `ui_box` uses `gum style --border rounded` when available, `printf` box otherwise. `ui_confirm` uses `gum confirm` when available, `read -p` fallback.

#### Scenario: Confirm yes with gum

- GIVEN `NEXUS_GUM_AVAILABLE` is true
- WHEN `ui_confirm "Continue?"` is called and user presses y
- THEN it MUST return exit code 0

#### Scenario: Confirm fallback no gum

- GIVEN `NEXUS_GUM_AVAILABLE` is false
- WHEN `ui_confirm "Continue?"` is called and user presses n
- THEN it MUST return exit code 1
- AND the prompt MUST show `Continue? [y/N]`
