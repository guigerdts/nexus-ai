## Exploration: NEXUS AI base project structure — folders, CLI skeleton, Zsh theme

### Current State

The project is at v0.1 — literally a fresh initialize. Only three files exist:

- **`README.md`** — 5-line description, "Framework de entorno para Termux/proot-Ubuntu. Convierte Android en una workstation profesional para agentes de IA. Estado: v0.1 — en desarrollo."
- **`.gga`** — Gentle AI config: `PROVIDER="opencode"`, `FILE_PATTERNS="*.sh,*.py,*.yaml,*.zsh"`, `STRICT_MODE="true"`
- **`openspec/`** — Just created by sdd-init with an empty `config.yaml`, empty `specs/`, and empty `changes/`. No project code exists.
- No `install.sh`, no `core/nexus.sh`, no `shell/.zshrc`, no `bin/`, no `modules/`, no `config/` — nothing.
- No tests, no CI, no linting (shellcheck not installed; only shfmt available as formatter).
- Git: local-only, single commit, `main` branch, no remote.

The `.gga` config defines `FILE_PATTERNS="*.sh,*.py,*.yaml,*.zsh"` which tells us the project expects Shell, Python, YAML, and Zsh files.

### Affected Areas

- `openspec/config.yaml` — context block will need updating with decisions made
- `install.sh` — new root-level entry point
- `core/nexus.sh` — new CLI command (this is the heart of the project)
- `shell/.zshrc` — new Zsh configuration with theme
- `bin/` directory — new, for user-facing scripts
- `modules/` directory — new, for extensible feature modules
- `config/` directory — new, for framework configuration

### Approaches

#### 1. Directory Structure

**A. Flat-by-domain (recommended)**

```
nexus-ai/
├── core/           # Framework core: nexus.sh CLI, init, helpers
├── shell/          # Zsh/Bash dotfiles: .zshrc, aliases, completions
├── modules/        # Feature modules (one subdir each, e.g., modules/ai/)
├── bin/            # User-facing scripts on PATH
├── config/         # Framework config (defaults, themes, mappings)
├── lib/            # Shared library functions sourced by core
├── docs/           # Documentation
├── tests/          # Shell tests (future)
└── install.sh      # Bootstrap entry point
```

**B. FHS-like structure**
```
nexus-ai/
├── usr/
│   ├── bin/        # User-facing commands
│   ├── lib/        # Libraries
│   └── share/      # Shared data
├── etc/
│   └── nexus/      # Config
└── install.sh
```
- Pros: Familiar to Linux users, maps to real filesystem
- Cons: Over-engineered for a framework project. Extra nesting creates friction. The project _is_ the framework, not a system package.

**C. Monolithic flat**
```
nexus-ai/
├── install.sh
├── nexus.sh
├── .zshrc
└── modules/
```
- Pros: Simplest to start
- Cons: No separation of concerns. Every file has no home. Doesn't scale.

**Decision**: **Approach A (Flat-by-domain)**. It's the sweet spot — organized enough for a growing framework, flat enough to navigate without mental overhead. Each directory has one clear responsibility. Matches conventions used by other Termux frameworks (like `proot-distro`'s layout) and standard shell project conventions.

---

#### 2. CLI Command Approach (`core/nexus.sh`)

**A. Function-based dispatch with source (recommended)**

```bash
#!/usr/bin/env bash
# core/nexus.sh — Main CLI entry point

source "$NEXUS_ROOT/lib/colors.sh"
source "$NEXUS_ROOT/lib/helpers.sh"

cmd_init()   { /* ... */ }
cmd_status() { /* ... */ }
cmd_update() { /* ... */ }

case "${1:-help}" in
  init)   shift; cmd_init "$@" ;;
  status) shift; cmd_status "$@" ;;
  update) shift; cmd_update "$@" ;;
  help|--help|-h) cmd_help ;;
  *) log_error "Unknown command: $1"; exit 1 ;;
esac
```
- Pros: Simple, no external deps, single file, fast to parse. Easy to add subcommands. Bash `case` is the standard POSIX dispatch pattern.
- Cons: Can grow large if every command is inline. Mitigation: extract command bodies to `core/commands/` and source them.

**B. Module-sourcing pattern**
```bash
# core/nexus.sh
case "$1" in
  init)   source "$NEXUS_ROOT/modules/init/init.sh" ;;
  status) source "$NEXUS_ROOT/modules/status/status.sh" ;;
esac
```
- Pros: Very modular, each command in its own file
- Cons: Every invocation sources files on the fly — slower. Too much indirection for v0.1. Better as the project grows.

**C. External CLI generator (Bashly, etc.)**
- Pros: Auto-generates help, completion, argument parsing
- Cons: Ruby/Python dependency. Adds build step. Overkill for a framework's CLI. One more thing to break in Termux.

**Decision**: **Approach A** — function-based dispatch with `case`/`esac` in `core/nexus.sh`. For v0.1, keep all commands in one file. When the command count grows past ~10, extract to `core/commands/*.sh`. This balances simplicity with clear evolution path.

---

#### 3. Zsh Theme Approach (`shell/.zshrc`)

**A. Minimal zero-dependency prompt (recommended for v0.1)**

```zsh
# shell/.zshrc
PROMPT='%F{cyan}%n%F{reset}@%F{yellow}%m%F{reset}:%F{green}%~%F{reset}$ '
RPROMPT='%F{8}%*%F{reset}'
```
- Pros: Zero dependencies. Instant load. Works with any Zsh. Predictable on Termux.
- Cons: No git info, no icons, no fancy segments. Ugly compared to modern prompts.

Enhance with a `shell/prompt.zsh` helper that adds git status without external tools:

```zsh
# In .zshrc: source "$NEXUS_ROOT/shell/prompt.zsh"
# Simple git branch in prompt using built-in Zsh
autoload -Uz vcs_info
zstyle ':vcs_info:git:*' formats '(%b)'
zstyle ':vcs_info:git:*' actionformats '(%b|%a)'
precmd() { vcs_info }
PROMPT='%F{cyan}%n%F{reset}@%F{yellow}%m%F{reset}:%F{green}%~%F{reset}${vcs_info_msg_0_}$ '
```

**B. Powerlevel10k via Oh-My-Zsh**
- Pros: Gorgeous prompt, configuration wizard, git/python/node segments out of the box
- Cons: Heavy dependency chain (Oh-My-Zsh + p10k + Nerd Font = 3 external deps). Adds ~1.5s to shell startup on a phone. Oh-My-Zsh is 100k+ lines. P10k's author explicitly says "very limited support, no new features." Brittle on Termux.

**C. Starship prompt**
- Pros: Cross-shell, Rust-based, fast. Single binary dep. TOML config.
- Cons: Requires Rust or binary download. On Termux ARM64, Starship may need compiling. Adds a forked process on every prompt. Still an external binary that must be maintained.

**Decision**: **Approach A enhanced** — minimal `.zshrc` with built-in Zsh features only for v0.1. Add a `prompt.zsh` helper for git info using `vcs_info` (Zsh native). No external dependencies. This keeps the framework self-contained and reliable on Termux/proot. The theme can be upgraded to Starship or P10k later as an opt-in module.

---

#### 4. Install Script Approach (`install.sh`)

**A. Flag-based with sensible defaults (recommended)**

```bash
# install.sh - NEXUS AI Bootstrap
# Usage: bash install.sh [--help] [--no-zsh] [--no-modules]

Usage:
  install.sh                 # Full install with defaults
  install.sh --no-zsh        # Skip Zsh configuration
  install.sh --no-modules    # Skip optional modules
  install.sh --help          # Show this help
```
- Pros: Non-interactive (good for scripting/automation), explicit intent, composable. Each flag is discoverable. Default is "install everything."
- Cons: Users must know flags exist.

**B. Interactive wizard**
- Pros: Guided experience, asks questions
- Cons: Requires stdin interaction, fails in non-interactive terminals (CI, remote). Heavier script.

**C. Silent single-mode**
- Pros: Simplest possible (just runs)
- Cons: No opt-out, no choice. Bad UX for a framework.

**Decision**: **Approach A** — flag-based. It's the Termux-native approach: `pkg install`, `proot-distro install` — all use flags, not wizards. Users on Android expect CLI tools to be non-interactive.

### Recommendation

**Go with the Flat-by-domain directory structure + function-based CLI dispatch + minimal Zsh prompt + flag-based install script.**

This combination gives the project:

1. **Zero external dependencies** — everything works inside Termux/proot with just Bash and Zsh. No compiling, no npm, no pip, no Rust toolchain.
2. **Simple evolution path** — as the framework grows, modules can become independent scripts, the CLI can extract subcommands, the prompt can be upgraded to Starship.
3. **Android-first mindset** — minimal overhead is critical on a phone. Every dependency is a potential breakage on ARM64/Termux.

The skeleton is intentionally minimal. Each piece has a clear growth path:

| Component | v0.1 (this change) | Future evolution |
|-----------|-------------------|-----------------|
| CLI | `core/nexus.sh` with case dispatch | Extract to `core/commands/*.sh` |
| Prompt | Minimal `shell/.zshrc` with vcs_info | Opt-in Starship module |
| Modules | Empty `modules/` directory | Per-feature subdirectories |
| Install | `install.sh` with flags | Package manager integration |

### Risks

- **Zsh availability**: Termux has Zsh by default, but proot-Ubuntu may not. The `.zshrc` should gracefully handle missing Zsh.
- **Path assumptions**: `$NEXUS_ROOT` must be set correctly. If the user moves the directory, the framework breaks. Mitigation: use `SCRIPT_DIR` detection in `nexus.sh`.
- **ShellCheck not installed**: No linting until it's added. Manual review required.
- **No test framework**: No shell test runner available. Shellspec/bats should be added before significant logic.
- **ARM64 compatibility**: All scripts must use portable POSIX/Bash — no `x86_64`-specific binaries or assumptions.

### Ready for Proposal

Yes — the exploration is complete. The approaches are well-understood and the technical tradeoffs are clear. The orchestrator should proceed to **sdd-propose** to formalize the change scope, then **sdd-spec** for requirements, **sdd-design** for architecture, and **sdd-tasks** for implementation planning.

The initial implementation can be done in a single PR (under 400 lines across all files) since each skeleton file is small (~20-50 lines). Follow-up PRs can add modules, completions, and enhanced prompts.
