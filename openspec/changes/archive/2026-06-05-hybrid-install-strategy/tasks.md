# Tasks: Hybrid Install Strategy — Termux Bind-Mount Integration

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | ~100–120 |
| 400-line budget risk | Low |
| Chained PRs recommended | No |
| Suggested split | Single PR |
| Delivery strategy | ask-on-risk |
| Chain strategy | pending |

Decision needed before apply: No
Chained PRs recommended: No
Chain strategy: pending
400-line budget risk: Low

### Suggested Work Units

| Unit | Goal | Likely PR | Notes |
|------|------|-----------|-------|
| 1 | Full hybrid install strategy — env.sh detection, nexus-install.sh Termux awareness, agent detection fixes, PATH blocks, cleanup | PR 1 | Single PR — under 120 lines across 8 files, no chain needed |

## Phase 1: Foundation — Detection Mechanism

- [x] **TASK-001**: Add Termux accessibility detection to `config/env.sh`

  - **Scope**: `config/env.sh` — insert block after line 78 (end of NEXUS_ENV detection), before architecture detection
  - **Prerequisites**: None
  - **Dependencies**: Termux constants (TERMUX_BIN, TERMUX_PREFIX, etc.)
  - **Acceptance**: `NEXUS_TERMUX_ACCESSIBLE=true` when TERMUX_BIN is executable AND NEXUS_ENV=proot-ubuntu; `false` on linux/termux native. Termux bin dirs prepended to PATH with `case` idempotency guard.
  - **Estimate**: ~15 lines added
  - **Verification**: `source config/env.sh && echo $NEXUS_TERMUX_ACCESSIBLE` in each environment

## Phase 2: Core Install Library — Termux-Aware Functions

- [x] **TASK-002**: Make `install_via_pip` prefer `TERMUX_PIP` and `install_via_apt` map to `TERMUX_PKG`

  - **Scope**: `lib/nexus-install.sh` — modify `install_via_pip()` (lines 48–88) and `install_via_apt()` (lines 118–133)
  - **Prerequisites**: TASK-001 (needs NEXUS_TERMUX_ACCESSIBLE var)
  - **Dependencies**: env.sh exports TERMUX_PIP, TERMUX_PKG, TERMUX_BIN
  - **Acceptance**: When `NEXUS_TERMUX_ACCESSIBLE=true`, `install_via_pip` uses `TERMUX_PIP install --user`; `install_via_apt` uses `TERMUX_PKG install -y`. Fallback to system pip3/apt when `false`.
  - **Estimate**: ~25 lines changed (two functions)
  - **Verification**: Set `NEXUS_TERMUX_ACCESSIBLE=true`, source nexus-install.sh, call `install_via_pip` and `install_via_apt` — assert TERMUX_PIP/TERMUX_PKG commands are invoked

## Phase 3: Agent Installers — Hybrid Detection Fix

- [x] **TASK-003**: Fix `modules/aider/install.sh` to check `NEXUS_TERMUX_ACCESSIBLE` before parent-defer in detection block, and use `TERMUX_PKG install python-numpy` for numpy pre-install

  - **Scope**: `modules/aider/install.sh` — detection block (lines 15–24) + numpy block (lines 40–56)
  - **Prerequisites**: TASK-001
  - **Dependencies**: NEXUS_TERMUX_ACCESSIBLE must be set by env.sh (loaded via nexus-install.sh line 23)
  - **Acceptance**: In proot+Termux, detection does NOT set NEXUS_ENV=linux; numpy pre-install uses `TERMUX_PKG install python-numpy` instead of `apt install python3-numpy`
  - **Estimate**: ~15 lines changed
  - **Verification**: Dry-run the installer with mocked NEXUS_TERMUX_ACCESSIBLE=true — assert pkg command used for numpy, NEXUS_ENV stays proot-ubuntu

- [x] **TASK-004**: Fix `modules/fabric/install.sh` detection for hybrid mode

  - **Scope**: `modules/fabric/install.sh` — detection block (lines 13–22)
  - **Prerequisites**: TASK-001
  - **Dependencies**: Same as TASK-003 (NEXUS_TERMUX_ACCESSIBLE flows through nexus-install.sh)
  - **Acceptance**: In proot+Termux, detection does NOT set NEXUS_ENV=linux; defers to parent env
  - **Estimate**: ~8 lines changed
  - **Verification**: Same detection test as TASK-003

- [x] **TASK-005**: Fix `modules/sgpt/install.sh` detection for hybrid mode

  - **Scope**: `modules/sgpt/install.sh` — detection block (lines 13–22)
  - **Prerequisites**: TASK-001
  - **Dependencies**: Same as TASK-003
  - **Acceptance**: Same pattern as TASK-004 for sgpt
  - **Estimate**: ~8 lines changed
  - **Verification**: Same detection test as TASK-003

## Phase 4: PATH Configuration — Termux Directories

- [x] **TASK-006**: Add Termux bind-mount PATH block to `shell/.bashrc`

  - **Scope**: `shell/.bashrc` — insert after line 29 (end of NEXUS_ROOT/bin PATH guard)
  - **Prerequisites**: None (uses direct `[ -d "$dir" ]` check, not env.sh var)
  - **Dependencies**: Termux dir layout
  - **Acceptance**: When `/data/data/com.termux/files/usr/bin` exists, TERMUX_BIN and TERMUX_PREFIX/local/bin are prepended to PATH. Idempotent on re-source.
  - **Estimate**: ~10 lines added
  - **Verification**: Source .bashrc with mocked dir — assert Termux dirs in PATH; source twice — assert no duplicates

- [x] **TASK-007**: Add Termux bind-mount PATH block to `shell/.zshrc`

  - **Scope**: `shell/.zshrc` — insert after line 31 (PATH export line)
  - **Prerequisites**: None (direct dir check)
  - **Dependencies**: Same as TASK-006
  - **Acceptance**: Same as TASK-006 for Zsh
  - **Estimate**: ~10 lines added
  - **Verification**: Same as TASK-006 with Zsh

- [x] **TASK-008**: Add Termux bind-mount dirs to `install.sh` hardcoded PATH block

  - **Scope**: `install.sh` — lines 514–524 (.bashrc PATH block) and lines 528–540 (.zshrc PATH block)
  - **Prerequisites**: None (direct dir check at install time)
  - **Dependencies**: Same dir check pattern as TASK-006
  - **Acceptance**: When Termux bind-mount dir exists at install time, the hardcoded PATH block in .bashrc/.zshrc includes Termux bin dirs
  - **Estimate**: ~12 lines added (6 per shell block)
  - **Verification**: Run install.sh in proot+Termux — assert generated PATH block contains Termux dirs

## Phase 5: Cleanup

- [x] **TASK-009**: Update legacy numpy `--no-build` comments and docs referencing old detection

  - **Scope**: `modules/aider/install.sh` — numpy comment block (lines 36–39) and fallback error messages (lines 150–153). Also `modules/fabric/install.sh` and `modules/sgpt/install.sh` error tips
  - **Prerequisites**: TASK-003, TASK-004, TASK-005
  - **Dependencies**: None
  - **Acceptance**: Comments reference hybrid strategy instead of "Termux vs proot" binary. Error messages mention TERMUX_PKG as option.
  - **Estimate**: ~5 lines changed
  - **Verification**: `grep -r "no-build" modules/` returns no stale references

## Implementation Order

1. **TASK-001** first — foundation, all others depend on it structurally
2. **TASK-002** second — consumers need Termux-aware pip/apt functions
3. **TASK-003 → TASK-004 → TASK-005** in parallel or sequential — agent detection fixes (identical pattern)
4. **TASK-006 → TASK-007 → TASK-008** in parallel — PATH blocks (no deps on each other)
5. **TASK-009** last — cleanup after all detection fixes are landed

Parallel-friendly groups: {T-003, T-004, T-005} and {T-006, T-007, T-008} can be done in any order within group. T-002 must follow T-001. T-009 must follow T-003/4/5.
