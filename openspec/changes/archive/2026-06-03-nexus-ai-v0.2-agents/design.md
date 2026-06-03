# Design: NEXUS AI v0.2 - Agentes y CLI

## Technical Approach

Single `core/nexus.sh` with case/esac subcommand routing, directory-based agent autodiscovery via `modules/*/metadata.sh`, shared install library at `lib/nexus-install.sh`, and direct `engram` CLI wrapping (no Python bridge needed -- engram v1.16.1 CLI confirmed available at `/data/data/com.termux/files/usr/bin/engram`). Patterns follow v0.1's `install.sh` while-case and `config/env.sh` idempotency conventions.

## Architecture Decisions

### Decision: CLI Structure

| Option | Tradeoff | Decision |
|--------|----------|----------|
| Single file case/esac | Grows large, matches install.sh pattern | **SELECTED** |
| Multi-file lib routing | Overengineering for ~10 subcommands | Rejected |
| Zsh functions | Not callable from bash/scripts | Rejected |

`core/nexus.sh` routes `$1` via case/esac. Color on `[ -t 1 ]`. Symlink `bin/nexus -> ../core/nexus.sh`.

### Decision: Agent Registry

| Option | Tradeoff | Decision |
|--------|----------|----------|
| Directory-based metadata.sh | Zero deps, bash source, mirrors shell/plugins/ | **SELECTED** |
| YAML config | Needs yq/jq, violates no-external-dep rule | Rejected |
| JSON config | Fragile grep/sed parsing | Rejected |

Modules provide `AGENT_NAME|VERSION|DESC|URL|TIER|METHOD|BINARY`. `config/agents.registry.sh` auto-builds assoc array via `for dir in $NEXUS_MODULES_DIR/*/`.

### Decision: Install Library

| Option | Tradeoff | Decision |
|--------|----------|----------|
| Shared lib/nexus-install.sh | Idempotent, reusable, sourceable | **SELECTED** |
| Inline per module | Duplicated logic | Rejected |

Functions: `check_dependency`, `install_via_pip|npm|curl|apt|cargo`, `mark_installed`, `mark_removed`. Termux maps `install_via_apt` to `pkg install`.

### Decision: Engram Integration

| Option | Tradeoff | Decision |
|--------|----------|----------|
| Direct engram CLI wrapper | Binary v1.16.1 confirmed in PATH with save/search/context/stats | **SELECTED** |
| Python MCP bridge | Overengineering -- standalone CLI works from bash | Rejected |

`nexus memory` wraps `engram save|search|context|stats` directly. Module is functional, not stub.

## Data Flow

```
Usuario --> bin/nexus (symlink)
                |
                v
          core/nexus.sh
                |
         case $1 in
         +------+------+------+------+------+
         |      |      |      |      |      |
        install list  status remove  agent  memory
           |      |      |      |      |       |
           v      v      v      v      v       v
    lib/nexus-   ls     env    mark_ source   engram
    install.sh  modules/ vars  removed metadata save/search
         |                      modules/  /context
         v
    modules/<name>/install.sh
         |
    install_via_pip|npm|curl|apt|cargo
         |
    test.sh (PASS/FAIL)
         |
    logs/agents.log
```

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `core/nexus.sh` | Create | CLI entry point, case/esac routing |
| `bin/nexus` | Create | Symlink `-> ../core/nexus.sh` |
| `lib/nexus-install.sh` | Create | Install functions (pip/npm/curl/apt/cargo) |
| `lib/nexus-log.sh` | Create | `[OK]`/`[WARN]`/`[ERROR]`/`[INFO]` helpers |
| `config/agents.registry.sh` | Create | Auto-built assoc array from modules/ |
| `config/env.sh` | Modify | VERSION 0.2.0, add NEXUS_MODULES_DIR, NEXUS_REGISTRY |
| `install.sh` | Modify | Step 8 (CLI + registry), 8/8 progress |
| `shell/motd.sh` | Modify | Real commands, remove "(proximamente)" |
| `modules/{aider,opencode,codex,antigravity,pi,fabric,sgpt,goose,engram,gentle-ai,openclou,claude-code}/` | Create | 12 agent dirs with metadata.sh, install.sh, test.sh, README.md

## Cross-cutting Decisions

| Decision | Option | Rationale |
|----------|--------|-----------|
| Output format | `[OK]`/`[WARN]`/`[ERROR]`/`[INFO]` | Consistent, parseable, Spanish |
| Color | Conditional on `[ -t 1 ]` | No ANSI in pipes |
| Stub agents | Manual instructions, exit 0 | Never block `nexus install --all` |
| Engram | Direct CLI wrapping | v1.16.1 at /data/data/.../bin/engram with save/search/context/stats |

## Implementation Order

Per user: 1) lib/nexus-install.sh, 2) core/nexus.sh, 3-13) 11 agent modules, 14) nexus agent add/test, 15) install.sh Step 8.

## Migration / Rollout

No migration required. All directories (core/, lib/, modules/, bin/) already exist empty. Installer Step 8 creates files into existing structure. Rollback: `rm bin/nexus && rm -rf core/ lib/ modules/` and revert env.sh VERSION.

## Open Questions

- [x] Engram CLI: confirmed available -- engram v1.16.1 with all required subcommands
- [ ] `pi` and `antigravity` exact pip package names -- TBD during apply per agent
- [ ] `gentle-ai` install method -- TBD (likely npm or go install, stub for now)
