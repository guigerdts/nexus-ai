# Proposal: Fix bugs in system_status, test.sh scripts, and install/manifest helpers

## Intent

Resolve 9 confirmed bugs (1 critical, 3 high, 4 medium, 1 low) that cause incorrect agent counts, hanging `nxai status`, false PASS on missing binaries, broken uninstalls, PYTHONPATH bloat, and dead code — without changing any command behavior.

## Scope

### In Scope
1. `core/nexus.sh` — `system_status()`: add `unset AGENT_*` guard, wrap test.sh with `timeout`, add manifest check for accurate counts
2. `core/nexus.sh` — `list_agents()` is already correct (fixed previously); verify no regression
3. `modules/claude-code/test.sh` — fix `||`/`&&` precedence so `exit 1` actually fires when binary is missing
4. `lib/nexus-install.sh` — `install_via_curl()`: check curl exit code before piping to bash
5. `lib/nexus-install.sh` — `update_installed_manifest remove`: escape regex special chars in `sed` pattern
6. `modules/codex/test.sh` — remove unconditional `exit 1`; add platform guard
7. `config/env.sh` — deduplicate PYTHONPATH append with `case` guard
8. `modules/termux-styling/test.sh` — remove dead `-z "$BINARY"` check
9. `config/agents.registry.sh` — `registry_list()`: add `unset AGENT_*` before source loop

### Out of Scope
- Shared function extraction for the `unset AGENT_*` pattern (higher risk — deferred)
- Adding shell test framework or test runner
- Refactoring `system_status()` into smaller functions
- Any feature work beyond bugfixes

## Capabilities

### New Capabilities
None — pure bugfix change.

### Modified Capabilities
None — all fixes align implementation with existing spec requirements. No spec-level behavior change.

## Approach

| Bug | File | Fix |
|-----|------|-----|
| 1 (Critical) | `core/nexus.sh` | Add `for key in "${!AGENT_@}"; do unset "$key"; done` before each `source metadata.sh` in `system_status()` |
| 2 (High) | `modules/claude-code/test.sh` | Wrap in `if ! command -v claude-code &>/dev/null; then echo "..."; exit 1; fi` with proper `||` chain |
| 3 (High) | `lib/nexus-install.sh` | `curl -fsSL "$url" \| bash || return $?` — curl must succeed before piping |
| 4 (Medium) | `core/nexus.sh` | Wrap test.sh call with `timeout 30`; add manifest lookup via `grep -qxF "$agent" "$INSTALLED_MANIFEST"` for count |
| 5 (Medium) | `modules/codex/test.sh` | Guard with `command -v codex || exit 1` like other test.sh scripts; remove bare `exit 1` |
| 6 (Medium) | `lib/nexus-install.sh` | Escape `/` in agent name with `sed -i "/^$(sed 's/[^^]/[&]/g; s/\^/\\^/g' <<< "$agent")$/d"` or use `grep -vxF` + temp file |
| 7 (Medium) | `config/env.sh` | Add `case ":$PYTHONPATH:" in *:"$VENV_PATH":*) ;; *) ... ;; esac` guard before append |
| 8 (Low) | `modules/termux-styling/test.sh` | Remove `[ -z "$BINARY" ]` block — BINARY is hardcoded non-empty |
| 9 (Low) | `config/agents.registry.sh` | Add `unset AGENT_*` before source loop in `registry_list()` — same pattern as `list_agents()` |

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `core/nexus.sh` | Modified | `system_status()` — 3 fixes: unset guard, timeout, manifest check |
| `modules/claude-code/test.sh` | Modified | Fix operator precedence causing false PASS |
| `lib/nexus-install.sh` | Modified | `install_via_curl()` error check, `update_installed_manifest()` regex escape |
| `modules/codex/test.sh` | Modified | Replace unconditional exit 1 with platform guard |
| `config/env.sh` | Modified | Deduplicate PYTHONPATH on re-source |
| `modules/termux-styling/test.sh` | Modified | Remove dead code branch |
| `config/agents.registry.sh` | Modified | `registry_list()` — add unset guard |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| `timeout 30` in system_status breaks agents with slow test.sh | Low | Timeout is generous (30s). No agent test.sh takes >5s currently. |
| sed regex escape in manifest remove fails edge case | Low | Use `grep -vxF` + temp file instead — simpler, no regex issues. |
| Any fix accidentally changes `nxai status/list/install/remove` output | Low | Each fix is a single-line change. Verify output matches before/after. |

## Rollback Plan

Revert each file independently with `git checkout HEAD -- <file>`. Since each fix is isolated to one file per bug, rollback is per-bug, not all-or-nothing. Test rollback with: `nxai status` (accurate counts), `nxai doctor` (no new warnings), `nxai list` (three states unchanged).

## Dependencies

None — all fixes purely within existing shell/bash codebase.

## Success Criteria

- [ ] `nxai status` shows correct agent counts matching `nxai list`
- [ ] `nxai status` completes within 30s regardless of module test.sh behavior
- [ ] `claude-code test.sh` returns 1 when claude-code is missing
- [ ] `codex test.sh` returns 0 when codex is missing (stub behavior), 1 when installed+broken
- [ ] `install_via_curl` propagates curl failure (non-zero exit)
- [ ] `nxai remove <agent>` with special-char names succeeds (e.g. `agent-cli`)
- [ ] `config/env.sh` sourced 3× in same shell: PYTHONPATH has no duplicates
- [ ] `registry_list()` shows no cross-module metadata leaks (verified with `AGENT_DEPRECATED` test)
