# Design: v0.6 — Guide & Help Redesign

## Technical Approach

Hybrid bash/Python architecture: help and basic guide use pure bash `printf` + ANSI (zero deps). Interactive mode delegates to Python/Rich when available, falls back to bash. Category data lives in `metadata.sh` as `AGENT_CATEGORY`, sourced at registry time. PYTHONPATH fix in `config/env.sh` ensures Rich import works without system-package flags.

## Architecture Decisions

| Decision | Choice | Alternatives | Rationale |
|----------|--------|-------------|-----------|
| Help rendering | Pure bash `printf` + ANSI | Python/Rich, gum formatting | Must work in minimal environments (Termux, proot). Zero dependencies = zero failure points. |
| Guide mode | Hybrid bash/Python | Pure bash, pure Python | Bash handles basic case instantly. Rich adds interactivity when available. Fallback preserves UX. |
| Category data | `AGENT_CATEGORY` in `metadata.sh` | External YAML catalog, registry-level map | Self-contained modules. Registry already sources metadata; adding one var is minimal delta. No sync problem. |
| Module Targets section | Hardcoded categories in `show_help()` | Dynamic from sourced agents | Help runs before `AGENTS` array is built. Hardcoding is explicit, testable, and matches stubs that exist only as names. |
| Rich availability | `NEXUS_RICH_AVAILABLE` flag in `env.sh` | Try/except at call site | Determined once at shell start, reused across subcommands. Avoids repeated `python3 -c` calls. |

## Data Flow

```
nxai (no args)
  └─▶ case "" → show_help()
       ├─ show_banner()               # ASCII art
       ├─ "Usage:" section            # printf columns
       ├─ "Available Commands:"       # grouped by domain
       ├─ "Quick Start:"              # 3+ examples
       └─ "Module Targets:"           # 8 hardcoded categories

nxai guide
  └─▶ show_banner() → show_guide()
       ├─ source agents.registry.sh   # pulls AGENT_CATEGORY
       ├─ iterate AGENT_ORDER         # build category→agents map
       └─ printf categorized listing

nxai guide <cat>
  └─▶ show_banner() → show_guide_category <cat>
       ├─ validate category exists
       └─ list only matching agents

nxai guide --interactive
  └─▶ show_banner()
       ├─ if NEXUS_RICH_AVAILABLE=true → exec python3 tui/guide.py
       └─ else → echo "Rich unavailable" → show_guide()
```

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `config/env.sh` | Modify | Add `export PYTHONPATH`, `NEXUS_RICH_AVAILABLE` detection via `python3 -c "from rich.console import Console"` |
| `config/agents.registry.sh` | Modify | Read and export `$_agent_category` from sourced metadata, expose in `registry_get()` output |
| `modules/*/metadata.sh` (12) | Modify | Add `export AGENT_CATEGORY="<category>"` per user assignment |
| `core/nexus.sh` | Modify | Replace `show_help()` with redesigned version, add `guide` case to main routing block, source `lib/nexus-guide.sh` |
| `lib/nexus-guide.sh` | Create | `show_guide()`, `show_guide_category()` — bash functions with printf formatting |
| `tui/guide.py` | Create | Rich app: `Table` per category, interactive category picker via `Console` + `input`/`Prompt`, calls `nxai install/remove` via `subprocess` |

## Interfaces / Contracts

### AGENT_CATEGORY values (metadata.sh addition)

```bash
export AGENT_CATEGORY="ai"       # opencode, codex, claude-code, openclou, antigravity, pi, gentle-ai, engram
export AGENT_CATEGORY="editor"   # aider, neovim
export AGENT_CATEGORY="shell"    # sgpt, zsh, starship
export AGENT_CATEGORY="tools"    # fabric, goose, gh, fzf, gum, curl
export AGENT_CATEGORY="language" # node, python, rust, go
export AGENT_CATEGORY="db"       # sqlite, postgresql
export AGENT_CATEGORY="ui"       # termux-ui, banner
export AGENT_CATEGORY="automation" # n8n
```

### `NEXUS_RICH_AVAILABLE` (env.sh)

```bash
export NEXUS_RICH_AVAILABLE=$(python3 -c "from rich.console import Console" 2>/dev/null && echo true || echo false)
```

### `tui/guide.py` interface

- Entry: `python3 tui/guide.py` (called from bash, NEXUS_ROOT in env)
- Reads: `NEXUS_ROOT/config/agents.registry.sh` → parse `registry_get` output for each agent
- Renders: Rich `Table` per category with tool name, status, description
- Interactive: `rich.prompt.Prompt` for category selection; `subprocess.run(["nxai", "install"|"remove", name])`

## Testing Strategy

| Layer | What to Test | Approach |
|-------|-------------|----------|
| Syntax | All shell files | `bash -n` on every modified/created `.sh` file |
| Import | Rich availability | `python3 -c "from rich.console import Console"` after PYTHONPATH fix |
| Manual | Help variants | Run `nxai`, `nxai help`, `nxai --help` — verify banner + sections |
| Manual | Guide variants | Run `nxai guide`, `nxai guide ai`, `nxai guide invalid`, `nxai guide --interactive` |
| Manual | Fallback | Temporarily break Rich, verify `--interactive` falls back to bash |

## Migration / Rollout

No migration required. All 12 `metadata.sh` files are additive (new `export` line). `lib/nexus-guide.sh` and `tui/guide.py` are new files. The `show_help()` rewrite is a single-function replacement — existing callers get the new output automatically.

## Open Questions

- [ ] Should we validate `AGENT_CATEGORY` presence at registry time (warn if missing)?
- [ ] `guide --interactive`: Prompt-based navigation or full keyboard-driven TUI? (Prompt = simpler, falls back gracefully without textual)
