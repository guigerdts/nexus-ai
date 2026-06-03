## Exploration: NEXUS AI v0.2 — Agent Management System

### Current State

NEXUS AI v0.1 is a Termux/Android environment framework now finalized and archived. The codebase is structured with:

- **`config/env.sh`** — Environment detection (Termux/proot/linux), exports `NEXUS_ROOT`, `NEXUS_AGENTS_DIR`, `NEXUS_VERSION`, color vars, with idempotency guard
- **`install.sh`** — Bootstrap installer with CLI flags (`--help`, `--no-zsh`, `--dir`, etc.), 7-step progress, idempotent block markers, plugin system via git clone
- **`shell/.zshrc`** — 8 Zsh plugins in mandatory order, dual prompt (Starship → vcs_info), MOTD, PATH includes `$NEXUS_ROOT/bin`
- **`shell/motd.sh`** — Already forward-references `nexus help`, `nexus status`, `nexus update`, `nexus docs`, `nexus logs` in random tips — expects CLI to exist
- **`shell/starship.toml`** — Cyan #00BCD4 palette
- **`README.md`** — Documents v0.1 structure, flags, install/uninstall

**Empty directories awaiting v0.2:**
- `core/` — Where `nexus.sh` (the CLI) will live
- `modules/` — Where agent directories will go (`NEXUS_AGENTS_DIR` already exported in env.sh)
- `bin/` — Where the `nexus` symlink → `core/nexus.sh` will be placed (already in PATH via .zshrc)
- `lib/` — Where shared shell functions will live
- `logs/` — Already has nexus.log placeholder

**Key observations from v0.1 patterns:**
- Pure shell (no Python/Node/Go dependencies for the framework itself)
- CLI flags parsed with `while case/esac` pattern (see install.sh lines 51-85)
- Installation is idempotent via block markers (`# >>> NEXUS AI BEGIN >>>`)
- Plugins installed via `git clone --depth 1` into `shell/plugins/`
- Pure ASCII output enforced (no Unicode blocks/emoji)
- Spanish language for user-facing messages

### Affected Areas

- `core/nexus.sh` — NEW: main CLI entry point, all subcommands routed here. Installed as `bin/nexus` symlink.
- `config/env.sh` — EXTEND: add `NEXUS_VERSION="0.2.0"`, add agent-related environment vars
- `config/agents.registry` — NEW: agent registry (format TBD). Each agent: name, repo, install method, deps, version.
- `modules/<agent-name>/` — NEW: per-agent directories. Each contains agent binaries, metadata, config.
- `lib/nexus-*.sh` — NEW: shared library functions for logging, package manager detection, git operations
- `bin/nexus` — NEW: symlink pointing to `../core/nexus.sh`
- `install.sh` — MODIFY: add Step 8 for CLI installation and agent setup; bump to v0.2.0
- `shell/.zshrc` — MODIFY: add `nexus init` call (or agent auto-detection) on shell startup
- `shell/motd.sh` — UPDATE: tips now reference real commands instead of forward-looking hints
- `openspec/specs/` — NEW: specs for agent-registry, nexus-cli modules

### CLI Design Approaches

1. **Option A: Single script with case/esac subcommands (`core/nexus.sh`)**
   - Single file, `case $1 in install|status|update|...)` routing
   - Pros: Simple, follows existing install.sh pattern, single entry point, easy to symlink to `bin/`, easy to `-h` parse
   - Cons: Can grow large; all subcommand logic in one file
   - Effort: Low

2. **Option B: Multi-file CLI with lib functions**
   - `core/nexus.sh` as thin router sourcing `lib/nexus-install.sh`, `lib/nexus-status.sh`, etc.
   - Pros: Clean separation, functions reusable by other scripts, easier to test individual modules
   - Cons: More files, more sourcing overhead, overengineering for v0.2 scope
   - Effort: Medium

3. **Option C: Shell functions sourced in .zshrc**
   - Functions like `nexus-install()`, `nexus-status()` defined and exported in .zshrc
   - Pros: No separate binary needed, always available, taps into shell completion
   - Cons: Pollutes shell namespace, not callable from scripts, no discoverable `--help`, no clean subcommand API, breaks if user runs bash
   - Effort: Low

**Recommendation for CLI**: **Option A** (single script) for v0.2. It's the simplest, matches existing installer patterns, and can be refactored to Option B in a future version if it grows beyond ~500 lines. The `bin/nexus` symlink approach is already wired in `.zshrc` (`export PATH="$NEXUS_ROOT/bin:$PATH"`).

### Agent Registry Approaches

1. **Option A: YAML-based registry (`config/agents.yaml`)**
   - Each agent: name, repo URL, install method, deps, version tracking
   - Pros: Human-readable, well-structured, familiar from Docker Compose/GitHub Actions
   - Cons: Requires `yq` parser (not guaranteed on Termux), or fragile grep/sed parsing. Adding Python+YAML dependency violates v0.1's "no external parser" pattern.
   - Effort: Medium

2. **Option B: JSON-based registry (`config/agents.json`)**
   - Same schema as YAML but in JSON
   - Pros: Can parse with `python3 -c "import json"` (python3 available in proot), or `jq` if installed. More predictable than YAML.
   - Cons: Less human-friendly to edit by hand. Requires either `jq` or python3 dependency for reliable parsing. Grep/sed on JSON is fragile.
   - Effort: Medium

3. **Option C: Directory-based registry (`modules/<agent>/metadata.sh`)**
   - Each agent is a subdirectory under `modules/` with a `metadata.sh` file defining bash variables:
     ```bash
     AGENT_NAME="opencode"
     AGENT_SOURCE="npm"
     AGENT_PACKAGE="@opencode-ai/cli"
     AGENT_DESC="OpenCode AI coding assistant"
     AGENT_DEPS="nodejs npm"
     ```
   - Central index: `config/agents.registry.sh` sources all metadata files or defines an associative array
   - Pros: Zero dependencies (pure bash `source`), self-contained per agent, naturally extensible (add a directory = add an agent), easy to iterate with `for dir in "$NEXUS_AGENTS_DIR"/*/`, follows `shell/plugins/` pattern from v0.1
   - Cons: No standard schema enforcement, metadata is in bash (executable, not declarative — slight risk)
   - Effort: Low

**Recommendation for Registry**: **Option C** (directory-based). It's the most shell-native approach, requires no external parsers, and mirrors the existing `shell/plugins/` pattern from v0.1. Each agent is self-contained: `modules/opencode/metadata.sh`, `modules/aider/metadata.sh`, etc. The registry index (`config/agents.registry.sh`) can be an associative array auto-built by listing directories and sourcing their metadata.

### Agent Installation Approaches

Each agent uses a different install method. The install system MUST detect the environment (Termux vs proot) and install accordingly.

**Lifecycle per agent:**
- `install` → checks deps, installs via appropriate method, records version
- `uninstall` → removes files, reverses install
- `status` → checks if installed, reports version
- `update` → upgrade to latest

**Install method analysis:**

| Agent | Method | Deps | Risk |
|-------|--------|------|------|
| **OpenCode** | `npm install -g @opencode-ai/cli` (or go install) | nodejs, npm | Medium — already installed in this env |
| **Aider** | `pip install aider-chat` | python3, pip | Low — well-maintained pip package |
| **Fabric** | `pip install fabric-ai` (or git clone) | python3, pip, git | Low |
| **Shell-GPT** | `pip install shell-gpt` | python3, pip | Low |
| **Gentle AI** | TBD — likely `go install` or npm | go or nodejs | Medium — needs verification |
| **Pi** | Unknown — might be `pip install pi-ai` | TBD | High — needs research |
| **Codex** | `npm install -g @openai/codex` or pip | nodejs or python3 | Medium — OpenAI CLI tool |
| **Antigravity** | `pip install antigravity` (or similar) | python3, pip | Medium — uncommon tool |
| **Engram** | MCP protocol / Go binary | go or prebuilt binary | High — needs specific integration (not just pip/npm) |

**Shared installation helpers in `lib/`:**

```bash
lib/nexus-install.sh  # install/uninstall/status/update facade
lib/nexus-deps.sh     # dependency checking (has_npm, has_pip, has_go)
lib/nexus-log.sh      # logging to $NEXUS_LOG_FILE
```

Each agent in `modules/<name>/` gets:
- `metadata.sh` — descriptor (name, method, package, deps, version_cmd)
- `install.sh` — optional custom install logic (defaults to generic method)
- `uninstall.sh` — optional custom uninstall logic
- `config/` — per-agent configuration files

### Engram Integration

Engram is the persistent memory layer — already available as MCP tools in this environment:

- `engram_mem_save()` — save observations
- `engram_mem_search()` — search memory
- `engram_mem_context()` — get recent context
- `engram_mem_session_summary()` — summarize sessions
- etc.

**Integration approach for nexus CLI:**

1. **CLI surface**: `nexus memory` subcommand with sub-subcommands:
   - `nexus memory save` — save a memory from terminal
   - `nexus memory search` — search memories
   - `nexus memory context` — show recent context
   - `nexus memory summary` — session summary
   - `nexus memory status` — Engram connection health

2. **Backend options**:
   - **Option A: Shell wrapper around MCP** — Shell functions that call MCP tools via `opencode` or direct MCP protocol calls. Concern: MCP tools are only available inside an AI agent conversation, not from a terminal shell.
   - **Option B: Engram CLI binary** — If Engram exposes a standalone CLI, wrap it. Need to investigate if `engram` has a standalone binary.
   - **Option C: Python bridge** — Python script that imports the engram client library and exposes CLI interface.
   - **Option D: HTTP API** — If Engram runs as an MCP server with HTTP transport, nexus CLI can `curl` it.

   **Most likely**: Engram is integrated as an MCP server, meaning the `nexus memory` commands would need a bridge (Python or Go) to communicate with the MCP server from the terminal. This needs deeper investigation in the design phase.

3. **Auto-memory in MOTD**: The MOTD could show recent Engram context on startup (like "last session you were working on X").

### Recommendation

| Aspect | Chosen Approach | Rationale |
|--------|----------------|-----------|
| **CLI structure** | Option A — Single script with case/esac | Matches existing pattern, simple, easy to symlink |
| **Agent registry** | Option C — Directory-based with `metadata.sh` | Zero dependencies, extends naturally, mirrors plugins pattern |
| **Agent lifecycle** | Shared lib functions + per-agent hooks | `lib/nexus-install.sh` handles generic install; per-agent scripts override |
| **Engram integration** | Python bridge via `lib/nexus-engram.py` | MCP tools inaccessible from shell; Python bridge exposes memory commands |
| **Install method** | Extend `install.sh` → add Step 8 for CLI + agent foundation | Keeps single installer; future agent installs go through `nexus install` |

**Why not the other options:**
- JSON/YAML parsers are an unnecessary dependency for a shell framework
- Multi-file CLI would be overengineering for ~10 subcommands
- Never pollute .zshrc with CLI functions — they need to work in scripts and bash too

### Risks

1. **Engram integration complexity** — MCP tools are conversation-only; exposing memory CRUD from a terminal shell needs a bridge. If Engram doesn't provide a standalone CLI or HTTP API, this becomes significantly harder. **Mitigation**: Investigate Engram's published interfaces in the design phase before committing to an approach.

2. **Unknown agents** — Pi and Antigravity are less well-known; their install methods might be undocumented or unstable. **Mitigation**: Research each agent during the design phase; make agent entries optional with clear error messages.

3. **`set -euo pipefail` conflicts** — The installer uses strict mode, but `count_agents()` (`find | wc -l`) and similar patterns can break with empty directories. v0.1 already hit this. **Mitigation**: Continue the pattern of using `2>/dev/null || true` guards in agent iteration.

4. **Termux environment constraints** — Some agents may require compilation or have native bindings that don't build on Termux ARM64. **Mitigation**: Environment detection before install; warn or skip if incompatible.

5. **Version tracking drift** — Pinning agent versions (for reproducibility) vs always-latest (for simplicity) is a tradeoff. **Mitigation**: Start with always-latest; add version pinning if users request it.

6. **Pure ASCII constraint** — Some agent installers may output Unicode. The nexus CLI wrapper MUST strip or replace non-ASCII output for Termux compatibility.

### Ready for Proposal

**Yes** — exploration complete. The recommended architecture is:

1. **CLI**: Single `core/nexus.sh` with `case/esac` subcommands, symlinked to `bin/nexus`
2. **Registry**: Directory-based with `modules/<agent>/metadata.sh` (bash-sourced descriptors)
3. **Agent lifecycle**: `lib/nexus-install.sh` (shared) + per-agent `install.sh`/`uninstall.sh` hooks
4. **Engram**: Python bridge script (`lib/nexus-engram.py`) for terminal-to-MCP communication
5. **Install flow**: `install.sh` Step 8 installs CLI skeleton; per-agent install via `nexus install <agent>`

Next phase: **sdd-propose** to define intent, scope, and rollback plan for this architecture.
