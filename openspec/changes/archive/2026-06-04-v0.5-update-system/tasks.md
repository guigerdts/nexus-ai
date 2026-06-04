# Tasks: v0.5 — Sistema de Actualizaciones + Version Bump

**Change**: v0.5-update-system
**Total tasks**: 29
**Mode**: Standard (strict_tdd: false)

## Phase 1: Foundation (1.1 – 1.17)

- [x] 1.1 Create `VERSION` file at repo root with content `0.5.0`
- [x] 1.2 Create `lib/nexus-update.sh` module with config vars (cache file, TTL, log paths)
- [x] 1.3 Implement `_nexus_version_compare()` — semver comparator
- [x] 1.4 Implement `_nexus_update_cache_read()` — temp file cache with TTL check
- [x] 1.5 Implement `_nexus_update_cache_write()` — write timestamp + version to cache
- [x] 1.6 Implement `check_update_silent()` — silent fetch, cache, compare, notify
- [x] 1.7 Implement `check_update_verbose()` — detailed version + changelog display
- [x] 1.8 Implement `apply_update()` — git pull or curl install
- [x] 1.9 Bump `NEXUS_VERSION` in `config/env.sh`: `0.2.0` → `0.5.0`
- [x] 1.10 Bump fallback version in `shell/motd.sh`: `0.2.0` → `0.5.0`
- [x] 1.11 Bump version comment in `core/nexus.sh`: `0.2.0` → `0.5.0`
- [x] 1.12 Bump version in `install.sh` (help text): `v0.2.0` → `v0.5.0`
- [x] 1.13 Bump version in `install.sh` (remote install echo): `v0.2.0` → `v0.5.0`
- [x] 1.14 Bump version comment in `config/agents.registry.sh`: `0.2.0` → `0.5.0`
- [x] 1.15 Bump version in `README.md`: `v0.2.0` → `v0.5.0`
- [x] 1.16 Source `lib/nexus-update.sh` in `core/nexus.sh` module chain
- [x] 1.17 Add `update` module to `system_status()` module listing

## Phase 2: Silent check in banner (2.1 – 2.8)

- [x] 2.1 Add `check_update_silent` after `show_banner` in `install` case
- [x] 2.2 Add `check_update_silent` after `show_banner` in `remove` case
- [x] 2.3 Add `check_update_silent` after `show_banner` in `list` case
- [x] 2.4 Add `check_update_silent` after `show_banner` in `status` case
- [x] 2.5 Add `check_update_silent` after `show_banner` in `agent` case
- [x] 2.6 Add `check_update_silent` after `show_banner` in `memory` case
- [x] 2.7 Add `check_update_silent` after `show_banner` in `update` case
- [x] 2.8 Add `check_update_silent` after `show_banner` in unknown command (`*`) case

## Phase 3: nxai update commands (3.1 – 3.2)

- [x] 3.1 Replace `update` case stub with routing: `--check` (verbose) / default (apply)
- [x] 3.2 Update `show_help()` to document `update` and `update --check`

## Phase 4: Verification (4.1 – 4.4)

- [x] 4.1 Syntax check: `bash -n` passes on all modified files (6 shell files)
- [x] 4.2 Functional test: `_nexus_version_compare` — equal, older, newer, with/without v-prefix, error cases
- [x] 4.3 Functional test: `_nexus_update_cache_read/write` — write, read, expired, missing
- [x] 4.4 Source chain test: `source config/env.sh && source lib/nexus-update.sh` works, `NEXUS_VERSION=0.5.0`
