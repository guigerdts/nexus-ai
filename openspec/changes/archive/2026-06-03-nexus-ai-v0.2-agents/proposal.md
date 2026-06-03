# Proposal: NEXUS AI v0.2 - Agentes y CLI

## Intent

Extend NEXUS AI from static Termux environment to extensible agent platform:
CLI subcommands, directory-based registry, per-agent lifecycle, custom agent
support. Users manage agents without modifying core code.

## Scope

### In Scope
- CLI: core/nexus.sh with case/esac subcommands, symlinked to bin/nexus
- Registry: modules/<name>/{metadata.sh,install.sh,test.sh,README.md}
- 11 agents across 3 tiers (opencode, codex, aider, antigravity, pi, fabric,
  sgpt, goose, engram, gentle-ai, openclou)
- Stub modules for unknown install methods (show manual instructions, never block)
- `nexus agent add <name> <url>` and `nexus agent test <name>`
- Engram memory via lib/nexus-engram.py (Python bridge for MCP)
- install.sh Step 8 for CLI+registry bootstrap

### Out of Scope (v0.3+)
- GUI/TUI dashboard
- Agent version pinning (always-latest)
- NEXUS plugin system (non-agent extensions)
- Multi-node orchestration
- CI/CD for agent test results

## Capabilities

### New Capabilities
- `nexus-cli`: Single core/nexus.sh entry point, case/esac subcommand routing,
  bin/nexus symlink. Commands: install, list, status, remove, update, agent,
  memory, help.
- `agent-registry`: Directory-based index. modules/<name>/metadata.sh bash-
  sourced. config/agents.registry.sh auto-builds associative array from
  modules/ listing. Extensible via `nexus agent add`.
- `agent-install`: Per-agent lifecycle (install, uninstall, test).
  lib/nexus-install.sh shared facade + per-agent hooks. Environment-aware
  (Termux vs proot). `nexus test <name>` runs test.sh reports PASS/FAIL.
- `engram-memory`: Python bridge (lib/nexus-engram.py) for `nexus memory`
  subcommands (save, search, context, summary, status). Connects terminal to
  Engram MCP server.

### Modified Capabilities
- `env-config`: Bump NEXUS_VERSION to 0.2.0. Add NEXUS_MODULES_DIR,
  NEXUS_REGISTRY vars.
- `install-bootstrap`: Add Step 8 for CLI skeleton + registry foundation.
  Update MOTD tips from forward-looking to real commands.

## Approach

Single core/nexus.sh routes subcommands via case/esac. Registry =
modules/*/metadata.sh sourced by bash. Shared lib/ for install/deps/log.
Engram via Python bridge. install.sh extended with Step 8. Pure ASCII output.

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| core/nexus.sh | NEW | CLI entry point |
| bin/nexus | NEW | Symlink -> ../core/nexus.sh |
| modules/<agent>/ | NEW | 11 agent directories |
| lib/nexus-install.sh | NEW | Install/uninstall/test facade |
| lib/nexus-deps.sh | NEW | Dep checker (has_npm, has_pip, etc) |
| lib/nexus-log.sh | NEW | CLI logging |
| lib/nexus-engram.py | NEW | Python MCP bridge for memory |
| config/agents.registry.sh | NEW | Registry index |
| config/env.sh | MODIFY | VERSION bump, agent vars |
| install.sh | MODIFY | Step 8 CLI bootstrap |
| shell/motd.sh | MODIFY | Real command tips |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Engram MCP bridge complexity | Med | Verify Engram publishes standalone interface in design |
| Unknown pi/antigravity install | High | Stub with manual instructions, never block |
| Termux ARM64 compat | Med | Env detection before install, warn |
| set -euo pipefail breaks | Low | current || true guards on iteration |
| Stub modules accumulate dust | Low | test.sh reports UNKNOWN for untested |

## Rollback Plan

1. rm bin/nexus
2. rm -rf core/ lib/ modules/
3. Revert config/env.sh NEXUS_VERSION to 0.1.0, remove agent vars
4. Revert install.sh: remove Step 8, restore 7-step progress
5. Revert shell/motd.sh: restore forward-looking tips
6. Each step idempotent via block markers (existing pattern)

## Dependencies

- Bash 5.0+ (confirmed in Termux)
- Python 3.x for Engram bridge (available in Termux/proot)
- No external parsers (yq, jq) needed

## Success Criteria

- [ ] `nexus install --all` installs all 11 agents without blocking on unknown methods
- [ ] `nexus list` shows correct installed/not-installed status per agent
- [ ] `nexus agent add foo <url>` creates modules/foo/ with skeleton files
- [ ] `nexus agent test opencode` runs test.sh and reports PASS or FAIL
- [ ] `nexus status` shows environment health (env, arch, agent count)
- [ ] `nexus memory save "test"` writes via Python bridge without errors
- [ ] install.sh Step 8 completes without breaking existing v0.1 installations
- [ ] All output is pure ASCII (no Unicode blocks, no emoji)
