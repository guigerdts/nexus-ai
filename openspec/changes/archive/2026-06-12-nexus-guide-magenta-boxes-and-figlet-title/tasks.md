# Tasks: Nexus Guide — Figlet Title + Magenta Boxes

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | ~60-80 |
| 400-line budget risk | Low |
| Chained PRs recommended | No |
| Suggested split | Single PR |
| Delivery strategy | ask-always |
| Chain strategy | pending |

Decision needed before apply: No
Chained PRs recommended: No
Chain strategy: pending
400-line budget risk: Low

## Phase 1: Figlet Title — show_guide()

- [x] 1.1 Add `command -v figlet` detection and font chain (small → mini → default) in `show_guide()`
- [x] 1.2 Pipe figlet output through `wc -L` to measure widest line; compare against `_inner`; fallback if exceeds
- [x] 1.3 Render figlet output in cyan (ANSI 96 or 38;5;51), or uppercase+padding if fallback triggered
- [x] 1.4 Render "POR CATEGORIAS" below the art in uppercase cyan with extra padding

## Phase 2: Box Wrapper — _print_category()

- [x] 2.1 Add `_cols`/`_bw`/`_inner` calculation at top of `_print_category()` (same vars as `core/nexus.sh`)
- [x] 2.2 Capture all current category output (header + table + uninstall line) into a variable
- [x] 2.3 Draw top border (╭─╮) and bottom border (╰─╯) in neon magenta ANSI 38;5;201
- [x] 2.4 Add content loop: strip ANSI via `sed` → measure `_visible` → compute `_pad` → print with `│` both sides

## Phase 3: Verification

- [x] 3.1 Run `bash lib/nexus-guide.sh` and visually verify figlet title renders in cyan
- [x] 3.2 Test fallback: temporarily hide figlet (`mv /usr/bin/figlet /tmp/`), verify uppercase+padding renders
- [x] 3.3 Verify all categories appear inside magenta boxes with correct ╭╮╰╯─│ characters
- [x] 3.4 Verify internal ANSI colors (cyan header, table content) preserved inside boxes
- [x] 3.5 Test narrow terminal: `COLUMNS=60 bash lib/nexus-guide.sh`
