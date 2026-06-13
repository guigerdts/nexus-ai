# Design: v0.8.2 Core Infrastructure Enhancements

## Technical Approach

Seven independent capabilities layered on a shared import system. Each new `lib/*.sh` follows the existing `nexus-figlet.sh` pattern — standalone functions with `NEXUS_COLOR_*` vars consumed from `config/env.sh`. Integration via minimal surgical edits to existing files: new case branch in `core/nexus.sh`, marker reads in `motd.sh`/`dashboard.py`, and optional `starship.toml` module.

## Architecture Decisions

| Decision | Choice | Alternatives | Rationale |
|----------|--------|-------------|-----------|
| Import guard mechanism | `declare -A` session map | File flags, indirect expansion | Termux Bash 5.x supports it; zero I/O; scope-correct per session |
| UI Toolkit location | New `lib/nexus-ui.sh` | Extend `nexus-log.sh` | Separate concern; `nexus-log.sh` is 214 LOC already; UI functions are independent |
| C Helper design | Shared function with heredoc C template | External C file, module-specific | Single source of truth for GLIBC loader; params injected via sed at compile time |
| Proot strategy | Wrapper functions around `proot-distro` | Full proot-distro replacement | No need to reimplement what `proot-distro` already does well; wrappers handle error handling and detection |
| PG detection | `pg_config` → `pg_ctl` in PATH → error | `pg_ctlcluster` probe, hardcoded path | `pg_config` is the official PostgreSQL discovery mechanism, cross-distro. Data directory detection uses 6-path probe pattern for reliability. `NEXUS_PG_CTL` env var for power-user override. |
| Scaffolding design | `nxai create` CLI subcommand | New module `modules/create/` | Scaffolding is a CLI-native action, not an agent install; keeps module count clean |
| Update marker format | Plain file `logs/update-available.txt` | JSON, env var, TMPDIR | Simplest readable format; survives across sessions; any language can read it (bash + Python) |

## Data Flow

```
Gap 1 (src-import)
  nexus_require "env" ──→ config/env.sh (sourced once, cached in declare -A)
  nexus_require "log" ──→ lib/nexus-log.sh
  nexus_require "ui" ───→ lib/nexus-ui.sh
  └── Guard: __NEXUS_SOURCED[name]=1 → subsequent calls are no-op

Gap 7 (update notifications)
  check_update_silent ──→ curl raw.githubusercontent.com ──→ version compare
       │                                                      
       └── writes logs/update-available.txt (marker)
                │
                ├── motd.sh reads marker → shows notification line
                ├── dashboard.py reads marker → MonitorPanel badge
                └── starship custom module → prompt indicator

Gap 3 (C helper)
  nexus_c_build bin output ──→ generate helper.c heredoc
       │                        └── replace @BINARY_PATH@, @LOADER@, @LIB_PATH@
       └── clang -O2 -o $output helper.c
            └── bin/claude (GLIBC-compatible wrapper)

Gap 5 (PG manager)
  nexus_pg_start data_dir ──→ os_detect: pg_ctlcluster? → pg_ctlcluster start
                                            └── pg_ctl? → pg_ctl -D dir start
                                                 └── error → "PostgreSQL not found"
```

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `lib/nexus-src.sh` | Create | Import system: `nexus_require()` with `declare -A` guard |
| `lib/nexus-ui.sh` | Create | UI toolkit: spinner, progress bar, table, box, confirm |
| `lib/nexus-c-helper.sh` | Create | C GLIBC loader compilation helper |
| `lib/nexus-proot.sh` | Create | Proot-distro lifecycle wrappers |
| `lib/nexus-pg.sh` | Create | PostgreSQL cluster management |
| `templates/` | Create | Project scaffolding template directory |
| `templates/express/` | Create | Express.js local template (package.json, src/, basic structure) |
| `core/nexus.sh` | Modify | Add `create`) case branch (~12 LOC) |
| `lib/nexus-update.sh` | Modify | Write `logs/update-available.txt` marker (~5 LOC); add `nexus_update_marker_read()` |
| `shell/motd.sh` | Modify | Read marker and show notification after random_tip (~8 LOC) |
| `tui/dashboard.py` | Modify | Read marker in `_refresh_all()`; pass to MonitorPanel (~10 LOC) |
| `tui/system_monitor.py` | Modify | Add `check_update()` returning marker content (~8 LOC) |
| `shell/starship.toml` | Modify | Add optional `custom.nexus-update` module (~6 LOC) |

## Interfaces

```bash
# lib/nexus-src.sh
nexus_require <module>       # Source module once with redeclaration guard
nexus_require_path <path>    # Source arbitrary path with guard

# lib/nexus-ui.sh
ui_spinner_start <label>     # Start animated spinner
ui_spinner_stop <ok|fail>    # Stop spinner with result
ui_progress_bar <current> <total> [label]
ui_table [--header h1 h2..] [--row v1 v2..]...
ui_box <title> [content]
ui_confirm <message>         # Returns 0 (yes) / 1 (no)

# lib/nexus-c-helper.sh
nexus_c_check_deps           # Verify clang + glibc available; returns 0/1
nexus_c_build <bin> <name> [extra_env...]
nexus_c_wrapper <name> <cmd> # Bash wrapper without C compilation

# lib/nexus-proot.sh
nexus_proot_detect           # Re-export env detection; returns 0 if proot host
nexus_proot_list             # List installed distros; returns array
nexus_proot_ensure <distro>  # Install distro if missing
nexus_proot_run <distro> <cmd>
nexus_proot_wrapper <distro> <bin> <name>

# lib/nexus-pg.sh
nexus_pg_init [data_dir]
nexus_pg_start [data_dir] [port]
nexus_pg_stop [data_dir]
nexus_pg_status
nexus_pg_create_db <name> [owner]
nexus_pg_drop_db <name>
nexus_pg_create_user <name> [password]
nexus_pg_detect              # Returns pg_ctl path (pg_config → PATH → error)
nexus_pg_detect_data         # Probes 6+ data dirs for PG_VERSION file

# lib/nexus-update.sh (modified)
nexus_update_marker_read     # Returns "vX.Y.Z" or empty
```

## Dependency Graph

```
Gap 1 (src-import) ─── base
    ├── Gap 2 (ui-toolkit)
    ├── Gap 3 (c-helper)
    ├── Gap 4 (proot)
    └── Gap 5 (pg-manager)

Gap 7 (update-notif) ─── independent (modifies existing lib)

Gap 6 (scaffolding) ─── independent (new CLI command)
```

## Testing Strategy

| Gap | Unit | Integration |
|-----|------|-------------|
| src-import | Source twice → verify no-op | Source in subshell → verify isolated state |
| ui-toolkit | Manual visual verification; ANSI detection in pipe | Pipe output → verify no ANSI codes |
| c-helper | Compile with known binary → verify ELF wrapper works | Cross-arch test if available |
| proot | Mock proot-distro; verify commands | Real proot-distro if installed |
| pg-manager | Mock pg_ctl; verify path detection | Real PostgreSQL if installed |
| scaffolding | Verify npx detection + error messages | `nxai create express test-app` → verify files |
| update-notif | Write marker → verify motd/dashboard/starship read it | Full chain test |

## Open Questions

- [x] `pg_ctlcluster` version detection — resuelto: usamos `pg_config` como mecanismo oficial, no pg_ctlcluster
- [ ] `proot-distro` installed check — add auto-install step in `nexus_proot_ensure`?
- [ ] `nexus_c_build` cross-arch test on x86_64 Linux
- [ ] Marker race condition: check_update_silent async vs motd.sh synchronous read
