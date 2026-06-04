# Tasks: v0.6 — Guide & Help Redesign

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | ~380 |
| 400-line budget risk | Medium |
| Chained PRs recommended | No |
| Suggested split | Single PR |
| Delivery strategy | ask-on-risk |
| Chain strategy | pending |

Decision needed before apply: No
Chained PRs recommended: No
Chain strategy: pending
400-line budget risk: Medium

## Phase 1: Foundation — Metadata & Registry

- [x] 1.1 Add `AGENT_CATEGORY="editor"` to `modules/aider/metadata.sh`
- [x] 1.2 Add `AGENT_CATEGORY="ai"` to `modules/antigravity/metadata.sh`
- [x] 1.3 Add `AGENT_CATEGORY="ai"` to `modules/claude-code/metadata.sh`
- [x] 1.4 Add `AGENT_CATEGORY="ai"` to `modules/codex/metadata.sh`
- [x] 1.5 Add `AGENT_CATEGORY="ai"` to `modules/engram/metadata.sh`
- [x] 1.6 Add `AGENT_CATEGORY="tools"` to `modules/fabric/metadata.sh`
- [x] 1.7 Add `AGENT_CATEGORY="ai"` to `modules/gentle-ai/metadata.sh`
- [x] 1.8 Add `AGENT_CATEGORY="tools"` to `modules/goose/metadata.sh`
- [x] 1.9 Add `AGENT_CATEGORY="ai"` to `modules/openclou/metadata.sh`
- [x] 1.10 Add `AGENT_CATEGORY="ai"` to `modules/opencode/metadata.sh`
- [x] 1.11 Add `AGENT_CATEGORY="ai"` to `modules/pi/metadata.sh`
- [x] 1.12 Add `AGENT_CATEGORY="shell"` to `modules/sgpt/metadata.sh`
- [x] 1.13 Update `config/agents.registry.sh` to read `AGENT_CATEGORY` from sourced metadata

## Phase 2: Environment — Rich Fix

- [x] 2.1 Add `export PYTHONPATH` with Rich site-packages to `config/env.sh`
- [x] 2.2 Add `NEXUS_RICH_AVAILABLE` detection via `python3 -c "from rich.console import Console"` in `config/env.sh`
- [x] 2.3 Add `pip install --break-system-packages --user rich` fallback in `config/env.sh`

## Phase 3: Core — Help Redesign

- [x] 3.1 Rewrite `show_help()` in `core/nexus.sh` with `printf` + ANSI: banner, Usage, Available Commands
- [x] 3.2 Add Quick Start section to `show_help()` with 3+ examples
- [x] 3.3 Add Module Targets section to `show_help()` listing all 8 categories
- [x] 3.4 Ensure `nxai` (no args), `nxai help`, `nxai --help` produce identical output

## Phase 4: Feature — Guide Command

- [x] 4.1 Create `lib/nexus-guide.sh` with `show_guide()` listing all categories from registry
- [x] 4.2 Add `show_guide_category()` for single-category filter in `lib/nexus-guide.sh`
- [x] 4.3 Add guide routing to `core/nexus.sh` — source lib + case dispatch
- [x] 4.4 Create `tui/guide.py` with Rich `Table` per category showing tools and status
- [x] 4.5 Add `--interactive` mode to `tui/guide.py` with `Prompt` + `subprocess` for install/remove
- [x] 4.6 Fallback: `nxai guide --interactive` uses bash `show_guide()` when Rich unavailable

## Phase 5: Verification

- [x] 5.1 Run `bash -n` on all modified shell files
- [x] 5.2 Verify `python3 -c "from rich.console import Console"` succeeds after PYTHONPATH fix
- [x] 5.3 Test `nxai` (no args) shows redesigned help with all sections
- [x] 5.4 Test `nxai guide` shows all 8 categories with tools
- [x] 5.5 Test `nxai guide ai` shows only ai-category tools
- [x] 5.6 Test `nxai guide nonexistent` exits 1 with error listing valid categories
- [x] 5.7 Test `nxai guide --interactive` launches Rich TUI or falls back gracefully
