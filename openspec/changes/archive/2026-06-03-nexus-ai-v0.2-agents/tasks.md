# Tasks: NEXUS AI v0.2 - Agentes y CLI

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | ~1800-2500 |
| 400-line budget risk | High |
| Chained PRs recommended | Yes |
| Suggested split | PR 1 -> PR 2 -> PR 3 |
| Delivery strategy | ask-always |
| Chain strategy | stacked-to-main |

Decision needed before apply: Yes
Chained PRs recommended: Yes
Chain strategy: stacked-to-main
400-line budget risk: High

### Suggested Work Units

| Unit | Goal | Likely PR | Notes |
|------|------|-----------|-------|
| 1 | Install library + CLI + 3 Tier-1 agents (aider, opencode, codex) | PR 1 | Foundation block; self-contained CLI with first agents |
| 2 | Remaining 9 agent modules (antigravity through claude-code) | PR 2 | Pure module creation, no structural changes |
| 3 | nexus agent add/test + install.sh Step 8 + env/config | PR 3 | Wiring and polish on existing structure |

## Phase 1: Install Library y Config

- [x] 1.1 Create `lib/nexus-install.sh` with check_dependency, install_via_pip|npm|curl|apt|cargo
- [x] 1.2 Create `lib/nexus-log.sh` with [OK]/[WARN]/[ERROR]/[INFO] helpers, color on [ -t 1 ]
- [x] 1.3 Modify `config/env.sh`: bump NEXUS_VERSION to 0.2.0, add NEXUS_MODULES_DIR, NEXUS_REGISTRY

## Phase 2: CLI Core

- [x] 2.1 Create `core/nexus.sh` with case/esac routing for install, remove, list, status, agent, memory, help
- [x] 2.2 Create `bin/nexus` symlink -> ../core/nexus.sh
- [x] 2.3 Create `config/agents.registry.sh` with auto-build assoc array from modules/*/metadata.sh

## Phase 3: Agentes Tier 1 (pip/npm)

- [x] 3.1 Create `modules/aider/` (metadata.sh, install.sh via pip, test.sh, README.md)
- [x] 3.2 Create `modules/opencode/` (metadata.sh, install.sh via npm, test.sh, README.md)
- [x] 3.3 Create `modules/codex/` (metadata.sh, install.sh via npm, test.sh, README.md)

## Phase 4: Agentes Practicos (pip)

- [x] 4.1 Create `modules/antigravity/` (metadata.sh, install.sh stub (exit 0), test.sh, README.md)
- [x] 4.2 Create `modules/pi/` (metadata.sh, install.sh via pip, test.sh, README.md)
- [x] 4.3 Create `modules/fabric/` (metadata.sh, install.sh via pip, test.sh, README.md)
- [x] 4.4 Create `modules/sgpt/` (metadata.sh, install.sh via pip -- package shell-gpt, test.sh, README.md)

## Phase 5: Agentes Curl/Stubs

- [x] 5.1 Create `modules/goose/` (metadata.sh, install.sh via curl, test.sh, README.md)
- [x] 5.2 Create `modules/engram/` -- functional CLI wrapper (engram v1.16.1 en PATH), test.sh, README.md
- [x] 5.3 Create `modules/gentle-ai/` -- stub (install TBD, exit 0), manual instructions, README.md
- [x] 5.4 Create `modules/openclou/` -- stub (exit 0), manual instructions, README.md
- [x] 5.5 Create `modules/claude-code/` -- stub (exit 0, heavy install), manual instructions, README.md

## Phase 6: Gestion e Installer Bootstrap

- [x] 6.1 Add `nexus agent add <name> <url>` to core/nexus.sh -- clona git repo a modules/<name>/, valida metadata.sh
- [x] 6.2 Add `nexus agent test <name>` to core/nexus.sh -- ejecuta test.sh con timeout 10s, reporta PASS/FAIL/TIMEOUT
- [x] 6.3 Modify `install.sh`: add Step 8 for CLI symlink + PATH in .zshrc/.bashrc, update to 8/8 progress
- [x] 6.4 Modify `shell/motd.sh`: replace tips with real nexus commands (install, list, agent test, status, etc.)
