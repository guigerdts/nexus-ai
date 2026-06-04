# Design: v0.4 — CLI Presentation with Gum

## Technical Approach

**Option C (Hybrid):** Banner centralized in `nexus-log.sh` via `show_banner()`. Gum-specific features (table, confirm, spin) handled inline in each `nexus.sh` command with `if [ "$NEXUS_GUM_AVAILABLE" = true ]` / else legacy ANSI path. Clean split — banner guaranteed consistent, interactive features stay where they make sense.

## Architecture Decisions

### Decision: Color system unification

| Option | Tradeoff | Decision |
|--------|----------|----------|
| Keep dual sources (env.sh + nexus-log.sh) | Same ANSI codes in two places, drift risk | ❌ |
| Move ALL colors to env.sh, nexus-log.sh does TTY-check per function | Single source of truth, slight verbosity in each log function | ✅ |

**Rationale:** `env.sh` gets `NEXUS_COLOR_CYAN`, `NEXUS_COLOR_YELLOW`, `NEXUS_COLOR_RED`, `NEXUS_COLOR_GREEN`, `NEXUS_COLOR_GRAY`, `NEXUS_COLOR_RESET`. Each `log_*()` function in `nexus-log.sh` checks `[ -t 1 ]` before emitting codes. `_NEXUS_*` removed. `install.sh` references updated from `NEXUS_COLOR_PRIMARY` to `NEXUS_COLOR_CYAN`.

### Decision: Banner format with gum

| Option | Tradeoff | Decision |
|--------|----------|----------|
| `gum style` wrapping the whole block | All banner text same color (--foreground 51 cyan) — loses gray distinction in gum mode | ✅ |
| Multiple `gum style` calls per line | Over-engineering for a banner | ❌ |

**Rationale:** When gum is available, wrap entire ASCII art in `gum style --foreground 51 --border double --padding "1 2"`. The "by GUIGERDTS" line gets a separate `gum style --foreground 245` for the gray distinction. When gum is unavailable, use `echo -e` with ANSI (existing motd.sh pattern).

### Decision: TTY detection for interactive prompts

| Option | Tradeoff | Decision |
|--------|----------|----------|
| Always use `gum confirm` when gum available | Hangs in CI/pipe | ❌ |
| Check `[ -t 0 ]` before `gum confirm` | Safe in all contexts | ✅ |

**Rationale:** `gum confirm` blocks on stdin. Only interactive when stdin is a TTY. Fallback to log-based prompt or skip confirmation entirely when `[ -t 0 ]` is false.

### Decision: Gum install strategy

| Option | Tradeoff | Decision |
|--------|----------|----------|
| Termux `pkg install gum`, others GitHub tarball | Two code paths, but each is one-liner / well-understood | ✅ |
| GitHub tarball for all platforms | More complex for Termux (where pkg is native and simpler) | ❌ |

**Rationale:** Termux has official gum package — use it. Proot-Ubuntu/linux has no apt repo — download tarball to `$NEXUS_ROOT/bin/`. `--no-gum` flag skips Step 9 entirely.

## Data Flow

### show_banner()
```
env.sh ──→ NEXUS_COLOR_CYAN, NEXUS_GUM_AVAILABLE
motd.sh ──→ ASCII art block (figlet -f big)
              │
              ▼
     show_banner() in nexus-log.sh
              │
        ┌─────┴─────┐
        │ gum avail  │ not avail
        ▼            ▼
    gum style --    echo -e with
    foreground 51   ANSI codes
```

### nxai list with gum table
```
AGENT_ORDER[] ──→ loop rows ──→ CSV: Nombre,Tier,Estado,Descripcion
                                      │
                                 gum table --separator ","
                                      │
                                 stdout (bordered table)
```

### nxai install with gum
```
user: nxai install aider
  │
  ├─ show_banner()
  │
  ├─ [ -t 0 ] && gum available?
  │   YES → gum confirm "Instalar aider?"
  │         ├─ Yes → gum spin --title "Instalando..." -- source install.sh
  │         │         ├─ exit 0 → gum style green "OK"
  │         │         └─ exit ≠0 → gum style red "ERROR"
  │         └─ No  → abort silently
  │   NO  → current log_info/log_ok flow (no confirm, no spinner)
```

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `config/env.sh` | Modify | Add `NEXUS_GUM_AVAILABLE` detection, add `NEXUS_COLOR_YELLOW/RED/GREEN/GRAY`, keep `NEXUS_COLOR_PRIMARY` as alias for `NEXUS_COLOR_CYAN` |
| `lib/nexus-log.sh` | Modify | Remove `_NEXUS_*` color vars, add `show_banner()` function, add TTY check per log function |
| `core/nexus.sh` | Modify | Add `show_banner()` calls before each command (except help/--help/dashboard/ui), add gum table/confirm/spin inline with fallback |
| `install.sh` | Modify | Add Step 9 (gum install), add `--no-gum` flag, update step counter from 8 to 9 |

## Interfaces / Contracts

### show_banner()
```bash
# Returns: 0 always
# Side effects: outputs ASCII banner to stdout
# Depends on: NEXUS_GUM_AVAILABLE, NEXUS_COLOR_CYAN, NEXUS_COLOR_RESET
show_banner()
```

### NEXUS_GUM_AVAILABLE
```bash
# Set once at env.sh source time
export NEXUS_GUM_AVAILABLE=$(command -v gum &>/dev/null && echo true || echo false)
```

### Unified colors in env.sh
```bash
export NEXUS_COLOR_CYAN='\033[0;36m'
export NEXUS_COLOR_YELLOW='\033[0;33m'
export NEXUS_COLOR_RED='\033[0;31m'
export NEXUS_COLOR_GREEN='\033[0;32m'
export NEXUS_COLOR_GRAY='\033[0;37m'
export NEXUS_COLOR_RESET='\033[0m'
# Backward compat alias
export NEXUS_COLOR_PRIMARY="${NEXUS_COLOR_CYAN}"
```

### Banner exceptions (in nexus.sh case/esac)
```bash
case "$COMMAND" in
    dashboard|ui)   # NO show_banner
    help|--help|"") # NO show_banner
    *)              # show_banner before dispatch
```

## Testing Strategy

| Layer | What to Test | Approach |
|-------|-------------|----------|
| Manual | Each command with gum available | Install gum, run every `nxai` command, verify output |
| Manual | Each command without gum | `unset PATH` or rename gum binary, run every command, verify ANSI fallback |
| Manual | Non-TTY fallback | `echo "" | nxai install aider` — verify no hang, no spinner |
| Manual | `--no-gum` flag | `bash install.sh --no-gum` — verify Step 9 skipped |
| Manual | Banner exceptions | `nxai help`, `nxai --help`, `nxai dashboard`, `nxai ui` — verify no banner |

## Open Questions

- None. All decisions resolved in proposal, exploration, and specs.

## Migration / Rollout

No migration required. This is a cosmetic layer on top of existing functions. The legacy ANSI path is preserved as fallback — rollback is simply reverting the four modified files.
