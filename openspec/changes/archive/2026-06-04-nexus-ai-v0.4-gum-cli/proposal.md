# Proposal: v0.4 — CLI Presentation with Gum

## Intent

Replace raw ANSI echo output with professional CLI formatting using Gum (Charm.sh). Current output is functional but unpolished — no borders, tables, spinners, or interactive prompts. This change makes NEXUS AI feel like a modern CLI tool while keeping full fallback when Gum is unavailable.

## Scope

### In Scope
1. **Banner display** — ASCII art before every command except `help`, `--help`, `dashboard`, `ui`
2. **`nxai list`** — `gum table` with Nombre/Tier/Estado/Descripcion (INSTALADO green, NO INSTALADO yellow)
3. **`nxai status`** — `gum style` bordered info panel
4. **`nxai install`** — `gum confirm` + `gum spin` with banner
5. **`nxai remove`** — mandatory `gum confirm` + `gum spin` with banner
6. **`nxai agent test`** — `gum spin` + `gum style` PASS/FAIL with banner
7. **Gum installation** in `install.sh` — `pkg install gum` (Termux), GitHub tarball (proot-Ubuntu)
8. **`--no-gum` flag** in `install.sh` to skip gum installation
9. **Fallback** — ANSI output + banner when gum unavailable
10. **Unify color systems** — merge `NEXUS_COLOR_PRIMARY` (env.sh) and `_NEXUS_CYAN` (nexus-log.sh)
11. **`NEXUS_GUM_AVAILABLE`** var in config/env.sh for fast runtime detection

### Out of Scope
- Changes to `tui/` (Textual dashboard)
- Changes to agent install scripts (`modules/*/`)
- New CLI commands or agent features

## Capabilities

### New Capabilities
None — all changes modify existing capabilities.

### Modified Capabilities
- **nexus-cli**: All output functions add gum formatting with ANSI fallback; banner display logic added; banner exceptions for help/dashboard/ui
- **env-config**: New `NEXUS_GUM_AVAILABLE` export; unified color system (single source of ANSI cyan/reset)
- **install-bootstrap**: Optional gum installation step; new `--no-gum` flag

## Approach

**Architecture: Option C (Hybrid)** — banner centralized in `nexus-log.sh`, gum features inline per command:

- **`config/env.sh`**: Add `NEXUS_GUM_AVAILABLE=$(command -v gum &>/dev/null && echo true || echo false)`. Unify `NEXUS_COLOR_PRIMARY` and `_NEXUS_CYAN` into one source.
- **`lib/nexus-log.sh`**: Add `show_banner()` (checks `NEXUS_GUM_AVAILABLE`, prints ASCII art in cyan). Enhance `log_ok/log_info/log_error/log_warn` with gum style when available.
- **`core/nexus.sh`**: Each command calls `show_banner()` upfront (except `help`/`--help`/`dashboard`/`ui`). Gum-specific features (`gum table`, `gum confirm`, `gum spin`) handled inline with `if [ "$NEXUS_GUM_AVAILABLE" = true ]` / else legacy path.
- **`install.sh`**: Add gum installation step (Step 9). `--no-gum` flag. Termux → `pkg install gum`, proot-Ubuntu/linux → GitHub tarball to `$NEXUS_ROOT/bin/`.

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `core/nexus.sh` | Modified | Banner calls + gum formatting in list/status/install/remove/agent-test, banner exceptions |
| `lib/nexus-log.sh` | Modified | `show_banner()`, gum-enhanced log helpers, unified color vars |
| `config/env.sh` | Modified | Add `NEXUS_GUM_AVAILABLE`, unify color system |
| `install.sh` | Modified | Optional gum install step, `--no-gum` flag |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Gum not available at runtime | Medium | `command -v gum` check + graceful ANSI fallback; test both paths per command |
| `gum confirm` hangs in CI/non-TTY | Low | Check `[ -t 0 ]` before interactive prompts; fallback to log prompt |
| Gum install failure (no ARM64 binary) | Low | Already verified: `gum_linux_arm64.tar.gz` exists in v0.17.0 |
| ARM64 compatibility | Low | Gum provides official ARM64 Linux tarballs |

## Rollback Plan

Revert `core/nexus.sh`, `lib/nexus-log.sh`, `config/env.sh`, `install.sh` to pre-v0.4 state via `git checkout`. Remove gum binary from `$NEXUS_ROOT/bin/` if present. Existing ANSI fallback means commands still work without gum — rollback is visual only.

## Dependencies

- **Gum v0.17.0+** (Charm.sh) — downloaded at install time, optional at runtime
- Termux: `pkg install gum` (official package)
- proot-Ubuntu/linux: GitHub tarball (`gum_linux_arm64.tar.gz`)

## Success Criteria

- [ ] `nxai list` shows a table with colored status (green/yellow) when gum available
- [ ] `nxai install <agent>` shows `gum confirm` prompt + `gum spin` progress
- [ ] `nxai remove <agent>` requires `gum confirm` before uninstalling
- [ ] `nxai agent test <name>` shows spinner + styled PASS/FAIL
- [ ] All commands work identically when gum is not installed (ANSI fallback)
- [ ] `nxai help`, `nxai --help`, `nxai dashboard`, `nxai ui` show NO banner
- [ ] `install.sh --no-gum` skips gum installation without error
- [ ] `NEXUS_GUM_AVAILABLE` is `true` when gum present, `false` otherwise
- [ ] Color system unified — `_NEXUS_CYAN` removed, `NEXUS_COLOR_PRIMARY` used everywhere
