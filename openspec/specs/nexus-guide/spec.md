# Nexus Guide Specification

## Purpose

Visual presentation layer for `nxai guide` output. Renders a dynamic ASCII art title (figlet) and wraps each category table in a neon magenta box, matching the style established in `core/nexus.sh show_help()`. All existing content, colors, and layout inside the category tables remain unchanged — only the outer wrapping is added.

## Requirements

### Requirement: Dynamic Title Rendering

The system MUST detect figlet availability at runtime via `command -v figlet`. When available, it MUST attempt compact fonts in order: `figlet -f small "NEXUS AI GUIA"`, then `figlet -f mini "..."`, then default figlet font. It MUST measure the widest line of figlet output against `_inner` (terminal-derived content width). If figlet output exceeds `_inner`, the system MUST fall back to uppercase text with padding. The fallback MUST render `NEXUS AI GUIA POR CATEGORIAS` in uppercase with the current separator style, plus one extra blank line above and below. The title MUST be cyan (ANSI 96). The title MUST NOT appear inside the magenta box.

#### Scenario: Figlet available, compact font fits

- GIVEN figlet is installed AND `figlet -f small "NEXUS AI GUIA"` produces output ≤ `_inner` width
- WHEN `show_guide()` runs
- THEN the figlet output renders in cyan above all category boxes
- AND no fallback text is used

#### Scenario: Figlet available but font too wide

- GIVEN figlet is installed AND all compact fonts produce output > `_inner` width
- WHEN `show_guide()` runs
- THEN the system renders `NEXUS AI GUIA POR CATEGORIAS` in uppercase with separator lines and extra blank lines above/below
- AND the output is cyan

#### Scenario: Figlet not available

- GIVEN `command -v figlet` fails
- WHEN `show_guide()` runs
- THEN the system renders the uppercase fallback text in cyan

### Requirement: Category Box Wrapping

Each category output from `_print_category()` MUST be wrapped in a neon magenta box using characters ╭ ╮ ╰ ╯ ─ │ with ANSI color 38;5;201. The system MUST capture all current category output (header, separator, column headers, tool rows, uninstall line) before wrapping. Internal cyan headers and existing ANSI colors MUST remain unchanged inside the box. Box width MUST clamp: `_bw = _cols - 2`, minimum 78, maximum 86. The system MUST reuse the same strip-ansi / visible-length / padding logic from `core/nexus.sh` to align content inside the box. If terminal width < 80, the system SHOULD still render using the floor clamp.

#### Scenario: Category with normal width content

- GIVEN all category lines are shorter than `_inner`
- WHEN `_print_category()` renders
- THEN each category appears inside a neon magenta box with proper ╭─╮││╰─╯ borders
- AND all ANSI colors (cyan header, gray stubs, yellow install) are preserved inside the box

#### Scenario: Category with content near the width limit

- GIVEN a category line (e.g., `mariadb` entry with longest install string) approaches 81 visible characters
- WHEN `_print_category()` renders
- THEN the line fits without truncation at the right box edge (`_inner` max 84 — 3 spare chars)

#### Scenario: tput cols unavailable (non-TTY)

- GIVEN `tput cols 2>/dev/null` fails AND stdout is not a TTY
- WHEN `_print_category()` renders
- THEN the system uses `_cols=80` as fallback
- AND the box renders at `_bw=78` / `_inner=76`

### Requirement: Reusable Box-Drawing Helper

The box-drawing logic (terminal width detection, strip-ansi measurement, padding loop, border character rendering) SHOULD be extracted as a reusable shell function. The helper MUST accept arbitrary multi-line content and render it wrapped in the box. The helper MUST handle ANSI-colored content: strip ANSI codes for measurement but preserve them in the output. The helper MUST be usable by both `show_help()` and `_print_category()`.

#### Scenario: Helper wraps arbitrary content

- GIVEN a multi-line string with mixed ANSI colors and a terminal width value
- WHEN passed to the box-drawing helper
- THEN each line renders padded between ││ borders with proper ╭─╮ top and ╰─╯ bottom

#### Scenario: ANSI codes do not distort measurements

- GIVEN a line with embedded ANSI escape sequences (e.g., `\033[96mheader\033[0m`)
- WHEN measured for padding
- THEN `visible` length equals the plain-text length (ANSI codes stripped)
- AND padding compensates so the visible text aligns correctly within the box
