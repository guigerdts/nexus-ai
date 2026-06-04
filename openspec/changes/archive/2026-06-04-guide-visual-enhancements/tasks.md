# Tasks: Guide Visual Enhancements

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | ~414 (155 bash + 259 python) |
| 400-line budget risk | Medium |
| Chained PRs recommended | No |
| Suggested split | Single PR |
| Delivery strategy | ask-always |
| Chain strategy | pending |

Decision needed before apply: Yes
Chained PRs recommended: No
Chain strategy: pending
400-line budget risk: Medium

### Suggested Work Units

| Unit | Goal | Likely PR | Notes |
|------|------|-----------|-------|
| 1 | Bash refactor: `_print_category()` + ANSI colors | PR 1 | Syntax-check verifiable |
| 2 | Rich tables, Panels, and interactive menu | PR 1 (same) | Both bash + python ship together |
| 3 | Verification of both layers | same PR | Included with each unit |

## Phase 1: Bash Refactor

- [ ] 1.1 Add ANSI color constants (`_CYAN`, `_YELLOW`, `_GRAY`, `_RESET`, `_SEP`) to `lib/nexus-guide.sh`
- [ ] 1.2 Create `_print_category()` with cyan ═ header, `printf` column alignment, color-coded commands, `has_uninstall` dimmed footer
- [ ] 1.3 Refactor all 8 `show_guide_category()` case blocks to use `_print_category()`

## Phase 2: Python/Rich Category Display

- [ ] 2.1 Create `build_category_table()` factory with columns: Herramienta, Descripcion, Estado, Comando
- [ ] 2.2 Implement `show_category()` — wrap table in `Panel(border_style="cyan", box=box.DOUBLE)`
- [ ] 2.3 Implement `show_all()` — iterate all categories calling `show_category()`
- [ ] 2.4 Add INSTALADO/NO INSTALADO status column with green/yellow colors and (stub) detection

## Phase 3: Interactive Menu

- [ ] 3.1 Wrap interactive menu intro heading with Panel
- [ ] 3.2 Build tool-selection table as Rich Table with #, Herramienta, Descripcion, Estado columns
- [ ] 3.3 Add `Confirm.ask` gate before subprocess install
- [ ] 3.4 Handle cancel (returns to category menu), stub (yellow notice), and install error paths

## Phase 4: Verification

- [ ] 4.1 `bash -n lib/nexus-guide.sh` — no syntax errors
- [ ] 4.2 `python3 -m py_compile tui/guide.py` — no syntax errors
- [ ] 4.3 `nxai guide` — verify cyan ═ headers, `printf` alignment, yellow commands, gray stubs
- [ ] 4.4 `nxai guide <cat>` — verify single category with same styling
- [ ] 4.5 `nxai guide --interactive` — verify Panels with cyan DOUBLE border on each category
- [ ] 4.6 `Confirm.ask` — verify install proceeds on confirm, returns to menu on decline
- [ ] 4.7 Stub categories (db, ui, automation) — verify NO INSTALADO + gray `(stub)`
- [ ] 4.8 Unknown category — verify error + available list printed
- [ ] 4.9 Rich unavailable fallback — verify bash guide shown with `[INFO]` notice
