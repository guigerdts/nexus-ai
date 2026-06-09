# Design: Nexus AI Hardening

## Technical Approach

Four-phase hardening: bugfixes first (eliminate variable leaks, path injections, fragile parsing), then diagnostics+logging, then performance (async/cache), then structural consolidation. Each phase is backward-compatible — no existing user workflow breaks.

## Architecture Decisions

### Decision: Group work units by file, not by phase

| Option | Tradeoff | Decision |
|--------|----------|----------|
| Apply per-phase (all Phase 1, then Phase 2...) | Multiple edits to same file from different phases | **REJECTED** — risk of merge conflicts in shared files |
| Apply per-file (all changes to a file together) | Combines bugfix + enhancement in one WU | **ACCEPTED** — cleaner diff per file, easier review |

### Decision: JSON logging via env var branch

| Option | Tradeoff | Decision |
|--------|----------|----------|
| Separate `log_json_ok()` functions | Duplicates every log function | **REJECTED** — maintainability cost |
| Single branch per function checking `NEXUS_LOG_FORMAT` | Minimal code change, one function per level | **ACCEPTED** — 4 functions × 1 branch each |

### Decision: Registry cache in Bash serialize (not JSON)

| Option | Tradeoff | Decision |
|--------|----------|----------|
| Serialize as JSON, parse with jq/grep | Adds dependency on jq at boot time | **REJECTED** — every `nxai` call would need JSON parser |
| Serialize as `declare -A AGENTS=(...)` + source | Zero dependencies, native Bash | **ACCEPTED** — cache is valid Bash sourced with `.` |

### Decision: Async update via lockfile + background subshell

| Option | Tradeoff | Decision |
|--------|----------|----------|
| Background job with `&` + lockfile | Simple, no external deps | **ACCEPTED** |
| Cron/anacron for periodic checks | Wrong abstraction — this is runtime, not scheduled | **REJECTED** |

## Data Flow

```
# Registry cache flow
source agents.registry.sh
  → cache exists AND all metadata.sh older?
    → source logs/registry.cache.sh  (50ms)
    → skip module iteration
  → cache missing/stale?
    → iterate modules/*/metadata.sh  (200-500ms)
    → build AGENTS + AGENT_ORDER
    → write logs/registry.cache.sh

# Async update flow
nxai list
  → show_banner
  → check_update_silent
    → lockfile exists?
      → read cached version, return
    → no lockfile?
      → create lockfile
      → (curl ... &)  ← background fetch
      → return immediately
    → background process finishes
      → compare, log result, remove lockfile
      → next nxai invocation shows update if available
```

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `config/agents.registry.sh` | Modify | +35 lines: unset AGENT_* before source (BUG1) + cache serialize/invalidation (MEJ2) |
| `lib/nexus-install.sh` | Modify | +16 lines: LD_LIBRARY_PATH colon fix (BUG2) + venv fallback for PEP 668 (MEJ6) |
| `install.sh` | Modify | +67 lines: install_gum mktemp (BUG3) + create nexus.env during install (MEJ3) |
| `lib/nexus-update.sh` | Modify | +35 lines: jq/python3/grep chain (BUG4) + async check with lockfile (MEJ1) |
| `lib/nexus-log.sh` | Modify | +30 lines: NEXUS_LOG_FORMAT branching per function (MEJ5) |
| `lib/nexus-doctor.sh` | Create | +80 lines: 5 diagnostic checks + exit code strategy (MEJ4) |
| `core/nexus.sh` | Modify | +5 lines: `doctor` case in COMMAND dispatch (MEJ4) |
| `config/env.sh` | Modify | +4 lines: source `nexus.env` if exists (MEJ3) |
| `config/nexus.env` | Create | +15 lines: user-facing overrides template (MEJ3) |
| `shell/.bashrc` | Modify | +8 lines: source nexus.env with fallback (MEJ3) |
| `shell/.zshrc` | Modify | +8 lines: source nexus.env with fallback (MEJ3) |

Total: ~300 lines changed/added.

## Interfaces / Contracts

```bash
# lib/nexus-log.sh — new env var
NEXUS_LOG_FORMAT="${NEXUS_LOG_FORMAT:-text}"   # text | json
# When =json, output is: {"timestamp":"ISO8601","level":"OK|WARN|ERROR|INFO","message":"..."}

# lib/nexus-update.sh — new async contract
# check_update_silent() spawns background curl; returns immediately
# Uses $TMPDIR/nexus-update.lock as mutex
# Previous cache (nexus-version-check) is read while background runs

# config/agents.registry.sh — new cache
# logs/registry.cache.sh is valid Bash with declare -A AGENTS / declare -a AGENT_ORDER
# Invalidated when any modules/*/metadata.sh is newer

# lib/nexus-doctor.sh — new module
# doctor_main() → exit 0 (all pass), 1 (warnings), 2 (critical errors)
# Checks: dir perms, curl connectivity, disk space, tool versions, installed.txt consistency
```

## Testing Strategy

No test runner available — verification is manual/shell-based:

| Layer | What to Test | Approach |
|-------|-------------|----------|
| Unit | BUG1 leak | `bash -c 'source config/agents.registry.sh; ...'` — verify AGENT_* unset after loop |
| Unit | BUG2 LD path | Extract GLIBC wrapper template, verify no trailing colon with unset LD_LIBRARY_PATH |
| Unit | BUG3 mktemp | `bash install.sh --no-gum` — verify /tmp not polluted |
| Unit | BUG4 JSON chain | Mock curl output with multiline body, test jq/py3/grep paths |
| Manual | MEJ4 doctor | Run `nxai doctor` in healthy + broken states |
| Manual | MEJ5 JSON log | `NEXUS_LOG_FORMAT=json nxai list \| head -5` validate JSON |
| Manual | MEJ6 venv | Test in PEP 668 environment or mock `pip3 install --user` failure |
| Manual | MEJ1 async | `nxai list` — verify instant return, lockfile creation |
| Manual | MEJ2 cache | `ls -la logs/registry.cache.sh` after first `nxai` — verify cache file |
| Manual | MEJ3 modular | Delete nexus.env → verify fallback works; create it → verify sourced |

## Migration / Rollout

No migration required. All changes are additive or fix bugs in place:
- `nexus.env` is optional — systems run without it (existing behavior preserved)
- Registry cache is rebuilt on first `nxai` invocation after update
- Async update falls back to sync if lockfile can't be created
- Doctor command is new — no existing workflow uses it

Rollback: restore from git for each work unit.

## Work Units (implementation order)

| # | WU | Files | Est. Lines | Deps | Risk |
|---|-----|-------|-----------|------|------|
| 1 | Registry hardening (BUG1 + MEJ2) | `config/agents.registry.sh` | 35 | None | Low |
| 2 | Install lib hardening (BUG2 + MEJ6) | `lib/nexus-install.sh` | 16 | None | Low |
| 3 | Bootstrap + config (BUG3 + MEJ3) | `install.sh`, `config/env.sh`, `config/nexus.env`, `shell/.bashrc`, `shell/.zshrc` | 67 | None | Low |
| 4 | Update checker (BUG4 + MEJ1) | `lib/nexus-update.sh` | 35 | None | Low |
| 5 | JSON logging (MEJ5) | `lib/nexus-log.sh` | 30 | None | None |
| 6 | Doctor command (MEJ4) | `lib/nexus-doctor.sh` (new), `core/nexus.sh` | 95 | None | None |

Total estimated: ~278 lines.

## Backward Compatibility Risks

| Item | Risk | Mitigation |
|------|------|------------|
| BUG2 LD_LIBRARY_PATH | Wrapper template changes — existing GLIBC wrappers stay unchanged | Only affects NEW wrapper creation, not existing |
| MEJ1 async update | Background process may race with `nxai update --check` | Lockfile prevents concurrent checks; cache read shows previous result |
| MEJ3 nexus.env | RC files add a source for an optional file | Guarded by `[ -f ... ]` — no error if absent |
| MEJ5 JSON log | Callers may parse `[OK]` prefix text | When NEXUS_LOG_FORMAT is unset or `text`, behavior is identical |

## Open Questions

- [ ] MEJ1 async: what TTL for the lockfile? Proposal: 30s (curl timeout + grace). Lockfile older than 30s is treated as stale and removed.
- [ ] MEJ2 cache: should the cache live in `$TMPDIR` or `$NEXUS_ROOT/logs/`? Spec says `logs/` — keeping it under `$NEXUS_ROOT` ensures it persists across reboots for Termux (which has ephemeral `/tmp` on some devices).
