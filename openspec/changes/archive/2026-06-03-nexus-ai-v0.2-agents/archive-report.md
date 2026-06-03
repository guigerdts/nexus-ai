# Archive Report: NEXUS AI v0.2 — Agentes y CLI

**Archived**: 2026-06-03 (updated 2026-06-03 — final fixes; re-opened for BUG 8 + BUG 9 + symlink fix)
**Change**: 2026-06-03-nexus-ai-v0.2-agents
**Mode**: openspec (file-based)

---

## Verification Summary

All 3 PRs + post-PR bug fixes + post-archive fixes passed verification with no critical issues. Production verification confirmed the curl|bash installer works end-to-end:

| Phase | Scope | Verdict |
|-------|-------|---------|
| PR 1 | Install library + CLI + 3 Tier-1 agents (aider, opencode, codex) | PASS ✅ |
| PR 2 | 9 agent modules (antigravity, pi, fabric, sgpt, goose, engram, gentle-ai, openclou, claude-code) | PASS ✅ |
| PR 3 | `nexus agent add/test`, install.sh Step 8, env/config, MOTD | PASS ✅ |
| Fixes | PATH block duplication, `nexus→nxai` rename, NEXUS_ROOT BASH_SOURCE fix, NEXUS_ALREADY_SOURCED guard removal, MOTD version hardcoded fix, ANSI color echo, install.sh hardcoded PATH safety net | PASS ✅ |
| Dual-env audit | `pip install --user` flag fix in `lib/nexus-install.sh`; full audit of all 12 agent modules for Termux + proot-Ubuntu compatibility | PASS ✅ |
| Post-archive BUG 8 | `curl|bash` remote install — added detection block, clone + re-execute, supports `--dir` and `--help` | PASS ✅ |
| Post-archive BUG 9 | `BASH_SOURCE[0]` unset in pipe mode — rewritten detection for all 3 pipe variants (unset, /dev/fd/*, /dev/stdin), runs BEFORE `set -u` | PASS ✅ |
| Symlink fix | `bin/nxai` absolute → relative (`../core/nexus.sh`); Step 8 changed from `[ ! -f ]` guard to unconditional `ln -sf` | PASS ✅ |
| Production verification | `curl -fsSL https://raw.githubusercontent.com/guigerdts/nexus-ai/main/install.sh | bash -s -- --no-zsh --no-starship --no-motd --dir ~/nexus-test` — full install succeeds, 12 agents, PATH safety net, all correct | PASS ✅ |

## Specs Synced

| Domain | Action | Details |
|--------|--------|---------|
| env-config | Updated | 2 requirements modified (Required variable exports — version bump 0.1.0→0.2.0, added NEXUS_MODULES_DIR, NEXUS_REGISTRY); 1 scenario added (New vars idempotent on re-source) |
| install-bootstrap | Updated | 2 requirements modified (Progress display — 7→8 steps; Post-install actions — CLI skeleton, registry foundation, real MOTD commands); 3 scenarios added (Step 8 creates CLI skeleton, MOTD shows real commands, MOTD tips include agent management) |
| install-bootstrap | Updated (post-archive) | 1 requirement added (Remote install detection — 6 scenarios: pipe mode, process substitution, source stdin, custom dir, --help, idempotent clone); 1 requirement added (Relative symlink for CLI entry point — 2 scenarios: relative path, recreated on re-run); Requirement modified (Post-install actions — `bin/nexus`→`bin/nxai`, relative symlink) |
| nexus-cli | Updated (post-archive) | 1 requirement modified (Global entry point — `bin/nexus`→`bin/nxai`, absolute→relative symlink, `ln -sf` unconditional); all command references updated `nexus`→`nxai` |

## Merge Details

### env-config

**MODIFIED**: `NEXUS_VERSION` bumped from `"0.1.0"` to `"0.2.0"`. Added `NEXUS_MODULES_DIR` and `NEXUS_REGISTRY` to required variable exports.
**ADDED**: Scenario "New vars are idempotent on re-source" to ensure double-sourcing safety for the new variables.
**Preserved**: All original requirements (NEXUS_ROOT auto-detection, Environment detection, Idempotent sourcing) — untouched.

### install-bootstrap

**MODIFIED**: Progress display step count from `[1/7]` to `[1/8]` with total count of 8.
**MODIFIED**: Post-install actions now include CLI skeleton (`core/nexus.sh` + `bin/nxai` relative symlink via Step 8), registry foundation (`config/agents.registry.sh` + empty `modules/` directory), and real MOTD command tips replacing `"(proximamente)"` placeholders.
**ADDED** (original v0.2): 3 scenarios — Step 8 creates CLI skeleton, MOTD shows real commands, MOTD tips include agent management.
**ADDED** (post-archive BUG 8 + BUG 9): 1 requirement — Remote install detection with 6 scenarios covering all 3 pipe variants, custom `--dir`, `--help` short-circuit, and idempotent clone.
**ADDED** (post-archive symlink fix): 1 requirement — Relative symlink for CLI entry point with 2 scenarios (always relative, recreated on re-run).
**MODIFIED** (post-archive): Post-install actions updated — `bin/nexus`→`bin/nxai`, symlink path `../core/nexus.sh`, uses `ln -sf` unconditionally.
**Preserved**: All original requirements (Environment detection before action, Supported CLI flags) — untouched.

### nexus-cli

**MODIFIED** (post-archive): Global entry point requirement — command renamed from `nexus` to `nxai`, symlink changed from absolute to relative (`../core/nexus.sh`), creation method changed from `[ ! -f ]` guard to unconditional `ln -sf`. Added scenario for symlink recreation on re-install.
**Preserved**: All original requirements (Help display, Subcommand operations, Pure ASCII and Spanish locale) — updated command name references from `nexus` to `nxai`.

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
| BUG 8 — curl\|bash remote install | `install.sh` failed via `bash <(curl ...)` because `BASH_SOURCE[0]` resolves to `/dev/fd/*` which can't be sourced | Added remote-install detection block at top of `install.sh` — clones repo from GitHub and re-executes locally | ✅ |
| BUG 9 — BASH_SOURCE[0] unset in pipe | `curl ... | bash` leaves `BASH_SOURCE[0]` UNSET, failing both detection AND triggering `set -u` unbound variable error | Rewrote detection block to run BEFORE `set -euo pipefail`; uses `${BASH_SOURCE[0]:-}` with default; detects all 3 pipe modes (unset, /dev/fd/*, /dev/stdin) | ✅ |
| Symlink absolute→relative | `bin/nxai` was absolute symlink (`/root/nexus-ai/core/nexus.sh`) which breaks when installed to custom directories via `--dir` | Recreated as relative symlink (`../core/nexus.sh`); Step 8 changed from `[ ! -f ]` guard to unconditional `ln -sf` | ✅ |

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
| `specs/nexus-cli/spec.md` | ✅ (added post-archive) |
| `design.md` | ✅ |
| `tasks.md` | ✅ (21/21 tasks complete) |
| `verify-report-pr1.md` | ✅ |
| `verify-report-pr2.md` | ✅ |
| `verify-report-pr3.md` | ✅ |
| `verify-report-fixes.md` | ✅ (8 post-PR bug fixes + 3 post-archive fixes + dual-env audit confirmed) |
| `archive-report.md` | ✅ |

## Source of Truth Updated

The following main specs now reflect the final v0.2 behavior:

- `openspec/specs/env-config/spec.md` — version 0.2.0, new vars, idempotent sourcing
- `openspec/specs/install-bootstrap/spec.md` — 8 steps, remote install detection, CLI skeleton (`bin/nxai` relative symlink), real MOTD commands
- `openspec/specs/nexus-cli/spec.md` — renamed to `nxai`, relative symlink `../core/nexus.sh`, unconditional `ln -sf`

**Spec gap resolved**: The `nexus→nxai` rename was previously flagged as a spec gap. All main specs now reference `nxai` as the command name. The `openspec/specs/agent-install/spec.md` and design artifacts may still reference `nexus` — LOW risk since `nxai` is functionally equivalent (`bin/nxai -> ../core/nexus.sh`).

## Tasks Completion

All 21 tasks across 6 phases completed, plus 8 ad-hoc bug fixes + 3 post-archive fixes + dual-environment audit + production verification:

| Phase | Tasks | Status |
|-------|-------|--------|
| 1. Install Library y Config | 1.1–1.3 | ✅ All complete |
| 2. CLI Core | 2.1–2.3 | ✅ All complete |
| 3. Agentes Tier 1 (pip/npm) | 3.1–3.3 | ✅ All complete |
| 4. Agentes Practicos (pip) | 4.1–4.4 | ✅ All complete |
| 5. Agentes Curl/Stubs | 5.1–5.5 | ✅ All complete |
| 6. Gestion e Installer Bootstrap | 6.1–6.4 | ✅ All complete |
| Bug fixes (post-PR) | 8 ad-hoc fixes | ✅ All verified on device |
| Post-archive BUG 8 | curl\|bash remote install detection | ✅ Tested locally with `cat install.sh | bash -s -- --no-zsh --no-starship --no-motd --dir ~/nexus-test` |
| Post-archive BUG 9 | BASH_SOURCE[0] unset in pipe — all 3 variants | ✅ Rewritten detection runs before `set -u`, handles unset, /dev/fd/*, /dev/stdin |
| Symlink absolute→relative | `bin/nxai -> ../core/nexus.sh`, Step 8 uses `ln -sf` | ✅ Relative symlink works from any install directory |
| Production verification | curl\|bash end-to-end | ✅ `curl ... | bash -s -- --no-zsh --no-starship --no-motd --dir ~/nexus-test` — full install, 12 agents, PATH safety net, all correct |
| Dual-environment audit | 14/14 concerns compliant | ✅ All 12 modules audited |

## Risk Assessment

| Risk | Status |
|------|--------|
| Destructive merge? | No — all modifications were additive or non-breaking updates (version bumps, new variables, extended scenarios, marker-based PATH safety net) |
| Critical verify issues? | None — all 3 PRs + fixes PASS |
| Archive integrity | All artifacts present and accounted for; fixes report added |
| Spec gap: `nexus→nxai` rename | RESOLVED — main specs now reference `nxai`; design artifacts still use `nexus` but functionally equivalent |

---

## SDD Cycle Complete

The NEXUS AI v0.2 change has been fully planned, explored, specified, designed, implemented, verified (3 PRs + 8 bug fixes + 3 post-archive fixes + dual-environment audit + production verification), and archived. All fixes confirmed on device and production-verified. The `nexus→nxai` spec gap has been resolved — all main specs now reference `nxai`. Ready for v0.3 onwards.
