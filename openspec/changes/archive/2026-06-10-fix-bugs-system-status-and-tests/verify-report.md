# Verification Report

**Change**: fix-bugs-system-status-and-tests
**Version**: N/A (no versioned spec — proposal-driven)
**Mode**: Standard Mode (strict_tdd disabled)

## Completeness

| Metric | Value |
|--------|-------|
| Tasks total | 11 (9 core + 2 implicit scope-extended) |
| Tasks complete | 9 of 9 core tasks |
| Tasks incomplete | 0 |
| Syntax checks | 7/7 passed (bash -n on all modified files) |

### Task-by-Task Status

| Task | Status | Verification |
|------|--------|-------------|
| 1.1 system_status() — unset AGENT_* loop | ✅ Done | Explicit `unset` of 12 AGENT_* vars before `source metadata.sh` (line 635-638) |
| 1.2 system_status() — timeout 30 on test.sh | ✅ Done | `timeout 30 bash "$_dir/test.sh"` at line 645 |
| 1.3 system_status() — manifest check (grep -qxF) | ✅ Done | `grep -qxF "$_name" "$NEXUS_ROOT/logs/installed.txt"` on BOTH binary AND test.sh paths (lines 642, 646) |
| 2.1 claude-code/test.sh — precedence fix | ✅ Done | `command -v claude-code &>/dev/null \|\| { echo "..."; exit 1; }` |
| 2.2 codex/test.sh — platform guard | ✅ Done | arm64 → exit 0, otherwise `command -v codex \|\| exit 1` |
| 2.3 termux-styling/test.sh — dead code removed | ✅ Done | `-z "$BINARY"` removed, straight to `command -v` |
| 3.1 install_via_curl() — error propagation | ⚠️ Partial | `\|\| return $?` added, but uses process substitution (not pipe) — see WARNING #1 |
| 3.2 manifest remove — grep -vxF + temp file | ✅ Done | `grep -vxF "$agent" "$manifest" > "${manifest}.tmp" && mv ...` |
| 4.1 env.sh — PYTHONPATH dedup | ✅ Done | `case ":$PYTHONPATH:" in *:"$_python_site":*) ;; *) export ... ;; esac` |
| 4.2 registry_list() — unset guard | ✅ Done | `unset` block before `source "$_meta"` at lines 153-156 |

### Scope-Extended Changes (not in tasks, all positive/alignment)

| Change | Files | Notes |
|--------|-------|-------|
| test.sh priority in list_agents() | `core/nexus.sh` lines 167-175, 232-240 | test.sh now authoritative before binary check for both display paths |
| timeout 10 on test.sh in list_agents() | `core/nexus.sh` lines 170, 237 | Prevents hanging in detection |
| timeout 3 on --version calls | 7 modules (codegraph, minimax-cli, mistral-vibe, openclaude, openclaw, pi, qwen-code) | Prevents hanging binaries from blocking |
| mongodb/test.sh rewrite | `modules/mongodb/test.sh` | Removed dead `-z "$BINARY"`, added `timeout 2`, proper pass/fail messages |

## Syntax & Build Evidence

**Build**: ✅ All 7 files pass `bash -n` syntax check

```text
$ bash -n core/nexus.sh           → exit 0
$ bash -n modules/claude-code/test.sh → exit 0
$ bash -n modules/codex/test.sh   → exit 0
$ bash -n modules/termux-styling/test.sh → exit 0
$ bash -n lib/nexus-install.sh    → exit 0
$ bash -n config/env.sh           → exit 0
$ bash -n config/agents.registry.sh → exit 0
```

**Tests**: ➖ No test suite (bash/Termux project) — verified by static analysis and reasoning.

**Coverage**: ➖ Not available

## Spec Compliance Matrix

No versioned spec file exists for this change — verification against proposal requirements.

| Proposal Requirement | Implementation Evidence | Status |
|---------------------|------------------------|--------|
| `system_status()` unset AGENT_* loop before source | Lines 634-638: explicit `unset` of 12 vars | ✅ COMPLIANT |
| `system_status()` timeout 30 on test.sh | Line 645: `timeout 30 bash "$_dir/test.sh"` | ✅ COMPLIANT |
| `system_status()` manifest check on BOTH paths | Lines 642, 646: `grep -qxF` on binary AND test.sh paths | ✅ COMPLIANT |
| claude-code/test.sh: fix `\|\|`/`&&` precedence | `cmd &>/dev/null \|\| { ... exit 1; }` | ✅ COMPLIANT |
| codex/test.sh: NEXUS_ARCH guard + remove bare exit 1 | arm64 guard + `command -v codex \|\| exit 1` | ✅ COMPLIANT |
| termux-styling/test.sh: remove dead `-z "$BINARY"` | No `-z` check present | ✅ COMPLIANT |
| install_via_curl(): curl exit propagation | `\|\| return $?` added (process substitution — see WARNING) | ⚠️ PARTIAL |
| manifest remove: grep -vxF + temp file | `grep -vxF "$agent" "$manifest" > "${manifest}.tmp" && mv ...` | ✅ COMPLIANT |
| env.sh PYTHONPATH: case dedup guard | `case ":$PYTHONPATH:" in *:"$_python_site":*) ;; *) export ... ;; esac` | ✅ COMPLIANT |
| registry_list(): unset AGENT_* before source | Lines 153-156: explicit unset before `source "$_meta"` | ✅ COMPLIANT |
| `list_agents()` no regression | test.sh priority, timeout 10 — consistent with system_status | ✅ COMPLIANT |

**Compliance summary**: 10/11 requirements compliant, 1 partial.

## Correctness (Static Evidence)

| Requirement | Status | Notes |
|------------|--------|-------|
| system_status unset AGENT_* | ✅ Implemented | Uses explicit `unset` of 12 vars — functionally equivalent to `${!AGENT_@}` loop |
| system_status timeout 30 | ✅ Implemented | `timeout 30 bash "$_dir/test.sh"` on test.sh path |
| system_status manifest check | ✅ Implemented | Both binary and test.sh paths check manifest before counting |
| claude-code precedence | ✅ Implemented | Proper `\|\|` chain with `{ }` group, exit 1 on missing |
| codex platform guard | ✅ Implemented | arm64 → exit 0 (skip), x86_64 → check binary |
| termux-styling dead code | ✅ Implemented | `-z "$BINARY"` removed entirely |
| install_via_curl error check | ⚠️ See WARNING #1 | `\|\| return $?` present but process substitution undermines it |
| manifest remove regex safety | ✅ Implemented | `grep -vxF` — no regex injection possible |
| PYTHONPATH dedup | ✅ Implemented | Case guard before export, same pattern as existing PATH guard |
| registry_list unset guard | ✅ Implemented | Same 12-variable unset before source |

## Coherence (Design)

| Decision | Followed? | Notes |
|----------|-----------|-------|
| system_status: unset before source via `${!AGENT_@}` loop | ⚠️ Divergent | Explicit unset of 12 vars instead of loop. Functionally equivalent but less future-proof |
| timeout 30 on test.sh in system_status | ✅ Yes | Correct, generous timeout (no agent test.sh takes >5s) |
| Manifest check via `grep -qxF` | ✅ Yes | Correct — `-x` for whole-line, `-F` for no-regex, `-q` for silent |
| claude-code: `if ! command -v` pattern | ⚠️ Divergent | Uses `\|\| { ... }` instead of `if !` — semantically equivalent |
| codex: NEXUS_ARCH guard | ✅ Yes | Proper pattern: `exit 0` for skip, `exit 1` on missing |
| Manifest remove: grep -vxF + temp file | ✅ Yes | Matches proposal mitigation exactly — avoids sed regex issues |
| env.sh PYTHONPATH: case guard same pattern as PATH | ✅ Yes | Identical `case ":$VAR:" in *:"$VAL":*) ;; *) ... ;; esac` pattern |
| manifest path: `"$NEXUS_ROOT/logs/installed.txt"` | ✅ Yes | Matches existing installed.txt convention |

### Design Coherence Summary: 7/9 fully aligned, 2 minor divergences

## Issues Found

**CRITICAL**: None

**WARNING**:

1. **install_via_curl() — process substitution prevents error propagation** (`lib/nexus-install.sh` line 162)
   - **What**: `bash <(curl -fsSL "$url") || return $?` uses process substitution, not a pipe.
   - **Why it fails**: When curl fails (network down, 404 with `-f`), the process substitution `<(...)` produces empty stdout. `bash` reads an empty script and exits **0**. The `|| return $?` never fires because `$?` is 0.
   - **Impact**: A failed curl silently installs nothing, instead of returning non-zero and allowing `install_via_curl`'s caller to handle the error.
   - **Fix**: Change to `curl -fsSL "$url" | bash || return $?`. With `set -o pipefail` (active from `nexus.sh`), this would propagate curl's exit code correctly.
   - **Evidence**: `git diff` shows the change added `|| return $?` to the process substitution form; the proposal explicitly used pipe syntax (`curl -fsSL "$url" \| bash \|\| return $?`).

2. **system_status() — missing AGENT_BINARY="none" + manifest case** (`core/nexus.sh` lines 641-648)
   - **What**: `system_status()` does not count modules with `AGENT_BINARY="none"` + in-manifest as installed, while `list_agents()` does (lines 173-174).
   - **Impact**: 13 modules have `AGENT_BINARY="none"` (banner, better-npm, nerd-fonts, powerlevel10k, zsh-* plugins, etc.). 12 of these have test.sh, so they're counted via the `elif` path anyway. However, `cursor` has no test.sh — it would be miscounted if ever in the manifest.
   - **Severity**: Low in practice (only `cursor` affected, which has no test.sh and BINARY="none").
   - **Fix**: Add `elif [ "${AGENT_BINARY:-}" = "none" ] && grep -qxF "$_name" "$NEXUS_ROOT/logs/installed.txt" &>/dev/null; then installed_count=$((installed_count + 1)); fi`

**SUGGESTION**:

1. **Redundant stderr redirect** (`core/nexus.sh` line 645)
   - `timeout 30 bash "$_dir/test.sh" &>/dev/null 2>&1` — `&>/dev/null` already covers stderr. The `2>&1` is redundant. Remove `2>&1`.
   - Impact: None (cosmetic).

2. **Explicit `unset` vs `${!AGENT_@}` loop** (multiple files)
   - Three unset blocks (system_status, registry_list, registry init loop) use explicit 12-variable lists. The proposal suggested `${!AGENT_@}` loop which is future-proof.
   - Impact: If a new AGENT_* variable is added to metadata.sh in the future, these unset blocks won't catch it.
   - Consider extracting to a shared helper: `_unset_agent_vars() { for key in "${!AGENT_@}"; do unset "$key"; done; }`.

3. **Scope-extended changes not tracked in tasks**
   - 7 modules got `timeout 3` additions to their test.sh `--version` calls (codegraph, minimax-cli, mistral-vibe, openclaude, openclaw, pi, qwen-code).
   - `mongodb/test.sh` was fully rewritten.
   - `list_agents()` got implicit behavioral changes (test.sh priority, timeout 10).
   - All aligned with the bugfix intent, but should be documented in tasks for auditability.

## Verdict

**PASS WITH WARNINGS**

Two actionable warnings found: `install_via_curl()` error propagation is incomplete (process substitution prevents `||` from catching curl failures), and `system_status()` lacks the `AGENT_BINARY="none"` in-manifest case (low impact — only 1 module affected in edge case). No critical issues. All 9 core tasks implemented. Syntax clean. Scope-extended changes are aligned with the proposal's intent.

## Post-Verification Fixes (applied before archive)

Both WARNING issues were resolved before archiving:

1. ✅ **install_via_curl()** — Changed `bash <(curl -fsSL "$url") || return $?` to `curl -fsSL "$url" | bash || return $?` (`lib/nexus-install.sh:162`). With `set -o pipefail` active from `nexus.sh`, curl failures now propagate correctly.
2. ✅ **system_status() AGENT_BINARY="none"** — Added `elif [ "${AGENT_BINARY:-}" = "none" ] && grep -qxF "$_name" "$NEXUS_ROOT/logs/installed.txt"` before the test.sh path (`core/nexus.sh:645-646`). Modules like `cursor` now count when manifested even without a binary or test.sh.

Both files pass `bash -n` syntax check.
