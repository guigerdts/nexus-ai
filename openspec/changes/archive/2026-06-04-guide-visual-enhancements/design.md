# Design: Guide Visual Enhancements

## Technical Approach

Two-layer rendering: (1) **Bash** — `_print_category()` function with ANSI color constants, `printf` column alignment, and a `has_uninstall` flag for the dimmed uninstall line; (2) **Python/Rich** — `build_category_table()` factory shared by single-category and all-categories views, wrapped in `Panel` with `border_style="cyan"` and `box.DOUBLE`. The interactive menu wraps its tool selection table in a Panel and gates install via `Confirm.ask`. Fallback from Rich to bash is handled by `NEXUS_RICH_AVAILABLE` flag in `env.sh`.

## Architecture Decisions

| Decision | Choice | Alternatives | Rationale |
|----------|--------|-------------|-----------|
| Bash category rendering | `_print_category()` with positional args + `has_uninstall` flag | One function per category, inline `echo` blocks | Single entry point: all 8 categories share same format. `has_uninstall` toggles the muted uninstall footer without duplicating template logic. |
| Rich table layout | `build_category_table()` factory + `show_category()` Panel wrapper | Single monolithic `show_all()`, inline table building per category | Factory is testable in isolation. Panel wrapper can be composed for both single-category and all-categories views without duplicating table construction. |
| Interactive tool table | Wrapped in `Panel` | Bare `console.print()` | Spec requires all Rich output to use cyan-bordered Panels. Consistent with single-category display. |
| Data source | `CATEGORIES` dict (Python), `case` statement (bash) | Shared YAML/JSON, metadata.sh sourcing | Both files already have inline data. Extracting to a shared format adds complexity with zero UX benefit for this visual-only change. |
| State management | Stateless — reads from `CATEGORIES` only | Tracking installed state per tool | The guide shows available tools, not installation status of the host. `INSTALADO`/`NO INSTALADO` is a visual hint based on stub detection, not a live state query. |

## Data Flow

```
nxai guide
  └─▶ show_guide()
       ├─ show_guide_category("ai")      → _print_category() → ANSI headers + printf columns
       ├─ show_guide_category("editor")  → _print_category()
       └─ ... 7 more

nxai guide <cat>
  └─▶ show_guide_category(<cat>)
       └─ case → _print_category() or error

nxai guide --interactive
  └─▶ show_guide_rich()
       ├─ NEXUS_RICH_AVAILABLE=true  →  python3 tui/guide.py --interactive
       │    ├─ CATEGORIES dict  →  build_category_table()  →  Panel  →  console.print
       │    └─ interactive_menu()  →  Panel intro  →  Prompt.ask  →  Table + Panel  →  Confirm.ask  →  subprocess
       └─ NEXUS_RICH_AVAILABLE=false →  echo "[INFO] Rich no disponible"  →  show_guide()
```

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `tui/guide.py` | Modify | Wrap interactive tool table in `Panel(border_style="cyan", box=box.DOUBLE)`. Wrap intro message Panel. Minor refinements. |
| `lib/nexus-guide.sh` | Modify (minor) | Ensure color constants match `_CYAN`, `_YELLOW`, `_GRAY`, `_RESET` pattern. Already refactored to `_print_category()`. |

## Interfaces / Contracts

### `_print_category()` (bash)

```bash
_print_category "Title" <has_uninstall> <name> <desc> <cmd> [name desc cmd...]
# has_uninstall: "yes"|"no"
# cmd: install command string or "(stub)"
```

### `build_category_table()` (Python)

```python
def build_category_table(cat_name: str) -> Table | None
# Returns None for unknown category
# Table has columns: Herramienta, Descripcion, Estado, Comando
```

### `CATEGORIES` dict shape

```python
CATEGORIES = {
    "ai": {
        "title": "IA / Agentes",
        "tools": [
            ("opencode", "CLI multi-modelo 150K+ stars", "nxai install opencode"),
            # ...
        ]
    },
    # ... 7 more
}
```

## Testing Strategy

| Layer | What to Test | Approach |
|-------|-------------|----------|
| Syntax | `lib/nexus-guide.sh` | `bash -n` verification |
| Syntax | `tui/guide.py` | `python3 -m py_compile tui/guide.py` |
| Import | Rich availability | `python3 -c "from rich.console import Console; from rich.table import Table; from rich.panel import Panel"` |
| Manual | `nxai guide` | Verify cyan headers, `═` separators, aligned columns |
| Manual | `nxai guide --interactive` | Verify Panels, Confirm.ask, stub detection, fallback |
| Manual | Cancel path | Decline Confirm.ask — verify return to category menu |

## Migration / Rollout

No migration required. Visual-only changes to existing functions. The interactive Panel wrapping is additive — existing callers see the new look immediately.

## Open Questions

- None — all decisions resolved in spec.
