# Tasks: v0.7 — Agent Registry Restructure

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | 800-1200 |
| 400-line budget risk | High |
| Chained PRs recommended | Yes |
| Suggested split | PR 1 (Cleanup) → PR 2 (Real modules) → PR 3 (Stubs) → PR 4 (Guides) |
| Delivery strategy | ask-on-risk |
| Chain strategy | stacked-to-main |

Decision needed before apply: Yes
Chained PRs recommended: Yes
Chain strategy: stacked-to-main
400-line budget risk: High

### Suggested Work Units

| Unit | Goal | Likely PR | Notes |
|------|------|-----------|-------|
| 1 | Cleanup — remove aider/goose, rename openclou, fix 8 metadata.sh | PR 1 | Base: main. Minimal diff. |
| 2 | Real modules — 4 npm + 14 pkg + 4 special | PR 2 | Base: main. Template-driven. |
| 3 | Stub modules — 7 new + 4 updated | PR 3 | Base: main. No real installs. |
| 4 | Guides + version bump | PR 4 | Base: main. Depends on prior modules. |

## Phase 1: Cleanup

- [x] 1.1 `rm -rf modules/aider/ modules/goose/`
- [x] 1.2 `mv modules/openclou/ modules/openclaude/` + update metadata.sh
- [x] 1.3 Fix metadata.sh in claude-code (T3→1, stub→npm, +package), fabric (tools→ai), engram (manual→binary), gentle-ai (T3→2), pi (pip→stub), antigravity (manual→stub), sgpt (shell→ai)
- [x] 1.4 Verify: `registry_list` shows no aider/goose, openclaude exists

## Phase 2: New npm modules

- [x] 2.1 Create modules/gemini-cli/ with 4 files (npm install -g @google/gemini-cli)
- [x] 2.2 Create modules/typescript/ with 4 files (npm install -g typescript)
- [x] 2.3 Create modules/pm2/ with 4 files (npm install -g pm2)
- [x] 2.4 Create modules/nodemon/ with 4 files (npm install -g nodemon)

## Phase 3: New pkg modules

- [x] 3.1 Create gh, bat, eza, lazygit, jq modules (pkg install, test.sh verifies binary)
- [x] 3.2 Create neovim, nodejs, python, rust, golang modules (pkg install)
- [x] 3.3 Create sqlite, postgresql, mariadb, wget modules (pkg install)

## Phase 4: Special modules

- [x] 4.1 Create modules/ollama/ (curl ARM64 binary download)
- [x] 4.2 Create modules/oh-my-zsh/ (git clone RUNZSH=no)
- [x] 4.3 Create modules/nvchad/ (git clone neovim config)
- [x] 4.4 Create modules/n8n/ (npm install -g n8n)

## Phase 5: Stub modules

- [x] 5.1 Create stubs: minimax-cli, codegraph, mistral-vibe, mongodb, termux-styling, nerd-fonts, qwen-code — 4 files each, AGENT_METHOD=stub
- [x] 5.2 Update stubs: antigravity, pi, gentle-ai, openclaude — fix metadata.sh fields
- [x] 5.3 Verify: each stub prints clear URL + manual steps, exits 0

## Phase 5b: Missing modules (pkg + curl + stub)

- [x] 5b.1 Create modules/zsh/ (pkg — install_via_apt zsh)
- [x] 5b.2 Create modules/fzf/ (pkg — install_via_apt fzf)
- [x] 5b.3 Create modules/gum/ (pkg — install_via_apt gum)
- [x] 5b.4 Create modules/curl/ (pkg — install_via_apt curl)
- [x] 5b.5 Create modules/git/ (pkg — install_via_apt git)
- [x] 5b.6 Create modules/perl/ (pkg — install_via_apt perl)
- [x] 5b.7 Create modules/php/ (pkg — install_via_apt php)
- [x] 5b.8 Create modules/clang/ (pkg — install_via_apt clang)
- [x] 5b.9 Create modules/starship/ (curl — official install script)
- [x] 5b.10 Create modules/banner/ (stub — ya incluido en NEXUS AI)

## Phase 6: Guides + Version

- [x] 6.1 Rewrite lib/nexus-guide.sh — 9 categories, all tool listings updated
- [x] 6.2 Rewrite tui/guide.py CATEGORIES dict — 9 categories, per-tool stub detection
- [x] 6.3 Update core/nexus.sh show_help() — Module Targets to 9 categories
- [x] 6.4 Update core/nexus.sh — add "node" to guide case statement
- [x] 6.5 Bump VERSION to 0.7.0; update config/env.sh NEXUS_VERSION
- [x] 6.6 Update README.md module table (39 entries, 9 categories)
- [x] 6.7 Update shell/motd.sh — remove aider tip
- [x] 6.8 Verify: `nxai guide`, `nxai guide --interactive`, `nxai help` show 9 categories
