# Proposal: v0.8.2 Core Infrastructure Enhancements

## Intent

7 infrastructure gaps in nexus-ai v0.8.2 — no centralized import system, no shared UI toolkit, ad-hoc C compilation, no proot wrappers, no PostgreSQL management, no project scaffolding, and update notifications invisible outside the TUI.

## Scope

### In Scope
- Import system with `declare -A` guard (`lib/nexus-src.sh`)
- UI toolkit: spinner, progress bar, table, box, confirm (`lib/nexus-ui.sh`)
- C GLIBC loader compilation helper (`lib/nexus-c-helper.sh`)
- Proot-distro lifecycle wrappers (`lib/nexus-proot.sh`)
- PostgreSQL server manager (`lib/nexus-pg.sh`)
- CLI scaffolding: `nxai create` subcommand + `templates/` directory
- Update notification markers across shell, TUI, and Starship prompt

### Out of Scope
- Package manager wrappers (pip/cargo/npm) — deferred to v0.9
- Proot performance tuning or multi-distro orchestration
- Full test harness or CI pipeline
- Database migration tooling or schema management

## Capabilities

### New Capabilities
- `src-import`: Centralized sourcing with `declare -A` redeclaration guards
- `ui-toolkit`: Reusable shell UI component library
- `c-helper`: GLIBC loader wrapper C program compilation
- `proot-management`: Proot-distro install/run/wrapper lifecycle
- `pg-manager`: PostgreSQL cluster init/start/stop/user/db management
- `project-scaffolding`: Template-based project generation via `nxai create`

### Modified Capabilities
- `update-checker`: Write persistent marker file consumed by shell and TUI
- `motd-display`: Read update marker and show notification line
- `nexus-cli`: Add `create` subcommand routing
- `dashboard-tui`: Read update marker in MonitorPanel
- `shell-bootstrap`: Starship config optionally reads marker for prompt indicator

## Approach

All 7 gaps are independently implementable. Build order follows dependency chain: Import System (blocks all others needing env vars) → Update Notifications → UI Toolkit → C Helper → Proot Mgmt → PG Manager → Scaffolding.

Each `lib/*.sh` follows existing patterns: bash functions wrapped by `nexus_require()`. Existing files get minimal surgical edits — `shell/motd.sh` (~2 LOC), `tui/dashboard.py` (~8 LOC), `core/nexus.sh` (~10 LOC for create routing), `lib/nexus-update.sh` (~5 LOC), `shell/starship.toml` (~5 LOC).

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `lib/nexus-src.sh` | New | Import system with `declare -A` guard (~80 LOC) |
| `lib/nexus-ui.sh` | New | UI toolkit (~150 LOC) |
| `lib/nexus-c-helper.sh` | New | C compilation helper (~90 LOC) |
| `lib/nexus-proot.sh` | New | Proot wrapper functions (~100 LOC) |
| `lib/nexus-pg.sh` | New | PG management (~180 LOC) |
| `templates/` | New | Project template stubs directory |
| `core/nexus.sh` | Modified | +create subcommand (~10 LOC) |
| `lib/nexus-update.sh` | Modified | Write `logs/update-available.txt` (~5 LOC) |
| `shell/motd.sh` | Modified | Read marker, show line (~2 LOC) |
| `tui/dashboard.py` | Modified | Read marker in MonitorPanel (~8 LOC) |
| `shell/starship.toml` | Modified | Optional prompt module (~5 LOC) |

## Delivery Note

Estimated total: ~860 LOC (new) + ~30 LOC (integration). This exceeds the 400-line review budget. Delivery strategy — chained PRs, single PR, or exception — will be decided in the Tasks phase, not now.

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| `declare -A` guard breaks existing source chain | Low | Test each module in isolation; chain integration test |
| C compilation fails on unknown arch | Low | Fallback error with aarch64/x86_64 supported list |
| `pg_ctl` paths differ across distros | Med | Probe `pg_ctlcluster` first, fallback to `pg_ctl` |

## Rollback Plan

Each gap is independently revertable. Remove `lib/*.sh` file, revert `core/nexus.sh` create branch, revert edits to `motd.sh`, `dashboard.py`, `starship.toml`, and `nexus-update.sh`. No cross-gap rollback dependency.

## Dependencies

- clang (`pkg install clang`) — C helper compilation
- proot-distro (`pkg install proot-distro`) — proot management
- npx (ships with Node.js) — project scaffolding remote templates
- PostgreSQL packages (pkg/apt) — PG management runtime

## Success Criteria

- [ ] `source lib/nexus-src.sh && nexus_require env` loads env once; 2nd call is no-op
- [ ] `ui_spinner_start "Loading"` animates; `ui_table` renders 3+ columns
- [ ] `nexus_c_build` produces executable that runs ELF binary via GLIBC loader
- [ ] `nexus_proot_ensure ubuntu` installs distro; `nexus_proot_run ubuntu echo ok` works
- [ ] `nexus_pg_init && nexus_pg_start` starts PostgreSQL on non-standard port
- [ ] `nxai create vite my-app` generates a Vite project
- [ ] `motd.sh` and `dashboard.py` show update line when marker file exists
