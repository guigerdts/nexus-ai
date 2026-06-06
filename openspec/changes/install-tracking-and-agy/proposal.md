# Proposal: Install Tracking and Antigravity CLI (agy)

## Intent

Two fixes: (1) `nxai list` shows INSTALADO for any binary in PATH, false positives for tools nxai never installed. (2) gemini-cli sunsets June 18; `modules/antigravity/` points to a third-party repo, not Google's official `agy`.

## Scope

### In Scope
- `logs/installed.txt` manifest — source of truth for nxai-tracked installs
- `update_installed_manifest()` in `lib/nexus-install.sh`, called from install/remove flows
- Three-state `list_agents()`: INSTALADO (manifest+PATH), EXTERNO (PATH only), NO INSTALADO (neither)
- New `modules/agy/` — `AGENT_METHOD="curl"`, Google official install script
- `modules/antigravity/` redirects to agy
- Deprecation banner on `modules/gemini-cli/install.sh`

### Out of Scope
- Replacing `agents.log` (separate audit trail, stays)
- Shell test framework (no runner available)
- Porting antigravity install logic — just redirect

## Capabilities

### New Capabilities
- None — `agy` is a new agent module, existing `agent-registry` covers it

### Modified Capabilities
- `agent-install`: new `update_installed_manifest()`, new `installed.txt`
- `nexus-cli`: EXTERNO status in list; install/remove sync manifest
- `agent-registry`: status detection changes from pure `command -v` to manifest+PATH

## Approach

1. Add `update_installed_manifest(agent, action)` to `lib/nexus-install.sh`
2. Call from `mark_installed()`/`mark_removed()` (already called from install/remove)
3. Rewrite `list_agents()`: read `installed.txt` first, then `command -v` — three states
4. Create `modules/agy/` with Google install script URL
5. Update `modules/antigravity/metadata.sh` to redirect
6. Add deprecation banner to `modules/gemini-cli/install.sh`

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `lib/nexus-install.sh` | Modified | Add `update_installed_manifest()`, call from `mark_*` |
| `core/nexus.sh` | Modified | `list_agents()`, `install_agent()`, `remove_agent()` manifest-aware |
| `logs/installed.txt` | New | Manifest file (one agent name per line) |
| `modules/agy/` | New | 4 files: metadata.sh, install.sh, test.sh, README.md |
| `modules/antigravity/` | Modified | Redirect to agy |
| `modules/gemini-cli/install.sh` | Modified | Add deprecation warning |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| `installed.txt` desyncs | Low | EXTERNO status visible for PATH-only binaries |
| `agy` install URL changes | Med | `AGENT_URL` has GitHub fallback reference |

## Rollback Plan

- Revert `core/nexus.sh` + `lib/nexus-install.sh` — falls back to `command -v` only
- Delete `logs/installed.txt` — no effect on `agents.log`
- Remove `modules/agy/` — antigravity stub remains

## Dependencies

- `curl` available for agy install (already a system dep)
- `agy` binary at `/data/data/com.termux/files/usr/bin/agy` (already present)

## Success Criteria

- [ ] `nxai list`: EXTERNO for `claude-code`, `mongodb`, `nerd-fonts`
- [ ] `nxai list`: INSTALADO for agents in `installed.txt`
- [ ] `nxai install agy` downloads from official script, registers in manifest
- [ ] `nxai install gemini-cli` shows deprecation warning with sunset date
- [ ] `nxai list`: NO INSTALADO for agents not in manifest nor PATH
