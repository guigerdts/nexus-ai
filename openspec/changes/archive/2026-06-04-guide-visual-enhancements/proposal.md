# Proposal: Guide Visual Enhancements

## Intent

The guide (`nxai guide`, `nxai guide --interactive`) works but has no visual hierarchy — plain echo headers in bash and no borders/panel structure in the Rich TUI make it hard to scan categories quickly. This change adds ANSI-colored headers with separators, Rich Panel wrappers, column alignment, and an interactive install flow with confirmation.

## Scope

### In Scope
1. Bash `lib/nexus-guide.sh`: refactor 8 hardcoded category blocks into `_print_category()` with cyan `═` headers, `printf` alignment, yellow install commands, gray stubs, and muted uninstall line
2. Rich `tui/guide.py`: wrap each category in `Panel` with `border_style="cyan"` and `box.DOUBLE`, add `build_category_table()` factory with Estado column, use `Confirm.ask` before install in interactive mode, use Rich Table for tool list in interactive menu
3. `show_guide_rich()`: use `echo -e` for `[INFO]` tag with yellow coloring

### Out of Scope
- New categories or tool entries
- Dashboard TUI changes
- Help screen redesign

## Capabilities

### New Capabilities
None — all changes are visual refinements to existing guide behavior.

### Modified Capabilities
- **guide-command**: visual styling of bash output (ANSI colors, `printf` alignment, color-coded commands) and Rich TUI output (Panel wrappers, border styling, Estado column, Confirm.ask interactive flow)

## Approach

1. **Bash**: Extract repeated category blocks into `_print_category()` with ANSI color constants, `printf` column format, and a `has_uninstall` flag for the muted uninstall line
2. **Rich**: Build a `build_category_table()` factory shared by single-category and all-categories views; wrap each table in a `Panel` with cyan double-border; add `Confirm.ask` gate before subprocess install
3. **Fallback**: Rich unavailability still falls back to bash guide per existing `guide-command` spec

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `lib/nexus-guide.sh` | Modified | Refactor to `_print_category()`, ANSI colors, printf alignment (+100 -91) |
| `tui/guide.py` | Modified | Panel wrappers, build_category_table(), Confirm.ask, interactive Rich Table (+79 -48) |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Rich not installed on Termux target | Low | Fallback to bash guide already exists |
| No shell test runner for bash refactor | High | Manual verification on device; visual diff review |
| Confirm.ask adds interactive step in CI | Low | Interactive mode is optional (`--interactive` flag only) |

## Rollback Plan

Revert `lib/nexus-guide.sh` and `tui/guide.py` to their previous state via `git checkout HEAD~1 -- lib/nexus-guide.sh tui/guide.py` then commit. The bash refactor changes structure but not external behavior, so rollback is safe.

## Dependencies

- Rich ≥ 13.0.0 (already installed, used by existing guide)
- python3 available (confirmed)

## Success Criteria

- [ ] `nxai guide` shows cyan headers with `═` separators and aligned columns
- [ ] `nxai guide editor` shows single category with color-coded commands
- [ ] `nxai guide --interactive` wraps each category in a cyan-bordered Panel
- [ ] Interactive install prompts with `Confirm.ask` before executing
- [ ] Stale categories (db, ui, automation) show `NO INSTALADO` / gray `(stub)` correctly
