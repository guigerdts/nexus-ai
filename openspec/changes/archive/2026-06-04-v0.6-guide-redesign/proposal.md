# Proposal: v0.6 — Guide & Help Redesign

## Intent

Current `nxai help` is a basic heredoc dump — no categories, no hierarchy, no quick start. Users have no way to explore available modules by domain or get an interactive overview. v0.6 delivers a professional help screen, a categorized guide system, and module metadata to support categories.

## Scope

### In Scope
1. AGENT_CATEGORY in all 12 `metadata.sh` files per user's category assignments
2. `export PYTHONPATH` fix in `config/env.sh` for Rich import
3. Redesigned `show_help()` with banner + Usage + grouped Commands + Quick Start + Module Targets
4. `nxai guide` routing in `core/nexus.sh`
5. `lib/nexus-guide.sh` — bash guide for `guide` and `guide <category>`
6. `tui/guide.py` — Rich interactive guide for `--interactive`
7. Stub categories listed but no install logic

### Out of Scope
- Actual install of stubs (db, ui, automation)
- Complete removal of legacy help format
- Dashboard TUI redesign

## Capabilities

### New Capabilities
- **guide-command**: `nxai guide`, `nxai guide <category>`, `nxai guide --interactive`
- **help-redesign**: new professional `nxai`/`nxai help` output

### Modified Capabilities
- **nexus-cli**: help text format changes — new banner, grouped commands, quick start section

## Approach

1. **Help**: Pure bash `show_help()` with `printf` + ANSI — zero deps
2. **Guide**: Hybrid — bash for basic guide (cat/less), Python/Rich for `--interactive`
3. **Categories**: `AGENT_CATEGORY` in each `metadata.sh`, read by `agents.registry.sh`
4. **Rich fix**: `export PYTHONPATH` in `config/env.sh`; fallback `--break-system-packages`

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `core/nexus.sh` | Modified | New `show_help()`, guide routing |
| `config/env.sh` | Modified | PYTHONPATH for Rich |
| `config/agents.registry.sh` | Modified | Read AGENT_CATEGORY |
| `modules/*/metadata.sh` | Modified | Add AGENT_CATEGORY (12 files) |
| `lib/nexus-guide.sh` | Created | Bash guide functions |
| `tui/guide.py` | Created | Rich interactive guide |
| `openspec/specs/nexus-cli/spec.md` | Modified | Delta for help behavior |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Rich still broken after PYTHONPATH fix | Low | Fallback to bash guide |
| 12 metadata files inconsistent | Med | Validation step in tasks |
| Help/category format drifts | Med | CI check AGENT_CATEGORY presence |

## Rollback Plan

Revert: restore `core/nexus.sh` `show_help()`, remove PYTHONPATH line from `env.sh`, revert AGENT_CATEGORY in all 12 `metadata.sh`. Delete `lib/nexus-guide.sh` and `tui/guide.py`.

## Dependencies

- Rich 15.0.0 (already installed, PYTHONPATH fix needed)
- python3 available (confirmed)

## Success Criteria

- [ ] `nxai help` shows professional grouped output, no errors
- [ ] `nxai guide` lists categories; `nxai guide <cat>` shows category agents
- [ ] `nxai guide --interactive` launches Rich TUI
- [ ] All 12 `metadata.sh` have AGENT_CATEGORY set
- [ ] `python3 -c "from rich.console import Console"` succeeds after PYTHONPATH fix
