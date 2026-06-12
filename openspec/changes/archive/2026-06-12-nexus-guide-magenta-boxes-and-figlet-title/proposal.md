# Proposal: Nexus Guide — Magenta Boxes & Figlet Title

## Intent

Improve visual presentation of `nexus-guide.sh`: add a dynamic ASCII art title (figlet) and wrap each category table in a neon magenta box, matching the style of `show_help()` in `core/nexus.sh`. The guide currently uses loose echo/printf with no borders — inconsistent with the rest of the CLI.

## Scope

### In Scope
1. Replace `show_guide()` title with figlet "NEXUS AI GUIA" (compact font) + "POR CATEGORIAS" uppercase below, cyan ANSI coloring, outside any box. Fallback if figlet unavailable/too wide.
2. Wrap every `_print_category()` output in a magenta neon box (ANSI 38;5;201) reusing the strip-ansi/padding/character pattern from `core/nexus.sh`.
3. Extract box-drawing into a reusable helper function sourced via `core/nexus.sh`.

### Out of Scope
- No content, table layout, or internal ANSI color changes.
- No refactoring of `_print_category` beyond adding the wrapper.
- No new categories or tools.

## Capabilities

### New Capabilities
None — no new spec-level behavior.

### Modified Capabilities
None — purely visual enhancement; all existing spec requirements remain satisfied (colors preserved inside box, same columns, same data).

## Approach

1. **Box helper**: Extract box-drawing (terminal width detection, strip-ansi, padding loop, border chars) into a reusable function in `core/nexus.sh` → sourced by `lib/nexus-guide.sh`.
2. **Figlet title in `show_guide()`**: Detect `figlet`, try `-f small`, measure output width vs `_inner` clamp (76-84). If fits → render "NEXUS AI GUIA" + "POR CATEGORIAS" in cyan outside box. If too wide → fallback to uppercase+padding format.
3. **Box wrapper in `_print_category()`**: Capture `_print_category` output via subshell (`_content=$(...)`), pipe through box-drawing loop.
4. **Clamp analysis**: Longest visible line across all categories = **81 chars** (db → `mariadb` + "BD SQL fork de MySQL — rapida y open source" + `nxai install mariadb`). Fits within max `_inner` (84). **No clamp adjustment needed.**

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `lib/nexus-guide.sh` | Modified | `show_guide()` title, `_print_category()` box wrapper, color/SHELL variables |
| `core/nexus.sh` | Modified | Extract box-drawing into reusable helper (shared via function) |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| figlet absent at runtime | Low | `command -v` check → uppercase fallback |
| figlet font too wide | Low | Measure vs `_inner` → fallback |
| ANSI 256-color unsupported | Low | Falls back to nearest color automatically |
| `tput cols` fails | Low | `|| echo 80` fallback exists |
| Category line wider than box | Low | 81 chars max vs 84 _inner max — verified. `_pad=0` handles overflow gracefully |

No Termux/proot-Ubuntu compatibility impact — same ANSI/tput/functions already used in `core/nexus.sh`.

## Rollback Plan

Revert the two functions in `lib/nexus-guide.sh` (`show_guide` and `_print_category`) and the box-drawing helper extraction in `core/nexus.sh`. Single file restore — low risk.

## Success Criteria

- [ ] `figlet -f small "NEXUS AI GUIA"` renders at ≤ 76-84 chars → displayed outside box, cyan
- [ ] Or figlet fallback renders uppercase with extra blank lines
- [ ] Every `_print_category()` output appears inside a neon magenta box (╭─╮││╰─╯)
- [ ] All ANSI colors preserved inside the box (cyan header stays cyan, yellow install stays yellow)
- [ ] No category line truncated by the right box edge
- [ ] Box helper function reusable for future widget wrappers
