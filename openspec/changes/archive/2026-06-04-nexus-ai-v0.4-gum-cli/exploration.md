## Exploration: v0.4 — CLI Presentation with Gum (Charm.sh)

### Current State

The CLI (`core/nexus.sh`) uses raw `echo` and `echo -e` with ANSI escape codes for all output. Formatting is minimal — colored prefix labels (`[OK]`, `[INFO]`, `[WARN]`, `[ERROR]`) plus plain strings. No borders, no tables, no spinners, no interactive prompts.

**Per-function output format today:**

| Function | Format | Color source |
|----------|--------|-------------|
| `show_help()` | `cat <<EOF` heredoc — plain text | None |
| `list_agents()` | `echo -e` with `_NEXUS_CYAN`/`_NEXUS_YELLOW` labels; two-line per agent | `nexus-log.sh` |
| `install_agent()` | `log_info/log_warn/log_ok` — prefix-style | `nexus-log.sh` |
| `remove_agent()` | `log_error/log_warn/log_ok` — prefix-style | `nexus-log.sh` |
| `agent_test()` | `log_ok` (PASS), `log_error` (FAIL/TIMEOUT) | `nexus-log.sh` |
| `agent_add()` | `log_info/log_error/log_ok` — prefix-style | `nexus-log.sh` |
| `system_status()` | `echo` with `key: value` format, no labels | None (plain) |
| `dashboard/ui` | `echo` inline strings | None |

**Notable:** there are **two color systems** — `env.sh` exports `NEXUS_COLOR_PRIMARY`/`NEXUS_COLOR_RESET` (used by `install.sh`), while `nexus-log.sh` defines `_NEXUS_CYAN`/`_NEXUS_YELLOW`/`_NEXUS_RED`/`_NEXUS_RESET` (used by `core/nexus.sh`). They use the same ANSI cyan but are declared independently.

There is currently **no banner** displayed before commands.

Gum is **not installed** on this system. GitHub releases confirm `gum_0.17.0_Linux_arm64.tar.gz` is available for ARM64.

### Affected Areas

- `core/nexus.sh` — **Main impact.** Every function's output format changes. Banner display logic added at the top of each command. Case/esac routing may need to separate `help`/`--help` for banner exception.
- `lib/nexus-log.sh` — Add optional `gum_*` wrapper functions (with fallback to current ANSI output). May also get a centralized `show_banner()` function to avoid duplication.
- `config/env.sh` — New variable `NEXUS_GUM_AVAILABLE` set once at startup for reuse across all functions.
- `install.sh` — Add optional Gum installation step: `pkg install gum` for Termux, GitHub tarball download for proot-Ubuntu/linux.
- `config/agents.registry.sh` — No changes needed, but the `registry_list()` helper provides structured data that `list_agents()` can pipe to `gum table`.

### Gum Features to Use Per Command

| Command | Gum feature | Purpose |
|---------|------------|---------|
| **all** (except help) | `gum style --foreground 212 --border double --padding "1 2"` | Banner box |
| `nxai list` | `gum table --separator "," --border rounded` | Structured table: Nombre, Tier, Estado, Descripcion |
| `nxai status` | `gum style --border rounded --padding "1 2"` | Bordered system info panel |
| `nxai install` | `gum confirm` + `gum spin --spinner dot --title "Instalando..."` | Interactive confirmation + spinner |
| `nxai remove` | `gum confirm` (obligatorio) + `gum spin` | Safety confirmation |
| `nxai agent test` | `gum spin --title "Probando..."` + `gum style` for PASS/FAIL | Spinner during test run |
| `nxai help` | **No banner** (exception) | Keep current format |

### Install Approaches

| Approach | Termux | proot-Ubuntu | Linux (generic) |
|----------|--------|-------------|-----------------|
| **A: distro package** | `pkg install gum` — official Termux package (simplest) | `apt install gum` — NOT available in Ubuntu repos | N/A |
| **B: GitHub tarball** | Also works: download `gum_linux_arm64.tar.gz` from charmbracelet/gum/releases | Download + extract to `~/.local/bin` (recommended) | Works everywhere |
| **C: Go install** | `go install github.com/charmbracelet/gum@latest` — requires Go toolchain | Same — requires Go | Same — requires Go |

**Recommendation:** Use **A for Termux** (one-liner) and **B for proot-Ubuntu/linux** (no Go dependency, no apt repo needed). GitHub releases are signed and stable. Save binary to `$NEXUS_ROOT/bin/` so it's in the project-local PATH.

### Architecture Options

#### Option A: Banner + gum wrappers in each function

Each function in `core/nexus.sh` independently implements its own banner display and gum formatting.

```bash
list_agents() {
    $NEXUS_GUM_AVAILABLE && show_banner
    if [ ${#AGENTS[@]} -eq 0 ]; then
        log_info "No hay agentes registrados..."
        return 0
    fi
    if [ "$NEXUS_GUM_AVAILABLE" = true ]; then
        # gum table version
        ...
    else
        # current echo version
        ...
    fi
}
```

- **Pros:** Explicit control per function, no hidden magic
- **Cons:** High duplication — banner call, availability check, formatting in every function
- **Effort:** Medium

#### Option B: Centralized banner + gum helpers in `nexus-log.sh`

Move ALL gum logic into `nexus-log.sh`. Add `gum_echo()`, `gum_style()`, `gum_spin_wrap()` helper functions that internally check `NEXUS_GUM_AVAILABLE`. Each function in `core/nexus.sh` becomes a simple call.

```bash
# in nexus-log.sh:
gum_table() { ... }    # pipes data to gum table or formats as text
gum_banner() { ... }   # shows banner or silent
log_ok() { ... }       # checks NEXUS_GUM_AVAILABLE internally
```

- **Pros:** Maximum DRY, clean nexus.sh functions, centralized fallback logic
- **Cons:** `gum table` and interactive features like `gum confirm` are hard to abstract behind a simple function — `gum confirm` is inherently interactive and command-specific
- **Effort:** High

#### Option C: Hybrid (banner centralized, gum inline in each command)

**The sweet spot.** Centralize: banner display, `NEXUS_GUM_AVAILABLE` detection, and basic gum style helpers (colored output, borders) in `nexus-log.sh`. Each command still handles its specific gum features (table, confirm, spin) inline with explicit fallback to legacy code.

```bash
# nexus-log.sh:
show_banner() { ... }                    # centralized banner
gum_or_echo() { ... }                    # style wrapper with fallback
log_ok/log_info/log_error/log_warn() { ... }  # gum-enhanced with fallback

# nexus.sh:
list_agents() {
    show_banner
    if [ "$NEXUS_GUM_AVAILABLE" = true ]; then
        # gum table inline — easier than abstracting tables
    else
        # legacy loop
    fi
}
```

- **Pros:** Clean separation, banner guaranteed consistent, interactive features stay where they make sense, easy to reason about fallback
- **Cons:** Some `if available; then gum; else legacy; fi` repetition in 3-4 commands
- **Effort:** Low-Medium

### Recommendation

**Option C: Hybrid.** Rationale:

1. **Banner MUST be consistent** across all commands — centralizing it in `nexus-log.sh` guarantees every command (except help) shows the exact same banner without each function repeating the ASCII art.
2. **`gum confirm` and `gum spin` are command-specific** — they need access to specific variables (agent name, install output) and interactive flow. Abstracting them into generic helpers would be leaky and over-engineered.
3. **`gum table` for `list_agents()`** is best kept in the function itself — it needs the loop that builds `AGENT_ORDER` data. A generic helper would require passing arrays, which is awkward in Bash.
4. **Fallback logic is simplest in this model** — the banner helper does `command -v gum`, each command's gum-specific code is wrapped in a single `if` block, and the legacy path remains untouched.
5. `nexus-log.sh` already provides `log_*` functions — these become the natural home for gum-enhanced output that replaces ANSI prefixes.

The hybrid model keeps the **hot path** (gum features) close to the data they operate on, and the **cold path** (banner + detection) centralized for consistency.

### Risks

- **Gum not available at runtime** — handled by `command -v gum` check and graceful fallback to current ANSI output. Must test both paths on each command.
- **Gum not available at install time** — handled during `install.sh` as optional dependency. If download fails, continue with warning.
- **`gum table` column alignment** — agent names and descriptions have variable length. `gum table` auto-aligns by column separator, but very long descriptions may wrap awkwardly. Use `--columns` flag to control widths, or truncate descriptions past 40 chars in the table view.
- **`gum confirm` in non-interactive contexts** — `gum confirm` blocks waiting for stdin. If `nxai remove` is piped or run in CI, it would hang. Mitigation: fallback to log-based prompt when stdin is not a TTY (`[ -t 0 ]`).
- **Banner repetition** — having the banner on `nxai list`, `nxai status`, `nxai install`, etc. is the requirement, but users running `nxai install aider && nxai status` will see the banner twice. This is by design per the requirements.
- **ARM64 binary compatibility** — verified: `gum_linux_arm64.tar.gz` exists in v0.17.0 release. No architecture risk.
- **Duplicate color systems** — After gum integration, `env.sh`'s `NEXUS_COLOR_PRIMARY` and `nexus-log.sh`'s `_NEXUS_CYAN` should be unified to avoid confusion. This is a minor cleanup opportunity.

### Ready for Proposal

**Yes.** The change is well-defined, the codebase is fully understood, and all three architecture options have been evaluated with clear tradeoffs. The hybrid approach (Option C) is recommended.

The proposal phase should clarify:
- Whether `--no-gum` flag should be added to install.sh to explicitly skip gum installation
- Whether the `dashboard`/`ui` subcommand and `show_help()` functions are truly the only two exceptions to the banner rule
- Whether the `_NEXUS_CYAN`/`NEXUS_COLOR_PRIMARY` duplication should be resolved as part of this change or deferred
