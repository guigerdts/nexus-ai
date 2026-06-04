# Delta for guide-command

## MODIFIED Requirements

### Requirement: Guide all categories

The system MUST display all 8 categories (ai, editor, shell, tools, language, db, ui, automation) with their tools and descriptions when `nxai guide` is invoked without arguments. Output MUST use ANSI cyan headers with `═` separators, `printf` column alignment, yellow-highlighted install commands, gray muted stub lines, and a dimmed uninstall line.
(Previously: plain output with printf and ANSI, no specific color scheme)

#### Scenario: Guide shows full catalog with visual hierarchy

- GIVEN the user runs `nxai guide`
- THEN all 8 categories MUST appear with a cyan `═` header separator and aligned `printf` columns
- AND each installed tool MUST show a yellow-highlighted install command
- AND each stub category (db, ui, automation) MUST show gray `(stub)` text
- AND any uninstall line MUST render in a dimmed style

#### Scenario: Empty category displays correctly

- GIVEN a category exists with zero tools
- WHEN `nxai guide` runs
- THEN that category MUST show "No tools available" in the same visual format

### Requirement: Guide single category

The system MUST filter to a single category when `nxai guide <category>` is invoked. Output MUST apply the same ANSI color scheme and alignment as the full guide.
(Previously: filtered display without specified visual treatment)

#### Scenario: Valid category match with visual styling

- GIVEN the category `editor` exists with tool entries
- WHEN `nxai guide editor` runs
- THEN only the `editor` category MUST display with cyan header, aligned columns, and color-coded commands

#### Scenario: Invalid category name

- GIVEN the user runs `nxai guide nonexistent`
- THEN the system MUST print an error listing available categories
- AND exit with code 1

### Requirement: Interactive guide

The system SHOULD launch a Rich TUI when `nxai guide --interactive` is invoked, with fallback to bash category list if Rich is unavailable. In interactive mode, each category MUST be wrapped in a Rich Panel with cyan border, tools MUST display with INSTALADO/NO INSTALADO status, install MUST prompt via Confirm.ask, and stub detection MUST show gray `(stub)`.
(Previously: Rich menu for browsing without Panel wrappers, status column, or confirmation gate)

#### Scenario: All categories in Rich Panel layout

- GIVEN Rich is available
- WHEN `nxai guide --interactive` displays all categories
- THEN each category MUST render inside a Panel with `border_style="cyan"` and `box.DOUBLE`
- AND each tool row MUST show INSTALADO or NO INSTALADO in the status column

#### Scenario: Single category selection by name or number

- GIVEN the user selects a category by name or number in the interactive menu
- WHEN the selection is valid
- THEN a Rich Table with the category's tools MUST display inside a cyan-bordered Panel

#### Scenario: Confirm.ask gates install

- GIVEN the user selects a tool for install in interactive mode
- WHEN the Confirm.ask prompt appears
- THEN the install command MUST execute only if the user confirms
- AND MUST NOT execute if the user declines
- AND the menu MUST return to category selection after cancel

#### Scenario: Stub detection in interactive mode

- GIVEN a stub category (db, ui, automation) is selected in interactive mode
- THEN its tools MUST show gray `(stub)` and NO INSTALADO status
- AND Confirm.ask MUST still be presented if the user attempts install

#### Scenario: Rich unavailable falls back

- GIVEN `python3 -c "from rich.console import Console"` fails
- WHEN `nxai guide --interactive` runs
- THEN the system MUST fall back to bash guide output matching `nxai guide`
- AND print a notice that Rich is unavailable

## REMOVED Requirements

None — all existing requirements remain, only their visual behavior is enhanced.
