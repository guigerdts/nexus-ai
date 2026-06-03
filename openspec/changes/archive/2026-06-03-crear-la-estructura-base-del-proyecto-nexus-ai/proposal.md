# Proposal: NEXUS AI v0.1 — Base project structure

## Intent

Foundational skeleton for NEXUS AI — a Termux/Android environment framework (spanish, terminal-only, no root). Dir structure, env config, Zsh with plugins, welcome screen, bootstrap installer. No agent logic yet.

## Scope

### In Scope
- Flat-by-domain skeleton: `core/`, `shell/`, `modules/`, `bin/`, `config/`, `lib/`
- `config/env.sh` — NEXUS_ROOT via `SCRIPT_DIR`, sourced by all scripts
- `shell/.zshrc` — autosuggestions, syntax-highlighting, vi-mode, fzf+fzf-tab, zoxide, atuin, thefuck
- Dual-level prompt: Starship (cyan/black) → vcs_info fallback
- MOTD — ASCII "NEXUS AI" in cyan/black, version, agents, date, tip (spanish)
- `install.sh` — flags (`--help`, `--no-zsh`, `--no-modules`), detects Termux vs proot-Ubuntu

### Out of Scope
- `nexus` CLI (`core/nexus.sh`), Agent installer, Engram, Dashboard TUI
- ShellCheck, tests, CI
- `docs/`, `tests/` dirs

## Capabilities

### New Capabilities
- `env-config`: NEXUS_ROOT, base vars, PATH
- `zsh-config`: Plugin stack, independent failure
- `prompt-starship`: Starship TOML (cyan/black), vcs_info fallback
- `motd-display`: Welcome banner — ASCII art, version, agents, date, tip
- `install-bootstrap`: Flag-based CLI, Termux/proot detection

### Modified Capabilities
None — v0.1 greenfield.

## Approach
1. Create 6 dirs at repo root
2. `config/env.sh` — `SCRIPT_DIR`-based `NEXUS_ROOT`
3. `shell/.zshrc` — install plugins; attempt Starship; vcs_info fallback
4. `shell/motd.sh` — ANSI ASCII art + system info
5. `install.sh` — detect Termux (`$PREFIX`) vs proot (`$PROOT`); orchestrate all
6. All scripts source `config/env.sh`; messages in spanish

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `install.sh` | New | Bootstrap entry point |
| `config/env.sh` | New | Framework env vars |
| `shell/.zshrc` | New | Zsh config + plugins |
| `shell/motd.sh` | New | Welcome screen |
| `core/`, `modules/`, `bin/`, `lib/` | New | Empty dirs |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Zsh missing in proot-Ubuntu | Med | `apt install -y zsh` |
| Starship missing on ARM64 | Low | vcs_info fallback |
| Plugin clone fails | Med | Independent installs, graceful skip |
| Symlink breaks `SCRIPT_DIR` | Low | `readlink -f` resolves it |

## Rollback Plan
- `git clean -fd` removes all new files
- `install.sh` backs up `~/.zshrc` → `~/.zshrc.nexus-backup`
- No system file changes outside `$HOME`

## Dependencies
- Runtime: `bash`, `zsh`, `curl`, `git` (Termux default; apt for proot)
- No build-time deps

## Success Criteria
- [ ] `install.sh` completes on Termux native AND proot-Ubuntu
- [ ] `config/env.sh` sets `NEXUS_ROOT`; sourced scripts resolve it
- [ ] `.zshrc` loads all plugins; Starship renders; removing binary triggers fallback
- [ ] MOTD shows art, version, agents, date in spanish
- [ ] `--help`, `--no-zsh`, `--no-modules` flags work
- [ ] All scripts pass `shfmt`
