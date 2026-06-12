# Tasks: Figlet Professional Enhancements

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | ~105-130 |
| 400-line budget risk | Low |
| Chained PRs recommended | No |
| Suggested split | Single PR |
| Delivery strategy | ask-on-risk |

Decision needed before apply: No
Chained PRs recommended: No
Chain strategy: size-exception
400-line budget risk: Low

## Phase 1: Foundation — Shared Helper

- [x] 1.1 Create `lib/nexus-figlet.sh` with `figlet_render(texto, color_ansi, font1, font2, font3, clamp_min, clamp_max)`
  - Font chain: small → mini → default → uppercase fallback
  - Default color: 96 (cyan), default clamp: 76/86
  - Prints directly to stdout via `printf`
  - No dependency on NEXUS_ROOT — only `figlet` and `tput` in PATH
- [x] 1.2 Add `source "$NEXUS_ROOT/lib/nexus-figlet.sh"` to `core/nexus.sh` near existing sources

## Phase 2: MOTD Banner

- [x] 2.1 Modify `shell/motd.sh`: replace hardcoded ASCII art block with `figlet_render "NEXUS AI"` using clamp_min=40, clamp_max=60
- [x] 2.2 Add source guard before call: `declare -f figlet_render >/dev/null || source "$(dirname "${BASH_SOURCE[0]}")/../lib/nexus-figlet.sh"`

## Phase 3: Status Header

- [x] 3.1 Modify `core/nexus.sh` (status routing case): add `figlet_render "STATUS"` before calling `system_status()`

## Phase 4: Install Celebration

- [x] 4.1 Modify `core/nexus.sh` (`install_agent`): on individual install success, call `figlet_render "$target" 92` (green) — only if `[ -t 1 ]`, `tput cols >= 80`, and NOT in batch mode
- [x] 4.2 Modify `core/nexus.sh` install routing: for batch/multi installs (category and --all), set `NEXUS_BATCH_INSTALL=true`; after all installs, call `figlet_render "COMPLETADO" 92`

## Phase 5: Error Banner

- [x] 5.1 Modify `lib/nexus-log.sh`: add `log_fatal()` function that calls `figlet_render "ERROR" 91` (red), prints the fatal message, and exits with 1
  - Explicitly separate from `log_error()` — not reused by warnings
