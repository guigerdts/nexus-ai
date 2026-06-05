# Archive Report: hybrid-install-strategy

**Change**: hybrid-install-strategy — Unified install via Termux bind-mounts
**Date archived**: 2026-06-05
**SDD Pipeline**: proposal → spec → design → tasks → apply → verify → archive
**Status**: Complete (all 9 tasks implemented and verified)

---

## What Was Done

Replaced self-contained package manager detection in each agent installer with a single, shared `NEXUS_TERMUX_ACCESSIBLE` detection in `config/env.sh`. When proot-Ubuntu detects Termux bind-mounts (via `-x /data/data/com.termux/files/usr/bin`), it sets `NEXUS_TERMUX_ACCESSIBLE=true`, exports Termux bin/prefix/pkg/pip paths, and prepends Termux directories to PATH. Downstream consumers (`lib/nexus-install.sh`, agent installers, shell configs) read this single variable to select `TERMUX_PIP`/`TERMUX_PKG` vs system `pip3`/`apt`, eliminating OOM from numpy source compilation and removing duplicate Python environments.

## Final State of Modified Files

Eight files were modified (0 created, 0 deleted, 8 modified):

| File | Lines Changed | What Changed |
|------|--------------|--------------|
| `config/env.sh` | ~30 lines added | `NEXUS_TERMUX_ACCESSIBLE` detection block after line 78 (NEXUS_ENV detection): checks `TERMUX_BIN` existence + executability, exports `TERMUX_BIN/PREFIX/PKG/PIP`, prepends to PATH with case-based idempotency guard |
| `lib/nexus-install.sh` | ~25 lines modified | `install_via_pip()`: checks `NEXUS_TERMUX_ACCESSIBLE=true` → uses `TERMUX_PIP`, falls back to `pip3`/`pip`. `install_via_apt()`: checks `ACCESSIBLE=true` → `TERMUX_PKG`, then `NEXUS_ENV=termux` → `pkg`, else `apt -y` |
| `modules/aider/install.sh` | ~15 lines modified | Detection block: added `NEXUS_TERMUX_ACCESSIBLE` guard before parent-defer. Numpy pre-install: uses `TERMUX_PKG install python-numpy` when accessible. Error messages reference hybrid strategy |
| `modules/fabric/install.sh` | ~8 lines modified | Detection block: same `NEXUS_TERMUX_ACCESSIBLE` guard pattern as aider |
| `modules/sgpt/install.sh` | ~8 lines modified | Detection block: same `NEXUS_TERMUX_ACCESSIBLE` guard pattern as aider |
| `shell/.bashrc` | ~10 lines added | Termux bind-mount PATH block after NEXUS_ROOT/bin guard: `[ -d "$dir" ]` guard per entry, case-based dedup |
| `shell/.zshrc` | ~10 lines added | Termux bind-mount PATH block after PATH export: same guard pattern as .bashrc |
| `install.sh` | ~12 lines added | Hardcoded PATH blocks for both .bashrc and .zshrc include Termux bind-mount dirs with runtime `[ -d ]` guards |

## Key Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Detection locus | `config/env.sh`, after NEXUS_ENV block | Single source of truth — every sub-shell that sources env.sh gets the var; avoids per-script detection drift |
| Variable surface | `NEXUS_TERMUX_ACCESSIBLE` (bool), `TERMUX_BIN/PREFIX/PKG` (paths) | Bool for conditional branching; paths so consumers don't re-derive; `TERMUX_*` naming matches Termux convention |
| PATH assembly | `[ -d "$dir" ]` guard per entry, `case ":$PATH:"` idempotency | Prevents pollution on Linux puro; idempotent re-source |
| Agent detection fix | Check `NEXUS_TERMUX_ACCESSIBLE` before parent-defer | Existing self-contained detection in agents would set `NEXUS_ENV=linux` because `PREFIX`/`PROOT` absent in hybrid; the var flows through env.sh which is loaded by nexus-install.sh |
| Package manager priority | ACCESSIBLE > NEXUS_ENV=termux > default | Existing `NEXUS_ENV=termux` check in `install_via_apt` would miss proot+Termux hybrid; `ACCESSIBLE` captures hybrid condition explicitly |
| Shell config approach | Direct `[ -d ]` check (not env.sh var) | Shell configs are standalone — they don't source env.sh; also ensures PATH works before env.sh is sourced |

## Delta Specs Synced to Main Specs

| Domain | Action | Details |
|--------|--------|---------|
| `agent-install` | Merged (MODIFIED + ADDED) | Replaced "Environment-aware installation" requirement with hybrid-aware version (3 priority levels, 5 scenarios). Added "Agent installer NEXUS_ENV fix" requirement |
| `env-config` | Merged (2× ADDED) | Added "Termux accessibility detection" and "PATH unification" requirements with scenario tables |
| `install-bootstrap` | Merged (MODIFIED) | Enhanced "Environment detection before action" requirement with Termux bind-mount PATH block behavior and 2 new scenarios |
| `shell-bootstrap` | Created (NEW) | New domain spec covering Termux PATH in .bashrc/.zshrc |

## Task Completion

All 9 tasks were completed in order:

| Task | Description | Status |
|------|-------------|--------|
| TASK-001 | `config/env.sh` — NEXUS_TERMUX_ACCESSIBLE detection block | ✅ Complete |
| TASK-002 | `lib/nexus-install.sh` — install_via_pip/apt Termux-aware functions | ✅ Complete |
| TASK-003 | `modules/aider/install.sh` — detection fix + numpy via TERMUX_PKG | ✅ Complete |
| TASK-004 | `modules/fabric/install.sh` — detection fix | ✅ Complete |
| TASK-005 | `modules/sgpt/install.sh` — detection fix | ✅ Complete |
| TASK-006 | `shell/.bashrc` — Termux PATH block | ✅ Complete |
| TASK-007 | `shell/.zshrc` — Termux PATH block | ✅ Complete |
| TASK-008 | `install.sh` — hardcoded PATH with Termux bind-mount dirs | ✅ Complete |
| TASK-009 | Cleanup — hybrid comments, updated error messages | ✅ Complete |

## Verification Result

**Verdict**: PASS WITH WARNINGS
- **Tasks**: 9/9 complete
- **Syntax**: All 8 files pass `bash -n`
- **Scenarios verified**: 5 trace-based, 1 idempotency, 2 command selection paths, 1 detection flow
- **Spec compliance**: 18/19 scenarios COMPLIANT, 1 PARTIAL (spec documentation discrepancy, not functional)

**Warnings** (2, non-blocking):
1. `install-bootstrap` spec table says "No Termux entries" for missing bind-mount dirs, but code always writes guarded blocks for auto-activation — functionally correct, spec is slightly imprecise
2. `install-bootstrap` spec table uses shorthand `/usr/bin` instead of full `/data/data/com.termux/files/usr/bin` path — typing discrepancy, not a bug

**Critical issues**: None

## What Remains for Future

Nothing — this change is complete. No follow-up tasks, no open questions, no deferred work.

## Rollback Instructions

To revert this change, apply the inverse of each file:

1. **`config/env.sh`**: Remove lines 80–110 (the Termux accessibility detection block). Remove `NEXUS_TERMUX_ACCESSIBLE`, `TERMUX_BIN`, `TERMUX_PREFIX`, `TERMUX_PKG`, `TERMUX_PIP` exports and the PATH prepend block
2. **`lib/nexus-install.sh`**: In `install_via_pip()`, remove the `NEXUS_TERMUX_ACCESSIBLE` check (lines ~48–55), restoring original top-level `pip3 install --user`. In `install_via_apt()`, remove the `NEXUS_TERMUX_ACCESSIBLE` branch (lines ~118–125), restoring original `NEXUS_ENV=termux → pkg, else → apt` logic
3. **`modules/aider/install.sh`**: Remove `NEXUS_TERMUX_ACCESSIBLE` guard from detection block. Restore original numpy pre-install logic (apt-based). Revert error messages to pre-hybrid wording
4. **`modules/fabric/install.sh`**: Remove `NEXUS_TERMUX_ACCESSIBLE` guard from detection block
5. **`modules/sgpt/install.sh`**: Remove `NEXUS_TERMUX_ACCESSIBLE` guard from detection block
6. **`shell/.bashrc`**: Remove the Termux PATH block (the `[ -d "/data/data/com.termux/files/usr/bin" ]` section)
7. **`shell/.zshrc`**: Remove the Termux PATH block (same pattern as .bashrc)
8. **`install.sh`**: Remove the Termux bind-mount PATH entries from the hardcoded PATH blocks for both .bashrc and .zshrc

No structural changes were made — pure config revert. Rollback is safe at any point.

## Engram Artifact IDs

| Artifact | Observation ID |
|----------|---------------|
| spec | #231 |
| design | #232 |
| apply report | #233 |
| verify report | #234 |

## Archive Paths

- **Filesystem archive**: `openspec/changes/archive/2026-06-05-hybrid-install-strategy/`
- **Main specs updated**: `openspec/specs/agent-install/spec.md`, `openspec/specs/env-config/spec.md`, `openspec/specs/install-bootstrap/spec.md`, `openspec/specs/shell-bootstrap/spec.md`
