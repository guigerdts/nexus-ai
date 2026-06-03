# Design: NEXUS AI v0.1 — Base project structure

## Technical Approach

Shell-based skeleton for Termux/Android. Flat-by-domain dir layout (6 dirs at repo root). Bootstrap `install.sh` detects runtime environment via decision tree, installs deps with the platform package manager, configures Zsh with an isolated plugin stack (local `shell/plugins/`), sets up dual-level prompt (Starship → vcs_info fallback), and hooks a responsive MOTD on terminal open. All scripts source `config/env.sh` for canonical paths. Zero external runtime deps beyond bash/zsh/git/curl.

**Final absolute paths** after install:

| Source | Target |
|--------|--------|
| `config/env.sh` | `$NEXUS_ROOT/config/env.sh` |
| `shell/.zshrc` | `$HOME/.zshrc` (appended via block markers) |
| `shell/plugins/*` | `$NEXUS_ROOT/shell/plugins/{name}/` |
| `shell/starship.toml` | `$NEXUS_ROOT/shell/starship.toml` |
| `shell/motd.sh` | `$NEXUS_ROOT/shell/motd.sh` |
| `install.sh` | `$NEXUS_ROOT/install.sh` |
| `core/`, `modules/`, `bin/`, `lib/` | `$NEXUS_ROOT/{dir}/` |

## Architecture Decisions

| Decision | Options | Tradeoffs | Decision |
|----------|---------|-----------|----------|
| Dir layout | Flat-by-domain vs hierarchical | Flat simpler for v0.1, less nesting | **Flat-by-domain** |
| Root detection | `SCRIPT_DIR`/`BASH_SOURCE` vs hardcoded path | `SCRIPT_DIR` survives moves & symlinks | **`SCRIPT_DIR` + `readlink -f`** |
| Plugin isolation | `$NEXUS_ROOT/shell/plugins/` vs system paths | Local = clean uninstall, no sudo needed | **Local plugins dir** |
| `.zshrc` integration | Block markers vs separate `source`d file | Markers = surgical uninstall, no orphan config | **`# >>> NEXUS AI` block markers** |
| Prompt strategy | Starship-only vs dual fallback | Dual = ARM64 resilience, zero-deps safety net | **Starship → vcs_info fallback** |
| Plugin failure | Abort on error vs continue with warning | Continue = resilient on offline/partial install | **Continue per plugin** |
| Plugin load order | zsh-vi-mode first vs last | vi-mode intercepts keys → MUST be last to not break other plugins | **zsh-vi-mode ALWAYS last** |
| Idempotency | Guard vars vs re-execute | `[ -z "$NEXUS_ROOT" ]` guard prevents re-export | **Guard-based idempotency** |

**Rationale for zsh-vi-mode ordering**: `zsh-vi-mode` rebinds key bindings and widget chains. If loaded before `zsh-autosuggestions` or `zsh-syntax-highlighting`, it overrides their key bindings, breaking accept-suggestion and highlight behaviour. Loading it last ensures all other plugins register their widgets first, then vi-mode wraps them cleanly. The `.zshrc` MUST document this constraint in a comment above the load sequence.

## Critical Flows

**Environment detection — decision tree**
```
install.sh
 ├─ $PREFIX is set? ──→ NEXUS_ENV=termux, pkg manager=pkg
 └─ $PREFIX unset
    ├─ /proc/self/mountinfo | grep -q proot? ──→ proot-ubuntu, apt
    └─ neither ──→ linux, apt (emit warning)
```

**Plugin installation — independent per plugin**
```
for plugin in autosuggestions syntax-highlighting fzf fzf-tab zoxide atuin thefuck zsh-vi-mode:
  dir=$NEXUS_ROOT/shell/plugins/$plugin
  ├─ [ -d "$dir" ]? ──→ skip (idempotent — no duplicate clone)
  └─ git clone fails? ──→ echo "⚠ Advertencia: $plugin falló" → continue
```

**Starship activation — dual-level prompt**
```
.zshrc init
  ├─ command -v starship? ──→ eval "$(starship init zsh)"   # primary
  └─ not found ──→ autoload -Uz vcs_info; precmd() { vcs_info; echo "$vcs_info_msg_0_" }
```

**MOTD display — width-responsive**
```
motd.sh
  ├─ $COLUMNS < 60? ──→ compact: echo "NEXUS AI v0.1 — {agents} agentes — {date}"
  └─ ≥ 60 cols ──→ figlet-style block "NEXUS AI" (cyan)
                    + separator (cyan dashes)
                    + subtitle "Tu estación de trabajo..." (white)
                    + "Versión 0.1.0 | {N} agente(s) instalados | {date}" (white)
                    + tip aleatorio (spanish array) (white)
                    + separator (cyan dashes)
                    + "by GUIGERDTS" (white/gray)
```

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `config/env.sh` | Create | `NEXUS_ROOT` auto-detect, var exports, env/arch detection, color escapes |
| `shell/.zshrc` | Create | Plugin stack with documented load order (vi-mode last), dual prompt, MOTD hook, PATH |
| `shell/motd.sh` | Create | Responsive ASCII banner, system info, Spanish tips, compact mode |
| `shell/starship.toml` | Create | Cyan `#00BCD4` palette, git status (green/red), path, cmd_duration |
| `install.sh` | Create | CLI flags (`--help`, `--no-zsh`, `--no-starship`, `--no-motd`, `--dir`), env detection, 7-step progress, orchestration |
| `core/`, `shell/plugins/`, `modules/`, `bin/`, `config/`, `lib/`, `logs/` | Create | Empty dir skeleton |
| `README.md` | Modify | Update with project structure and install instructions |

**Every script** follows:
```bash
#!/usr/bin/env bash
# NEXUS AI — script-name
# Brief description
# Version: 0.1.0
```

## Interfaces / Contracts

**`config/env.sh` exports**: `NEXUS_ROOT`, `NEXUS_VERSION=0.1.0`, `NEXUS_LANG=es`, `NEXUS_ENV` (termux\|proot-ubuntu\|linux), `NEXUS_ARCH` (arm64\|x86_64), `NEXUS_AGENTS_DIR`, `NEXUS_LOG_FILE`, `NEXUS_COLOR_PRIMARY` (cyan escape), `NEXUS_COLOR_RESET`.

**Starship**: config at `$NEXUS_ROOT/shell/starship.toml` — NOT `~/.config/starship.toml`. User config preserved.

**Block markers in `.zshrc`** for clean uninstall: remove lines between `# >>> NEXUS AI BEGIN >>>` and `# <<< NEXUS AI END <<<` + delete `$NEXUS_ROOT`.

**Idempotency contract**: running `install.sh` twice MUST NOT duplicate `.zshrc` entries, create duplicate plugin dirs, or break existing config. Guard vars (`NEXUS_ALREADY_SOURCED`) in `env.sh`. Directory existence checks before `git clone`.

## Testing Strategy

No shell test framework available (per `config.yaml`). Manual checklist:

| Layer | What to Test | Approach |
|-------|--------------|----------|
| CLI flags | `--help`, `--no-zsh`, `--no-starship`, `--no-motd`, `--dir` | Run each, verify behaviour per spec |
| Env detection | Termux, proot, Linux | Mock `$PREFIX`, verify `NEXUS_ENV` |
| Plugin independence | Offline/git failure | Block one plugin, verify others install |
| Load order | zsh-vi-mode position | Assert it's the last `source` in `.zshrc` |
| Starship fallback | Binary missing | Remove binary, verify vcs_info activates |
| MOTD width | <60 cols | Resize terminal, verify compact mode |
| Idempotency | 2× install | No dupes, no errors |
| Uninstall | Block markers + `$NEXUS_ROOT` | Remove both → clean state |

## Implementation Order

1. `config/env.sh` — foundation (all scripts depend on it)
2. `shell/motd.sh` — standalone, testable in isolation
3. `shell/starship.toml` — config file, no deps
4. `shell/.zshrc` — depends on env.sh + motd + starship paths
5. `install.sh` — orchestrator, depends on everything above
6. `README.md` — document final structure and usage

## Open Questions

- [ ] Confirm proot detection string — `/proc/self/mountinfo` pattern may need fallback via `$PROOT` env var or `/proc/1/status`.
- [ ] Should `install.sh` prompt before overwriting existing `~/.config/starship.toml`? Spec says skip or ask.
