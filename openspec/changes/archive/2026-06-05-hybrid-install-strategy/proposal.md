# Proposal: Hybrid Install Strategy — Termux Bind-Mount Integration

## Intent

Proot-Ubuntu hits OOM when `pip3` compiles numpy from source. Termux bind-mounts (`/data/data/com.termux/files/usr/`) expose pre-compiled binaries — use them when available to avoid OOM and eliminate duplicate Python environments.

## Scope

### In Scope
- `NEXUS_TERMUX_ACCESSIBLE` auto-detection in `config/env.sh`
- PATH unification: Termux bin dirs added to `config/env.sh`, `shell/.bashrc`, `shell/.zshrc`, `install.sh`
- `install_via_pip` → use `TERMUX_PIP` when accessible
- `install_via_apt` → use `TERMUX_PKG` when accessible
- numpy pre-install in aider → use `TERMUX_PKG install python-numpy`
- Agent install scripts: fix `NEXUS_ENV` detection (don't defer to parent when Termux accessible)

### Out of Scope
- npm agent forwarding (not affected by OOM)
- pipx forwarding (already handles isolated envs)
- Termux-side changes
- Linux puro (no bind-mounts, no change)

## Capabilities

### New Capabilities

None — modifies existing capabilities only.

### Modified Capabilities
- `agent-install`: `install_via_pip` MUST prefer `TERMUX_PIP` when `NEXUS_TERMUX_ACCESSIBLE=true`; `install_via_apt` MUST map to `TERMUX_PKG` in same condition
- `env-config`: MUST export `NEXUS_TERMUX_ACCESSIBLE`; MUST prepend Termux bin dirs to PATH when bind-mounts exist
- `install-bootstrap`: PATH block MUST include Termux bind-mount dirs

## Approach

Detection-first at env.sh load time:
1. After `NEXUS_ENV=proot-ubuntu`, check `TERMUX_BIN` exists + executable
2. Set `NEXUS_TERMUX_ACCESSIBLE=true/false`
3. Prepend `TERMUX_BIN` and `TERMUX_PREFIX/local/bin` to PATH (conditional on dir existence)
4. `nexus-install.sh` reads `NEXUS_TERMUX_ACCESSIBLE` to select pip/pkg targets
5. Agent install scripts remove self-contained detection that defers to parent — check `NEXUS_TERMUX_ACCESSIBLE` for numpy/pkg decisions

On Linux puro: `TERMUX_BIN` missing → `NEXUS_TERMUX_ACCESSIBLE=false` → no change.
On Termux native: `NEXUS_ENV=termux` → existing path runs unchanged.

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `config/env.sh` | Modified | NEXUS_TERMUX_ACCESSIBLE detection + PATH |
| `lib/nexus-install.sh` | Modified | install_via_pip/apt prefer Termux |
| `modules/aider/install.sh` | Modified | Remove parent-defer; use pkg for numpy |
| `modules/fabric/install.sh` | Modified | Same detection fix |
| `modules/sgpt/install.sh` | Modified | Same detection fix |
| `shell/.bashrc` | Modified | PATH with Termux bind-mount dirs |
| `shell/.zshrc` | Modified | PATH with Termux bind-mount dirs |
| `install.sh` | Modified | PATH block with Termux bind-mount dirs |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Python version mismatch (Termux vs proot) | Med | Pin python version in pkg; test pip compat |
| Bind-mount missing some bins | Low | Check per-tool; fallback to proot pip/apt |
| PATH pollution on Linux puro | Low | Conditional on `[ -d "$dir" ]` guard |

## Rollback Plan

Revert each file: remove `NEXUS_TERMUX_ACCESSIBLE` block from env.sh, restore original install functions, remove Termux PATH lines from shell configs. No structural changes — pure config revert.

## Dependencies

- `config/env.sh` MUST change first (defines `NEXUS_TERMUX_ACCESSIBLE` consumed by all others)

## Success Criteria

- [ ] `NEXUS_TERMUX_ACCESSIBLE=true` inside proot-Ubuntu with Termux bind-mounts
- [ ] `install_via_pip aider-chat` uses Termux pip3 — no OOM on numpy
- [ ] `install_via_apt python-numpy` maps to `pkg install python-numpy`
- [ ] Linux puro shows zero PATH or behavior changes
