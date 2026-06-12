# Proposal: figlet-professional-enhancements

## Intent

Replace ad-hoc figlet logic duplicated across the codebase with a shared helper, and apply figlet rendering to four existing features (MOTD, status, install celebration, fatal errors) for a more professional, visually consistent terminal experience.

## Scope

### In Scope
1. **`lib/nexus-figlet.sh`** — new shared helper with `figlet_render()`: font chain small→mini→default, `command -v figlet`, `wc -L` vs terminal width, cyan color (parametrizable), fallback to uppercase+padding.
2. **MOTD** (`shell/motd.sh`) — use helper for figlet "NEXUS AI" header, respecting `NEXUS_MOTD_MODE`, one render per terminal session.
3. **`nxai status`** (`core/nexus.sh`) — figlet "STATUS" header via helper before `system_status()` output, with version below.
4. **Post-install celebration** (`core/nexus.sh` + `lib/nexus-install.sh`) — single install: figlet tool name + green check. Multi/bulk (`--all`): single figlet "COMPLETADO" + plain list. Only on interactive TTY with ≥80 columns.
5. **`log_fatal`** (`lib/nexus-log.sh`) — new function: figlet "ERROR" in red before fatal message, reserved for catastrophic failures only.

### Out of Scope
- Figlet for warnings or non-fatal errors
- New capabilities or spec-level requirements
- Figlet for `nxai list`, `nxai help`, or any command not listed above
- Changes to the existing `show_banner()` hardcoded ASCII art

## Capabilities

### New Capabilities
None — pure implementation enhancement, no spec-level changes.

### Modified Capabilities
None — behavior of existing features remains identical when figlet is unavailable.

## Approach

Extract the figlet rendering pattern from `lib/nexus-guide.sh:81-120` into `lib/nexus-figlet.sh::figlet_render()`. Each consumer calls the helper instead of duplicating the detection/font-chain/fallback logic. Consumers remain functional without figlet — fallback to uppercase+padding or existing plain-text output. Color defaults to cyan, overridable via `$2`.

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `lib/nexus-figlet.sh` | **New** | Shared figlet helper (`figlet_render`) |
| `shell/motd.sh` | Modified | Replace ASCII art block with figlet helper call |
| `core/nexus.sh` | Modified | Add figlet "STATUS" to `system_status`; add post-install figlet celebration to `install_agent` |
| `lib/nexus-install.sh` | Modified | Source helper and use for install celebration feedback |
| `lib/nexus-log.sh` | Modified | Add `log_fatal` function with figlet "ERROR" in red |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| figlet not installed on target | Medium | Fallback to uppercase+padding in helper; all consumers degrade gracefully |
| Performance on MOTD (per-shell) | Low | Font chain tries 3 fonts max, one attempt each; helper exits fast on failure |
| Session duplication (MOTD per shell) | Low | MOTD guard (`NEXUS_MOTD_MODE` + marker file) already exists |

## Rollback Plan

Revert changes to the 5 files listed in Affected Areas. Remove `lib/nexus-figlet.sh`. MOTD/nxai/log behavior returns to pre-change state immediately — no data migration needed.

## Dependencies

- `figlet` binary (optional — helper falls back gracefully)

## Success Criteria

- [ ] `figlet_render()` renders text through font chain, falls back to uppercase+padding when figlet absent or text too wide
- [ ] MOTD shows figlet "NEXUS AI" header once per terminal session, respects `NEXUS_MOTD_MODE`
- [ ] `nxai status` shows figlet "STATUS" with version below
- [ ] Single-agent install shows figlet tool name + green check on interactive TTY ≥80 cols
- [ ] `nxai install --all` shows single figlet "COMPLETADO" + plain agent list
- [ ] `log_fatal` shows red figlet "ERROR" before fatal message; `log_error`/`log_warn` unaffected
- [ ] All consumers work identically without figlet installed
