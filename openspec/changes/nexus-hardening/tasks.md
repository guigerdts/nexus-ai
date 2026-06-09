# Tasks: Nexus AI Hardening

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | ~303 |
| 400-line budget risk | Low |
| Chained PRs recommended | No |
| Suggested split | Single PR |
| Delivery strategy | single-pr |
| Chain strategy | pending |

Decision needed before apply: No
Chained PRs recommended: No
Chain strategy: pending
400-line budget risk: Low

## WU1: Registry — config/agents.registry.sh

- [x] 1.1 Add `unset AGENT_*` vars before each `source "$_agent_dir/metadata.sh"` in loop (line 36, BUG1)
- [x] 1.2 Add `_registry_cache_generate()`: serialize `AGENTS` + `AGENT_ORDER` as valid Bash `declare` to `logs/registry.cache.sh`
- [x] 1.3 Add `_registry_cache_load()`: verify all `modules/*/metadata.sh` older than cache via `find -newer`, source cache if fresh; else return 1
- [x] 1.4 Wire cache load at top after array init (fast path); wire cache generate before `source categories.sh` and after each mutation

## WU2: Install — lib/nexus-install.sh

- [x] 2.1 Fix BUG2: change GLIBC wrapper template (line 265) to `export LD_LIBRARY_PATH=__GLIBC_LIB__${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}`
- [x] 2.2 Add PEP 668 venv fallback in `install_via_pip()`: detect `--user` failure, check `$VIRTUAL_ENV`, else create `$NEXUS_ROOT/venvs/<pkg>/`, keep `--break-system-packages` as last resort with warning
- [x] 2.3 Add venv-aware search in `uninstall_via_pip()`: check `$NEXUS_ROOT/venvs/<pkg>/bin/pip` first

## WU3: Bootstrap — install.sh, config/nexus.env (new), config/env.sh, shell/.bashrc, shell/.zshrc

- [x] 3.1 Fix BUG3: replace `/tmp/gum.tar.gz` + `rm -rf /tmp/gum_*` with `mktemp -d` in `install_gum()`, clean temp on exit
- [x] 3.2 Create `config/nexus.env`: NEXUS_ROOT, absolute PATH entries, Termux bind-mount block, user override vars
- [x] 3.3 Modify `config/env.sh`: add `[ -f "$NEXUS_ROOT/config/nexus.env" ] && source "$_"` at end
- [x] 3.4 Modify `shell/.zshrc` + `shell/.bashrc`: source nexus.env with `[ -f ]` guard, keep inline PATH as fallback
- [x] 3.5 Modify `install.sh` Step 8 (lines 507-584): replace inline PATH block with nexus.env write, keep symlink creation

## WU4: Update — lib/nexus-update.sh

- [x] 4.1 Fix BUG4: replace grep/cut JSON parsing (line 160-161) with `jq` > `python3 -c "import sys,json"` > grep fallback chain
- [x] 4.2 Add `_update_check_spawn()`: background `curl` to GitHub API, write result to `$TMPDIR/nexus-update.result`
- [x] 4.3 Modify `check_update_silent()`: lockfile mutex at `$TMPDIR/nexus-update.lock` with 30s stale TTL, spawn bg on miss, read cache if locked

## WU5: JSON Log — lib/nexus-log.sh

- [x] 5.1 Add `NEXUS_LOG_FORMAT="${NEXUS_LOG_FORMAT:-text}"` default at top
- [x] 5.2 Create `_nexus_log_json(level, message)`: emit `{"timestamp":"ISO8601","level":"LEVEL","message":"..."}`
- [x] 5.3 Branch `log_ok`, `log_warn`, `log_error`, `log_info` on `NEXUS_LOG_FORMAT=json` → call json formatter, else existing text path

## WU6: Doctor — lib/nexus-doctor.sh (new), core/nexus.sh

- [x] 6.1 Create `lib/nexus-doctor.sh`: `doctor_main()` dispatching 6 checks (permissions, connectivity, bindmounts, disk space, tool versions, installed.txt vs binary consistency); exit 0=pass, 1=warning, 2=critical
- [x] 6.2 Add `doctor)` case in `core/nexus.sh` case/esac (before `help`)
- [x] 6.3 Add `doctor` entry in `show_help()` command list
