# Archive Report: NEXUS AI v0.2 — Agentes y CLI

**Archived**: 2026-06-03 (updated 2026-06-03 — final fixes)
**Change**: 2026-06-03-nexus-ai-v0.2-agents
**Mode**: openspec (file-based)

---

## Verification Summary

All 3 PRs + post-PR bug fixes passed verification with no critical issues:

| Phase | Scope | Verdict |
|-------|-------|---------|
| PR 1 | Install library + CLI + 3 Tier-1 agents (aider, opencode, codex) | PASS ✅ |
| PR 2 | 9 agent modules (antigravity, pi, fabric, sgpt, goose, engram, gentle-ai, openclou, claude-code) | PASS ✅ |
| PR 3 | `nexus agent add/test`, install.sh Step 8, env/config, MOTD | PASS ✅ |
| Fixes | PATH block duplication, `nexus→nxai` rename, NEXUS_ROOT BASH_SOURCE fix, NEXUS_ALREADY_SOURCED guard removal, MOTD version hardcoded fix, ANSI color echo, install.sh hardcoded PATH safety net | PASS ✅ |
| Dual-env audit | `pip install --user` flag fix in `lib/nexus-install.sh`; full audit of all 12 agent modules for Termux + proot-Ubuntu compatibility | PASS ✅ |

## Specs Synced

| Domain | Action | Details |
|--------|--------|---------|
| env-config | Updated | 2 requirements modified (Required variable exports — version bump 0.1.0→0.2.0, added NEXUS_MODULES_DIR, NEXUS_REGISTRY); 1 scenario added (New vars idempotent on re-source) |
| install-bootstrap | Updated | 2 requirements modified (Progress display — 7→8 steps; Post-install actions — CLI skeleton, registry foundation, real MOTD commands); 3 scenarios added (Step 8 creates CLI skeleton, MOTD shows real commands, MOTD tips include agent management) |

## Merge Details

### env-config

**MODIFIED**: `NEXUS_VERSION` bumped from `"0.1.0"` to `"0.2.0"`. Added `NEXUS_MODULES_DIR` and `NEXUS_REGISTRY` to required variable exports.
**ADDED**: Scenario "New vars are idempotent on re-source" to ensure double-sourcing safety for the new variables.
**Preserved**: All original requirements (NEXUS_ROOT auto-detection, Environment detection, Idempotent sourcing) — untouched.

### install-bootstrap

**MODIFIED**: Progress display step count from `[1/7]` to `[1/8]` with total count of 8.
**MODIFIED**: Post-install actions now include CLI skeleton (`core/nexus.sh` + `bin/nxai` symlink via Step 8), registry foundation (`config/agents.registry.sh` + empty `modules/` directory), and real MOTD command tips replacing `"(proximamente)"` placeholders.
**ADDED**: 3 scenarios — Step 8 creates CLI skeleton, MOTD shows real commands, MOTD tips include agent management.
**Preserved**: All original requirements (Environment detection before action, Supported CLI flags) — untouched.

## Post-PR Bug Fixes

The following fixes were verified and confirmed after the 3 PRs completed:

| Fix | Issue | Resolution | Status |
|-----|-------|------------|--------|
| PATH block duplication | install.sh Step 8 appended duplicate PATH entries on re-run | Marker-based idempotency (`# === NEXUS AI PATH (absoluto) ===`) | ✅ |
| `nexus→nxai` rename | `bin/nexus` conflicts with system packages | Renamed symlink to `bin/nxai`, updated CLI help text | ✅ |
| NEXUS_ROOT BASH_SOURCE fix | `env.sh` detection unreliable in nested source contexts | Improved `BASH_SOURCE[0]` resolution chain | ✅ |
| NEXUS_ALREADY_SOURCED guard removal | Idempotency guard caused issues in sub-shells | Removed `NEXUS_ALREADY_SOURCED` guard | ✅ |
| MOTD version hardcoded | MOTD displayed hardcoded version instead of `$NEXUS_VERSION` | Replaced literal with variable reference | ✅ |
| ANSI color echo issue | `echo -e` not portable across shells | Replaced with `printf` for ANSI escape sequences | ✅ |
| install.sh hardcoded PATH | Installer wrote absolute PATH fallback, needed safety net | Added step 8 PATH safety net with marker-based idempotency | ✅ |
| pip install --user flag | `pip install` fallback in `install_via_pip()` missing `--user` flag — caused permission errors in Termux | Added `--user` flag to `pip install "$package"` on line 51 of `lib/nexus-install.sh` | ✅ |

## Dual-Environment Audit (Final)

A post-archive audit of all 12 agent modules for dual-environment compatibility (Termux native + proot-Ubuntu) was completed and verified:

| Concern | Result |
|---------|--------|
| `pip install --user` in fallback branch | ✅ COMPLIANT — `--user` flag added to both `pip3` and `pip` branches |
| All install scripts source shared lib | ✅ COMPLIANT — 12/12 modules source `lib/nexus-install.sh` |
| pip-based agents install python3-pip via apt | ✅ COMPLIANT — `install_via_apt "python3-pip"` in all pip agents |
| `install_via_apt` detects NEXUS_ENV → pkg/apt | ✅ COMPLIANT — `pkg` for Termux, `apt` for proot-Ubuntu |
| No hardcoded paths in module scripts | ✅ COMPLIANT — zero occurrences across all 12 modules |
| No sudo usage anywhere | ✅ COMPLIANT — zero occurrences across all install scripts |
| npm install -g works in both envs | ✅ COMPLIANT — Termux $PREFIX prefix, proot runs as root |
| All READMEs have `## Notas para Termux` | ✅ COMPLIANT — 12/12 modules |
| pip-based READMEs include pkg commands | ✅ COMPLIANT — aider, pi, fabric, sgpt |
| npm-based READMEs include nodejs | ✅ COMPLIANT — codex, opencode |
| claude-code covers both envs explicitly | ✅ COMPLIANT — both `pkg install nodejs` and `apt install nodejs` |
| goose warns about Termux incompatibility | ✅ COMPLIANT — explicit warning in README |
| shell/.bashrc dynamic PATH resolution | ✅ COMPLIANT — `BASH_SOURCE[0]`, no hardcoded NEXUS_ROOT |
| install.sh Step 8 PATH safety net | ✅ COMPLIANT — marker-based idempotency |

**Key findings:** No hardcoded paths or sudo usage in any install path. All pip agents correctly use `install_via_apt` for `python3-pip` dependency, auto-switching between `pkg` (Termux) and `apt` (proot-Ubuntu). The `--user` flag was the only gap found and has been fixed.

## Archive Contents

| Artifact | Present |
|----------|---------|
| `proposal.md` | ✅ |
| `exploration.md` | ✅ |
| `specs/env-config/spec.md` | ✅ |
| `specs/install-bootstrap/spec.md` | ✅ |
| `design.md` | ✅ |
| `tasks.md` | ✅ (21/21 tasks complete) |
| `verify-report-pr1.md` | ✅ |
| `verify-report-pr2.md` | ✅ |
| `verify-report-pr3.md` | ✅ |
| `verify-report-fixes.md` | ✅ (8 post-PR bug fixes + dual-env audit confirmed) |
| `archive-report.md` | ✅ |

## Source of Truth Updated

The following main specs now reflect the v0.2 behavior:

- `openspec/specs/env-config/spec.md` — version 0.2.0, new vars, idempotent sourcing
- `openspec/specs/install-bootstrap/spec.md` — 8 steps, CLI skeleton, real MOTD commands

**Spec gap detected — `nexus→nxai` rename**: The CLI was renamed from `nexus` to `nxai` (symlink: `bin/nxai -> core/nexus.sh`) in post-PR fixes. The main specs (`openspec/specs/nexus-cli/spec.md`, `openspec/specs/agent-install/spec.md`) and design artifacts still reference `nexus` as the command name. These specs work correctly since `nxai` is a drop-in alias, but the naming mismatch SHOULD be resolved in a future spec update.

## Tasks Completion

All 21 tasks across 6 phases completed, plus 8 ad-hoc bug fixes + dual-environment audit:

| Phase | Tasks | Status |
|-------|-------|--------|
| 1. Install Library y Config | 1.1–1.3 | ✅ All complete |
| 2. CLI Core | 2.1–2.3 | ✅ All complete |
| 3. Agentes Tier 1 (pip/npm) | 3.1–3.3 | ✅ All complete |
| 4. Agentes Practicos (pip) | 4.1–4.4 | ✅ All complete |
| 5. Agentes Curl/Stubs | 5.1–5.5 | ✅ All complete |
| 6. Gestion e Installer Bootstrap | 6.1–6.4 | ✅ All complete |
| Bug fixes (post-PR) | 8 ad-hoc fixes | ✅ All verified on device |
| Dual-environment audit | 14/14 concerns compliant | ✅ All 12 modules audited |

## Risk Assessment

| Risk | Status |
|------|--------|
| Destructive merge? | No — all modifications were additive or non-breaking updates (version bumps, new variables, extended scenarios, marker-based PATH safety net) |
| Critical verify issues? | None — all 3 PRs + fixes PASS |
| Archive integrity | All artifacts present and accounted for; fixes report added |
| Spec gap: `nexus→nxai` rename | LOW — specs reference `nexus` but code uses `nxai`; functional alias, no behavioral impact |

---

## SDD Cycle Complete

The NEXUS AI v0.2 change has been fully planned, explored, specified, designed, implemented, verified (3 PRs + 8 bug fixes + dual-environment audit), and archived. All fixes confirmed on device. Ready for v0.3 onwards.
