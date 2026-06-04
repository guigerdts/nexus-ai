# guide-command Specification

## Purpose

Categorized module guide for exploring NEXUS AI tools by domain. Supports full listing, single-category filter, and interactive Rich TUI. Pure bash output for basic use, Python/Rich for interactive mode.

## Requirements

### Requirement: Guide all categories

The system MUST display all 8 categories (ai, editor, shell, tools, language, db, ui, automation) with their tools and descriptions when `nxai guide` is invoked without arguments. Output MUST use printf and ANSI, no external tools.

#### Scenario: Guide shows full catalog

- GIVEN the user runs `nxai guide`
- THEN all 8 categories MUST appear with name, description, and tool list
- AND each tool MUST show install/uninstall status via NEXUS_AGENTS array

#### Scenario: Empty category displays correctly

- GIVEN a category exists with zero tools
- WHEN `nxai guide` runs
- THEN that category MUST show an empty state ("No tools available")

### Requirement: Guide single category

The system MUST filter to a single category when `nxai guide <category>` is invoked.

#### Scenario: Valid category match

- GIVEN the category `ai` exists with tool entries
- WHEN `nxai guide ai` runs
- THEN only the `ai` category MUST display with its tools
- AND each tool MUST show install/uninstall status

#### Scenario: Invalid category name

- GIVEN the user runs `nxai guide nonexistent`
- THEN the system MUST print an error listing available categories
- AND exit with code 1

### Requirement: Interactive guide

The system SHOULD launch a Rich TUI when `nxai guide --interactive` is invoked, with fallback to bash category list if Rich is unavailable.

#### Scenario: Rich available launches TUI

- GIVEN `python3 -c "from rich.console import Console"` succeeds
- WHEN `nxai guide --interactive` runs
- THEN a Rich interactive menu MUST display categories for browsing

#### Scenario: Rich unavailable falls back

- GIVEN `python3 -c "from rich.console import Console"` fails
- WHEN `nxai guide --interactive` runs
- THEN the system MUST fall back to bash guide output matching `nxai guide`
- AND print a notice that Rich is unavailable
