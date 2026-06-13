# Tasks: v0.8.2 Core Infrastructure Enhancements

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | ~890 |
| 400-line budget risk | High |
| Chained PRs recommended | Yes |
| Suggested split | PR 1→5 (see below) |
| Delivery strategy | ask-on-risk |

Decision needed before apply: **Yes**
Chained PRs recommended: **Yes**
Chain strategy: **stacked-to-main**
400-line budget risk: **High**

### Suggested Work Units

| Unit | Goal | LOC | PR |
|------|------|:---:|:--:|
| 1 | Import System + Update Notifications | ~120 | PR 1 |
| 2 | UI Toolkit | ~150 | PR 2 |
| 3 | C Helper + Proot Management | ~190 | PR 3 |
| 4 | PostgreSQL Manager | ~180 | PR 4 |
| 5 | Scaffolding + CLI routing | ~130 | PR 5 |

## Phase 1: Foundation (Import System)

- [x] 1.1 Create `lib/nexus-src.sh` — `nexus_require()` with `declare -A` guard and NEXUS_ROOT auto-detection
- [x] 1.2 Create `_NEXUS_SRC_MODULES` map: env, log, install, figlet, update, guide, ui, c-helper, proot, pg
- [x] 1.3 Migrate `core/nexus.sh` — replace 8 `source` calls with `source lib/nexus-src.sh` + `nexus_require`
- [x] 1.4 Document `nexus_require` usage in lib headers

## Phase 2: Update Notifications

- [x] 2.1 Modify `lib/nexus-update.sh` — `check_update_silent` writes `logs/update-available.txt` and `nexus_update_marker_read()` reads it
- [x] 2.2 Modify `shell/motd.sh` — read marker after random_tip, show ">> Actualizacion disponible: vX.Y.Z"
- [x] 2.3 Modify `tui/system_monitor.py` — add `check_update()` reading marker
- [x] 2.4 Modify `tui/dashboard.py` — show update in MonitorPanel
- [x] 2.5 Modify `shell/starship.toml` — add optional `custom.nexus-update` module

## Phase 3: UI Toolkit

- [x] 3.1 Create `lib/nexus-ui.sh` — `ui_spinner_start(label)` / `ui_spinner_stop(result)` with native bash frames and gum fallback
- [x] 3.2 Add `ui_progress_bar(current, total, label)` using `_build_bar` pattern
- [x] 3.3 Add `ui_table` with header/row support and column auto-alignment
- [x] 3.4 Add `ui_box(title, content)` consolidating patterns from show_help and _print_category
- [x] 3.5 Add `ui_confirm(message)` returning 0/1 with ANSI detection
- [x] 3.6 Migrate `_build_bar` from `lib/nexus-log.sh` into private `_ui_build_bar` with delegation

## Phase 4: C Helper + Proot

- [x] 4.1 Create `lib/nexus-c-helper.sh` — `nexus_c_check_deps()` verifies clang + ld-linux + glibc
- [x] 4.2 Add `nexus_c_build(binary, output, extra_env...)` — heredoc C template, sed replace, clang -O2 compile
- [x] 4.3 Add `nexus_c_wrapper(name, cmd)` — bash wrapper without C compilation
- [x] 4.4 Create `lib/nexus-proot.sh` — `nexus_proot_detect()`, `nexus_proot_list()`, `nexus_proot_ensure(distro)`
- [x] 4.5 Add `nexus_proot_run(distro, cmd)` and `nexus_proot_wrapper(distro, bin, name)`
- [x] 4.6 Refactor `modules/claude-code/install.sh` — replace inline C helper (lines 101-156) with `nexus_c_build`

## Phase 5: PostgreSQL Manager

- [x] 5.1 Create `lib/nexus-pg.sh` — `nexus_pg_detect()` with pg_config → PATH probe chain
- [x] 5.2 Add `nexus_pg_detect_data()` — 6-path probe for PG_VERSION file
- [x] 5.3 Add `nexus_pg_init(data_dir)` — initdb with `$NEXUS_ROOT/data/pg` default
- [x] 5.4 Add `nexus_pg_start(data_dir, port)` — pg_ctl start with env-aware detection
- [x] 5.5 Add `nexus_pg_stop(data_dir)` / `nexus_pg_status` / `nexus_pg_create_db` / `nexus_pg_drop_db` / `nexus_pg_create_user`

## Phase 6: Scaffolding

- [x] 6.1 Create `templates/` directory with `templates/express/` (package.json, src/index.js, basic structure)
- [x] 6.2 Add `create_project(type, name)` to `core/nexus.sh` — npx-based + local template fallback
- [x] 6.3 Add `create)` case branch to `core/nexus.sh` CLI router
- [x] 6.4 Update `show_help` and guide to document `nxai create`

## Verification

- [x] V.1 Source `lib/nexus-src.sh` twice — second source is no-op
- [x] V.2 Write marker file → verify motd.sh shows notification
- [x] V.3 `ui_spinner_start/stop` animates; `ui_table` renders 3+ columns
- [x] V.4 `nexus_c_build` produces executable that runs via GLIBC loader
- [x] V.5 `nexus_proot_ensure ubuntu` installs distro if missing
- [x] V.6 `nexus_pg_init && nexus_pg_start` starts PostgreSQL on non-standard port
- [x] V.7 `nexus_pg_create_db test && nexus_pg_drop_db test` succeeds
- [x] V.8 `nxai create express test-app` generates project structure
