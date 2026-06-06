## Archive Report

**Change**: install-tracking-and-agy
**Archived at**: 2026-06-06
**Archive path**: `openspec/changes/archive/2026-06-06-install-tracking-and-agy/`
**Mode**: openspec

### Verdict on Archive
- Verify report: **PASS WITH WARNINGS**
- CRITICAL issues: 0
- WARNINGS: 1 (Phase 6 manual verification tasks incomplete — requires on-device testing)
- Safe to archive: ✅ Yes

### Specs Synced

| Domain | Action | Details |
|--------|--------|---------|
| agent-install | Updated | 1 requirement modified (Shared install functions — +1 function, updated 2 descriptions), 1 requirement added (Install manifest tracking — 3 scenarios) |
| nexus-cli | Updated | 1 requirement modified (Subcommand operations — three-state coloring, +2 scenarios, 2 updated), 1 requirement modified (Gum formatting — three-state fallback) |
| agent-registry | Updated | 1 requirement added (Install status detection — 4 scenarios, three-state model) |

### Archive Contents
- proposal.md ✅
- specs/ ✅ (3 domain specs: agent-install, nexus-cli, agent-registry)
- design.md ✅
- tasks.md ✅ (17/19 tasks complete)
- verify-report.md ✅
- archive-report.md ✅

### Source of Truth Updated
The following specs now reflect the new behavior:
- `openspec/specs/agent-install/spec.md`
- `openspec/specs/nexus-cli/spec.md`
- `openspec/specs/agent-registry/spec.md`

### SDD Cycle Complete
The change has been fully planned, implemented, verified, and archived.
Ready for the next change.

### Merge Summary

#### agent-install
- **MODIFIED** "Shared install requirements": Updated function table — `mark_installed()` and `mark_removed()` now sync to `installed.txt` manifest; added `update_installed_manifest(agent, action)` function
- **ADDED** "Install manifest tracking": New requirement with 3 scenarios (install adds, remove deletes, remove-non-installed is no-op)

#### nexus-cli
- **MODIFIED** "Subcommand operations": Updated description to three-state (INSTALADO/EXTERNO/NO INSTALADO); replaced "List shows agent status" with "List shows agent status with three states"; added "EXTERNO detection for PATH-only agents" and "INSTALADO shows for manifest-tracked agents" scenarios; updated "Remove uninstalls an agent" to include manifest removal
- **MODIFIED** "Gum formatting with fallback": Added previous-state note; updated list fallback scenario to show [EXTERNO] state

#### agent-registry
- **ADDED** "Install status detection": New requirement with 4 scenarios — manifest-tracked (INSTALADO), PATH-only (EXTERNO), neither (NO INSTALADO), stale manifest (NO INSTALADO)
