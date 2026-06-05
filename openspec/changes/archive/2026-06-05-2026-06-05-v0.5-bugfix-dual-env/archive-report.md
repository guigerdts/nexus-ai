# Archive Report — 2026-06-05-v0.5-bugfix-dual-env

**Archived**: 2026-06-05
**Change**: `2026-06-05-v0.5-bugfix-dual-env`
**Type**: Bugfix/Config
**Verdict**: ✅ PASS (all 4 bugfixes compliant, 6/6 tasks complete, 4/4 verification sub-tasks complete)

---

## 1. Summary

Fixed critical shell startup crash from auto `pip3 install rich` on every spawn, broken tool installs in `guide --interactive` (PATH-dependent `subprocess.run`), stderr leaks from `gum style`, and hardcoded PYTHONPATH that breaks on Termux.

### What Changed

| File | Change | Impact |
|------|--------|--------|
| `config/env.sh` | Dynamic PYTHONPATH via `site.getsitepackages()[0]`; removed pip auto-install; rich detection without pip call | Shell no longer crashes with `zvm_cursor_style` regex error on Termux |
| `tui/guide.py` | Absolute `nxai` path from `NEXUS_ROOT` via `os.path.join()`; `subprocess.run([nxai_bin, "install", name], ...)` list syntax | `guide --interactive` works when `$NEXUS_ROOT/bin` is not in PATH |
| `core/nexus.sh` | `2>/dev/null` on 4 `gum style` status lines (uninstall, TIMEOUT, PASS, FAIL) | No stderr leaks during tests |

---

## 2. Verification Result

**PASS** — No critical or warning issues.

| Metric | Value |
|--------|-------|
| Tasks total (implementation) | 6 |
| Tasks complete | 6 |
| Verification sub-tasks total | 4 |
| Verification sub-tasks complete | 4 |
| Static analysis (bash -n, py_compile) | 3/3 PASS |
| Proposal success criteria | 5/5 ✅ |
| Bugfix compliance checks | 16/16 ✅ |

---

## 3. Engram Artifact References

| Artifact | Observation ID | Topic Key |
|----------|---------------|-----------|
| Proposal | #216 | `sdd/2026-06-05-v0.5-bugfix-dual-env/proposal` |
| Tasks | #217 | `sdd/2026-06-05-v0.5-bugfix-dual-env/tasks` |
| Apply Progress | #218 | `sdd/2026-06-05-v0.5-bugfix-dual-env/apply-progress` |
| Verify Report | #219 | `sdd/2026-06-05-v0.5-bugfix-dual-env/verify-report` |

---

## 4. Delta Spec Sync

**Not applicable** — Pure bugfix/config change. No spec or design artifacts were created. No main specs required updating.

---

## 5. Files Changed

| File | Before | After |
|------|--------|-------|
| `config/env.sh` | Hardcoded `PYTHONPATH=/usr/local/lib/python3.13/...`; auto `pip3 install --break-system-packages --user rich` on every shell startup | Dynamic `PYTHONPATH` via `python3 -c "import site; print(site.getsitepackages()[0])"` with fallback; `NEXUS_RICH_AVAILABLE=false` via `python3 -c "import rich"` check (no pip call) |
| `tui/guide.py` | `subprocess.run(install_cmd.split(), timeout=300)` — PATH-dependent, breaks when `nxai` not in PATH | `NEXUS_ROOT` from `os.environ.get()`; absolute `nxai_bin = os.path.join(nexus_root, "bin", "nxai")`; `subprocess.run([nxai_bin, "install", name], timeout=300)` with guard for missing binary; `import os` added at top |
| `core/nexus.sh` | 4 `gum style` status lines (line 254, 340, 342, 344) without stderr redirect | `2>/dev/null` appended to all 4 lines; bonus: line 402 also got it (out of scope, beneficial) |

---

## 6. Final State

- [x] **All 6 implementation tasks complete** — verified by static analysis and runtime evidence
- [x] **All 4 verification sub-tasks complete** — no regressions
- [x] **Verdict: PASS** — no critical or warning issues
- [x] **No spec/design update needed** — pure bugfix
- [x] **Archived to**: `openspec/changes/archive/2026-06-05-2026-06-05-v0.5-bugfix-dual-env/`

The change is fully planned, implemented, verified, and archived. Ready for the next change.
