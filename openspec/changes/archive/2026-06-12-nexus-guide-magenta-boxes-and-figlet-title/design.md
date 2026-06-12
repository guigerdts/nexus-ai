# Design: Nexus Guide — Figlet Title + Magenta Boxes

## Technical Approach

Two isolated changes to `lib/nexus-guide.sh`:

1. **Dynamic figlet title**: Replace the hardcoded separator+title in `show_guide()` with figlet-rendered "NEXUS AI GUIA" using a compact font. Falls back to uppercase+padding if figlet is unavailable or output exceeds `_inner` width.
2. **Magenta box wrapper**: Capture all output of `_print_category()` into a variable, then wrap it with the same `╭─╮`/`│`/`╰─╯` pattern used in `core/nexus.sh show_help()`.

## Architecture Decisions

### Decision: Font Selection Chain

**Choice**: Try `figlet -f small`, then `-f mini`, then default font.
**Alternatives**: Hardcode one font; pipe through `figlet -I 2` + `ls *.flf` for auto-detection.
**Rationale**: small/mini are standard compact fonts shipped with figlet. The three-step chain is simple, doesn't depend on filesystem layout, and each step falls back cleanly.

### Decision: Box Logic Integration

**Choice**: Inline the box-drawing directly in `_print_category()` using the same variable names as `core/nexus.sh` (`_cols`, `_bw`, `_inner`, `_line`, `_plain`, `_visible`, `_pad`).
**Alternatives**: Extract a reusable `_print_box()` shell function.
**Rationale**: Inlining avoids modifying other files or creating a cross-file dependency. The logic is ~15 lines and self-contained. Duplication is acceptable here because the visual pattern intentionally matches (same colors, same characters) but serves a different caller context.

### Decision: Clamp Values

**Choice**: `_bw` min=78, max=86 (→ `_inner` 76-84).
**Rationale**: Longest line measured across all tool categories is 81 visible characters. The clamp range provides 3 chars of safety margin. No adjustment needed.

### Decision: Variable Naming

**Choice**: Reuse `_bw`, `_inner`, `_cols`, `_line`, `_plain`, `_visible`, `_pad` — identical to `core/nexus.sh`.
**Rationale**: Familiarity for anyone who has read the existing box code. Avoids introducing new naming conventions.

## Data Flow

### show_guide() title flow

```
command -v figlet → figlet -f small "NEXUS AI GUIA" → wc -L → compare ≤ _inner?
  ├─ YES: print figlet output → print "POR CATEGORIAS" → reset color
  └─ NO:  figlet -f mini → same measure → compare?
             ├─ YES: print
             └─ NO:  figlet default → same measure → compare?
                        ├─ YES: print
                        └─ NO: fallback (uppercase + padding)
```

### _print_category() box flow

```
_category_content=$( )
  ├─ header (cyan separator + title + separator)
  ├─ table header (Herramienta / Descripcion / Instalar)
  ├─ table rows (per tool)
  └─ uninstall line
                        ↓
draw top border: ╭───╮
for each line in _category_content:
  _plain = strip-ansi
  _visible = ${#_plain}
  _pad = _inner - _visible
  print: │ content [padding] │
draw bottom border: ╰───╯
```

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `lib/nexus-guide.sh` | Modify | `show_guide()` — figlet title or uppercase fallback; `_print_category()` — box wrapper |

## Testing Strategy

| Layer | What | Approach |
|-------|------|----------|
| Visual | figlet renders correctly | Run `bash nexus-guide.sh` and inspect output |
| Fallback | figlet unavailable | Temporarily move figlet binary, verify fallback renders |
| Fallback | font too wide | Use a wide font explicitly, verify fallback triggers |
| Non-TTY | tput cols fails | `tput cols` fallback to `|| echo 80` (already proven) |

## Migration / Rollout

No migration required. Single-file change, no state, no data.

## Open Questions

None. All technical decisions resolved by exploration, proposal, and spec analysis.