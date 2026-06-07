# Proposal: NEXUS AI CLI Restructure (v0.8)

## Intent

The current `nxai` CLI uses flat `case/esac` dispatch with no category awareness, no flag parsing, and no per-module lifecycle management. 50 modules exist but 35+ tools from the spec are missing or stub-only. This restructure delivers category+flags syntax, module scaffolding, and GLIBC binary support — unlocking the full 84-tool spec.

## Scope

### In Scope
- CLI rewrite: `nxai <cmd> <category> --flags` syntax with backward-compat shim
- `bin/nxai` → symlink to `core/nexus.sh` (consolidate duplicate)
- Category manifest functions — read category from metadata.sh (NOT installed.txt)
- `uninstall.sh` + `update.sh` stubs for all 50 existing modules
- 35+ new stub modules (metadata.sh only) for missing tools
- GLIBC binary wrapper support (opencode, agy, claude-code on Termux native)
- Category→flag mapping in `config/categories.sh`
- `list` rewrite: 3-state table with flag column, category filter

### Out of Scope
- Full `install.sh` for new stub modules (stubs only — fill later)
- Dashboard TUI changes
- README rewrites or doc restructuring

## Capabilities

### New Capabilities
- `cli-parsing`: category+flags CLI parser with backward-compat flat shim
- `category-manifest`: category-based module tracking and listing
- `module-lifecycle`: per-module `uninstall.sh` + `update.sh` scaffolding
- `binary-compat`: GLIBC binary wrapper detection and install for Termux native

### Modified Capabilities
None — no existing spec-level capabilities.

## Approach

**Hybrid** — four chained PRs with feature-branch-chain strategy:
1. `config/categories.sh` + AGENT_FLAG in metadata.sh
2. CLI parser rewrite (resolve_args shim + category routing)
3. Category list table
4. Module lifecycle scripts + install_via_binary + new stubs

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `bin/nxai` | Modified | Become symlink to `core/nexus.sh` |
| `core/nexus.sh` | Modified | Full CLI parser rewrite |
| `config/categories.sh` | New | Category→flag mapping source of truth |
| `config/agents.registry.sh` | Modified | Add category-based lookup, AGENT_FLAG |
| `config/env.sh` | Modified | GLIBC detection, new manifest vars |
| `lib/nexus-install.sh` | Modified | Add category manifest functions |
| `lib/nexus-update.sh` | Modified | Add per-module update routing |
| `modules/*/{uninstall,update}.sh` | New | 50 pairs of lifecycle scripts |
| `modules/*/metadata.sh` | Modified | Add `AGENT_FLAG` |
| `modules/<35+ new>/` | New | Stub module directories |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| bin/nxai + nexus.sh divergence | High | Consolidate to symlink as PR1 |
| PR exceeds budget | High | Auto-chain into 4 PRs with 800-line/PR budget |
| New tools unknown install method | Med | Stub-only; research later |
| Old syntax users break | Med | Backward compat shim in parser |

## Rollback Plan

Per-PR rollback via `git revert <merge-commit>`. Each chained PR is self-contained.

## Dependencies

- bash ≥ 4.0 (associative arrays)
- curl, git (already present)

## Success Criteria

- [ ] `nxai list` shows correct 3-state table (INSTALADO/EXTERNO/NO INSTALADO)
- [ ] `nxai list ai` filters by category correctly
- [ ] `nxai install ai --opencode --engram` works with new flag syntax
- [ ] `nxai install opencode` (old syntax) still works via compat shim
- [ ] `nxai list` shows ≤ 84 tools (all spec entries present)
- [ ] All 50 existing modules have `uninstall.sh` + `update.sh`
- [ ] Missing spec tools show as "STUB" in list
- [ ] `bin/nxai` is a real symlink to `core/nexus.sh`
