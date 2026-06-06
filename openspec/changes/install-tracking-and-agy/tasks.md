# Tasks: Install Tracking and Antigravity CLI (agy)

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | 115–145 |
| 400-line budget risk | Low |
| Chained PRs recommended | No |
| Suggested split | Single PR |
| Delivery strategy | ask-on-risk |
| Chain strategy | pending |

Decision needed before apply: No
Chained PRs recommended: No
Chain strategy: pending
400-line budget risk: Low

## Phase 1: Manifest Foundation

- [x] 1.1 Create `logs/installed.txt` — empty manifest file, one agent per line
- [x] 1.2 Add `update_installed_manifest(agent, action)` to `lib/nexus-install.sh` — `install` appends via `grep -Fx || echo`, `remove` deletes via `sed -i`
- [x] 1.3 Call `update_installed_manifest` from `mark_installed()` (after the log write)
- [x] 1.4 Call `update_installed_manifest` from `mark_removed()` (after the log write)

## Phase 2: Three-State Detection

- [x] 2.1 Modify `list_agents()` in `core/nexus.sh` — read `installed.txt` into manifest check before `command -v`
- [x] 2.2 Change status logic: manifest+PATH → `INSTALADO` (green), PATH only → `EXTERNO` (cyan), neither → `NO INSTALADO` (yellow)
- [x] 2.3 Update both gum table and ANSI fallback branches of `list_agents()` for three states

## Phase 3: agy Module

- [x] 3.1 Create `modules/agy/metadata.sh` — `AGENT_METHOD="curl"`, `AGENT_BINARY="agy"`, `AGENT_URL="https://antigravity.google/cli/install.sh"`, tier 2
- [x] 3.2 Create `modules/agy/install.sh` — source lib, call `install_via_curl`, verify binary, `mark_installed`
- [x] 3.3 Create `modules/agy/test.sh` — `command -v agy`
- [x] 3.4 Create `modules/agy/README.md` — basic module doc

## Phase 4: Redirect antigravity → agy

- [x] 4.1 Modify `modules/antigravity/metadata.sh` — point `AGENT_BINARY` to `agy`, `AGENT_METHOD` to `curl`, `AGENT_URL` to Google install URL, update `AGENT_DESC`
- [x] 4.2 Modify `modules/antigravity/install.sh` — replace manual instructions with `install_via_curl` for agy, then `mark_installed "antigravity"`

## Phase 5: Deprecation Banner

- [x] 5.1 Add deprecation banner to `modules/gemini-cli/install.sh` — print sunset warning with June 18 date before install logic
- [x] 5.2 (Optional) Add deprecation note to `modules/gemini-cli/metadata.sh` description

## Phase 6: Manual Verification

- [ ] 6.1 Verify `nxai list` shows EXTERNO for PATH-only agents (claude-code, mongodb, nerd-fonts)
- [ ] 6.2 Verify `nxai install agy` from official URL and check INSTALADO status
- [ ] 6.3 Verify `nxai install gemini-cli` shows deprecation banner
- [ ] 6.4 Verify stale manifest entry (binary removed) shows NO INSTALADO
