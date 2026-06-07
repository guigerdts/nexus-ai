# guide-command Specification

## Purpose

Categorized module guide for exploring NEXUS AI tools by domain. Supports full listing, single-category filter, and interactive Rich TUI. Pure bash output for basic use, Python/Rich for interactive mode.

## Requirements

### Requirement: Guide all categories

The system MUST display all 9 categories (ai, editor, shell, tools, language, db, node, ui, automation) with their tools when `nxai guide` is invoked. Output MUST use ANSI cyan headers with `═` separators, `printf` column alignment, yellow-highlighted install commands, gray muted stub text, and dimmed uninstall lines.

#### Scenario: Guide shows full catalog with visual hierarchy

- GIVEN the user runs `nxai guide`
- THEN all 9 categories MUST appear with cyan `═` header and aligned columns
- AND each installed tool MUST show a yellow install command
- AND each stub tool MUST show gray `(stub)` text
- AND uninstall lines MUST render in dimmed style

#### Scenario: Empty category displays correctly

- GIVEN a category exists with zero tools
- WHEN `nxai guide` runs
- THEN that category MUST show "No tools available" in the same format

### Requirement: Guide single category

The system MUST filter to a single category when `nxai guide <category>` is invoked. Output MUST apply the same ANSI color scheme and alignment as the full guide.

#### Scenario: Valid category match with visual styling

- GIVEN the category `editor` exists with tool entries
- WHEN `nxai guide editor` runs
- THEN only the `editor` category MUST display with cyan header, aligned columns, and color-coded commands

#### Scenario: Invalid category name

- GIVEN the user runs `nxai guide nonexistent`
- THEN the system MUST print an error listing available categories
- AND exit with code 1

### Requirement: Interactive guide

The system SHOULD launch a Rich TUI when `nxai guide --interactive` is invoked, with fallback to bash list if Rich is unavailable. Each category MUST wrap in a Rich Panel with cyan border, tools MUST display INSTALADO/NO INSTALADO, install MUST prompt via Confirm.ask, stub tools MUST show gray `(stub)`.

#### Scenario: All categories in Rich Panel layout

- GIVEN Rich is available
- WHEN `nxai guide --interactive` displays all categories
- THEN each category MUST render in a Panel with `border_style="cyan"` and `box.DOUBLE`
- AND each tool MUST show INSTALADO or NO INSTALADO

#### Scenario: Single category selection by name or number

- GIVEN the user selects a category by name or number
- WHEN the selection is valid
- THEN a Rich Table with the category's tools MUST display

#### Scenario: Confirm.ask gates install

- GIVEN the user selects a tool for install
- WHEN the Confirm.ask appears
- THEN install executes only on confirmation
- AND returns to category selection on cancel

#### Scenario: Stub detection in interactive mode

- GIVEN a stub tool (AGENT_METHOD="stub") is selected
- THEN it MUST show gray `(stub)` and NO INSTALADO
- AND Confirm.ask MUST present if user attempts install

#### Scenario: Rich unavailable falls back

- GIVEN `python3 -c "from rich.console import Console"` fails
- WHEN `nxai guide --interactive` runs
- THEN output MUST match `nxai guide` bash output
- AND print notice that Rich is unavailable
