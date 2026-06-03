# Tasks: NEXUS AI v0.1 — Base project structure

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | 350-450 |
| 400-line budget risk | Medium |
| Chained PRs recommended | No |
| Suggested split | Single PR |
| Delivery strategy | ask-on-risk |
| Chain strategy | pending |

Decision needed before apply: Yes
Chained PRs recommended: No
Chain strategy: pending
400-line budget risk: Medium

## Phase 1: Foundation

- [x] 1.1 Create 7 dirs at repo root: `core/`, `shell/plugins/`, `modules/`, `bin/`, `config/`, `lib/`, `logs/`
- [x] 1.2 Create `config/env.sh` — SCRIPT_DIR + readlink -f NEXUS_ROOT detection, env classification (termux/proot/linux), arch detection, NEXUS_COLOR_PRIMARY (cyan) + NEXUS_COLOR_RESET exports, guard var for idempotent sourcing

## Phase 2: Shell Configuration

- [x] 2.1 Create `shell/starship.toml` — cyan #00BCD4 palette, username@host, dir, git status (green clean / red dirty), cmd_duration
- [x] 2.2 Create `shell/motd.sh` — ASCII "NEXUS AI" block in cyan, separator line, version/agent count/date, Spanish tips array, compact one-liner at <60 cols, "by GUIGERDTS" footer
- [x] 2.3 Create `shell/.zshrc` — block markers `# >>> NEXUS AI` / `# <<< NEXUS AI`, PATH prepend `$NEXUS_ROOT/bin`, 8 plugins in mandatory load order (zsh-vi-mode ALWAYS last), independent source guards, dual prompt (starship → vcs_info), MOTD source

## Phase 3: Installer

- [x] 3.1 Create `install.sh` — CLI flags `--help`, `--no-zsh`, `--no-starship`, `--no-motd`, `--dir PATH`; env decision tree ($PREFIX → termux+pkg, proot mountinfo → apt, else → linux+apt warning)
- [x] 3.2 Implement numbered 7-step progress display `[N/7] Descripción...` with step marking
- [x] 3.3 Implement plugin install loop — `$NEXUS_ROOT/shell/plugins/{name}`, dir-existence skip, git clone per plugin, graceful failure with Spanish warning, continue on error
- [x] 3.4 Implement `.zshrc` block append — preserve existing file, inject only once (idempotent), skip with `--no-zsh`
- [x] 3.5 Implement post-install — trigger MOTD, Spanish welcome message, next-steps, source/restart instructions

## Phase 4: Polish

- [x] 4.1 Update `README.md` — project tree, prerequisites, install.sh usage, flags reference, uninstall notes
- [x] 4.2 Verify header format — every script has `#!/usr/bin/env bash` + name/description/version header
- [x] 4.3 Run manual verification checklist from design.md (8 scenarios: CLI flags, env detection, plugin independence, load order, starship fallback, MOTD width, idempotency, uninstall)

## Verification Fixes (post-verify)

- [x] 5.1 Fix symlink resolution in `config/env.sh` — add `readlink -f` detection with fallback for Termux/minimal environments (addresses CRITICAL verify finding)
- [x] 5.2 Create `shell/.bashrc` with NEXUS AI block markers — sources env.sh, MOTD, sets PATH (addresses WARNING: MOTD not sourced from .bashrc)
- [x] 5.3 Update `install.sh` — add `--no-bashrc` flag, `.bashrc` block append logic with idempotent backup (addresses WARNING: .bashrc gap)
- [x] 5.4 Add `set -euo pipefail` to `install.sh` for fail-fast error handling (addresses SUGGESTION from verify)
- [x] 5.5 Update `README.md` — add `.bashrc` to tree, add `--no-bashrc` to flags, update uninstall instructions

## Bug Fixes (post-archive)

- [x] 6.1 Fix `((VAR++))` abort in `install.sh` — replace all 3 instances of `((VAR++))` with `VAR=$((VAR + 1))` to prevent `set -euo pipefail` from aborting on zero-count arithmetic
- [x] 6.2 Fix git clone error suppression in `install.sh` — remove `2>/dev/null` from git clone, add `GIT_TERMINAL_PROMPT=0` to prevent hang on auth prompts, capture stderr output and show in warning message
- [x] 6.3 Fix proot environment detection in `config/env.sh` — add `$PROOT` env var check (fastest/most reliable), fallback to mountinfo, fallback to proot-distro data directory

## Bug Fixes (post-archive round 2 — v0.1.0 final)

- [x] 7.1 Fix URL parsing in `install.sh` — change `url="${entry##*:}"` to `url="${entry#*:}"` on line 205. Greedy `##` matched last colon (after `https:`), producing broken `//github.com/...` URLs. Single `#` matches first colon separator correctly.
- [x] 7.2 Add `|| true` guards to grep pipelines in `install.sh` (lines 308-309) — under `set -euo pipefail`, `grep` with no match exits 1, aborting the vi-mode verification block. Guards prevent fatal exit on expected non-matches.
- [x] 7.3 Fix `count_agents()` crash in `shell/motd.sh` — replace `ls -1d "$agents_dir"/*/` with `find "$agents_dir" -mindepth 1 -maxdepth 1 -type d -not -name '.*'`. `ls` with empty glob returns exit code 2, aborting under `set -euo pipefail`. `find` exits 0 on empty results.
- [x] 7.4 Replace Unicode block chars in `shell/motd.sh` — compact mode `███` → `###`, separator `─` → `=`, tip icon `💡` → `>>>`. All ASCII art changed to `figlet -f big` pure ASCII output for Termux/proot ARM64 terminal compatibility.
- [x] 7.5 Add subtitle to `shell/motd.sh` — `"Framework de Entorno para AI Agents"` in gray (`COLOR_GRAY`) after ASCII art block, before info line.
- [x] 7.6 Add robust terminal width detection in `shell/motd.sh` — `NEXUS_MOTD_MODE=full` override skip, `tput cols` with `stty size` fallback, 80-col default. Cascading fallback for all terminal environments.
- [x] 7.7 Add `NEXUS_MOTD_MODE=full` to `install.sh` step 7 (line 363) — forces full ASCII art banner for post-install welcome regardless of terminal width.
