# Tasks: v0.4 — CLI Presentation with Gum

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | ~275 (250-300) |
| 400-line budget risk | Low |
| Chained PRs recommended | No |
| Suggested split | Single PR |
| Delivery strategy | ask-on-risk |
| Chain strategy | pending |

Decision needed before apply: No
Chained PRs recommended: No
Chain strategy: pending
400-line budget risk: Low

## Phase 1: Foundation — config/env.sh (no deps)

- [x] 1.1 `config/env.sh` — Add `NEXUS_GUM_AVAILABLE=$(command -v gum &>/dev/null && echo true || echo false)` after the version block. Replace the color block with unified vars: `NEXUS_COLOR_CYAN`, `NEXUS_COLOR_YELLOW`, `NEXUS_COLOR_RED`, `NEXUS_COLOR_GREEN`, `NEXUS_COLOR_GRAY`, `NEXUS_COLOR_RESET`. Keep `NEXUS_COLOR_PRIMARY="${NEXUS_COLOR_CYAN}"` as alias.

## Phase 2: Logging Layer — lib/nexus-log.sh (depends on Phase 1)

- [x] 2.1 `lib/nexus-log.sh` — Remove the 4 `_NEXUS_*` local color vars (lines 9-20). Use `NEXUS_COLOR_*` from env.sh instead. Each `log_*()` fn adds `[ -t 1 ]` check before emitting ANSI codes, else strips colors.
- [x] 2.2 `lib/nexus-log.sh` — Add `show_banner()` function: when `NEXUS_GUM_AVAILABLE=true` → `gum style --foreground 212 --border double --padding "1 2"` wrapping the ASCII art + `gum style --foreground 245` for credits. Fallback → `echo -e` with `NEXUS_COLOR_CYAN`/`NEXUS_COLOR_GRAY`.

## Phase 3: Core CLI — core/nexus.sh (depends on Phase 1+2)

- [x] 3.1 `core/nexus.sh` — Add `show_banner` calls in case dispatch before `install`, `remove`, `list`, `status`, `agent`, `memory`, `update`, and `*` (not before `dashboard|ui`, `help|--help|""`). Reorder case: exceptions first, then dispatch with banner.
- [x] 3.2 `core/nexus.sh` — Rewrite `list_agents()`: when `NEXUS_GUM_AVAILABLE=true` → build CSV rows from `AGENT_ORDER` loop with status colored `gum style --foreground 42` (INSTALADO) / `--foreground 220` (NO INSTALADO), pipe to `gum table --separator "," --border rounded --columns "Nombre,Tier,Estado,Descripcion"`. Fallback → existing `echo -e` loop.
- [x] 3.3 `core/nexus.sh` — Rewrite `system_status()`: when gum available → `gum style --border rounded --padding "1 2"` with the system info string. Fallback → current `echo` block.
- [x] 3.4 `core/nexus.sh` — Rewrite `install_agent()`: when gum available + `[ -t 0 ]` → `gum confirm` + `gum spin --spinner dot`. Fallback → current install flow with `log_*` calls.
- [x] 3.5 `core/nexus.sh` — Rewrite `remove_agent()`: when gum available + `[ -t 0 ]` → mandatory `gum confirm` + `gum spin`. Fallback → current flow.
- [x] 3.6 `core/nexus.sh` — Rewrite `agent_test()`: when gum available → `gum spin --title "Probando..."` + `gum style --foreground 42` PASS / `--foreground 196` FAIL. Fallback → current `log_ok`/`log_error`.

## Phase 4: Installer — install.sh (depends on Phase 1)

- [x] 4.1 `install.sh` — Add `SKIP_GUM=false` default. Add `--no-gum)` case to flag parser and usage() help text. Update all `step N 8` calls to `step N 9`.
- [x] 4.2 `install.sh` — Add `install_gum()` function: if `SKIP_GUM=true` → skip. If `command -v gum` succeeds → skip. If `NEXUS_ENV=termux` → `pkg install gum -y`. Else → download `gum_0.17.0_Linux_arm64.tar.gz` from GitHub, extract binary to `$NEXUS_ROOT/bin/gum`. Add call to `install_gum` after Step 8 block.
