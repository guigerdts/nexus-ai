# Proposal: v0.7 — Agent Registry Restructure

## Intent

Clean up 2 stale modules (aider, goose), rename openclou→openclaude, add ~38 new modules across 9 categories, standardize module quality (REAL vs STUB), and update all guide files. Current: 12 modules, 8 categories, inconsistent quality. Target: ~48 modules, 9 categories, every module with metadata.sh/install.sh/test.sh/README.md.

## Scope

### In Scope (6 phases)

1. **Cleanup** — Remove aider/, goose/; rename openclou/→openclaude/; fix AGENT_CATEGORY on 8 existing modules
2. **New (npm)** — gemini-cli, typescript, pm2, nodemon
3. **New (pkg)** — gh, bat, eza, lazygit, jq, neovim, nodejs, python, rust, golang, sqlite, postgresql, mariadb, wget
4. **Special** — ollama (curl), oh-my-zsh (git), nvchad (git), n8n (npm)
5. **Stubs** — minimax-cli, codegraph, mistral-vibe, mongodb, termux-styling, nerd-fonts, qwen-code, antigravity, pi, gentle-ai (update), openclaude
6. **Guides + version** — Rewrite lib/nexus-guide.sh, tui/guide.py, core/nexus.sh show_help(); bump VERSION to 0.7.0; update README.md, shell/motd.sh

### Out of Scope

Module generator script, shell test harness, CI/CD pipeline.

## Capabilities

### New Capabilities

None — all changes modify existing specs.

### Modified Capabilities

- `agent-registry`: Required files standard expanded — metadata.sh MUST export 8 fields (name, version, desc, category, tier, method, binary, url); REAL (pkg/npm/curl binary, no source compile) vs STUB (manual instructions) criteria codified; test.sh MUST verify binary existence
- `guide-command`: Expand from 8→9 categories (add "node"); update all tool listings per category
- `help-redesign`: Expand Module Targets section from 8→9 categories

## Approach

Phased migration (exploration's recommendation, user's 6 phases). Registry auto-discovers from modules/*/, so adding/removing dirs takes effect immediately without registry code changes. Each phase independently verifiable.

## Affected Areas

| Area | Impact |
|------|--------|
| `modules/aider/`, `modules/goose/` | Removed |
| `modules/openclou/` | Renamed → openclaude/ |
| 37 new module dirs | Created |
| 8 existing modules (metadata.sh) | Modified (category, tier) |
| `lib/nexus-guide.sh`, `tui/guide.py` | Rewritten (9 categories) |
| `core/nexus.sh` (show_help) | Modified (9 categories) |
| `config/env.sh`, `VERSION` | Bump to 0.7.0 |
| `README.md`, `shell/motd.sh` | Updated |
| `openspec/specs/{agent-registry,guide-command,help-redesign}/` | Delta specs |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Guide desync (bash vs Python) | Med | Phase 6 updates both in same step |
| openclou→openclaude breaks `nxai install openclou` | High | Breaking change documented; users must migrate |
| 50+ file ops across 6 phases | Med | Each phase independently verifiable |
| Stub→Real install errors on ARM64 | Low | REAL criteria require proven ARM64 compatibility |

## Rollback Plan

`git revert HEAD~1` reverts all file changes. Restore removed module dirs via `git checkout HEAD~1 -- modules/aider modules/goose`. Registry auto-adapts as directories are restored. Guide files and VERSION revert with the commit.

## Dependencies

- Termux `pkg install` for all 14 pkg-phase modules
- `npm install -g` for npm-phase modules (gemini-cli, claude-code, codex, typescript, pm2, nodemon, n8n)
- `curl` binary install for ollama, engram
- No compilation from source required (excluded by REAL criteria)

## Success Criteria

- [ ] `ls modules/ | wc -l` shows ~48 directories
- [ ] `nxai guide` shows 9 categories with correct tools per category
- [ ] `nxai guide --interactive` matches bash guide output
- [ ] `nxai help` shows 9 Module Target categories
- [ ] All REAL module installers succeed on Termux ARM64
- [ ] All stubs show clear manual instructions (no cryptic errors)
- [ ] `cat VERSION` shows 0.7.0
