# Design: Hybrid Install Strategy — Termux Bind-Mount Integration

## Technical Approach

Detection-first at `env.sh` load time: after `NEXUS_ENV` is resolved to `proot-ubuntu`, check `TERMUX_BIN` existence + executability. If true, export `NEXUS_TERMUX_ACCESSIBLE=true` and prepend Termux bin dirs to `PATH`. Downstream consumers (`nexus-install.sh`, agent installers, shell configs) read this single var to select `TERMUX_PIP`/`TERMUX_PKG` vs system `pip3`/`apt`.

## Architecture Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Detection locus | `config/env.sh`, after NEXUS_ENV block | Single source of truth — every sub-shell that sources env.sh gets the var; avoids per-script detection drift |
| Variable surface | `NEXUS_TERMUX_ACCESSIBLE` (bool), `TERMUX_BIN/PREFIX/PKG` (passthrough) | Bool for conditional branching, paths so consumers don't re-derive; `TERMUX_*` naming matches Termux env conventions |
| PATH assembly | `[ -d "$dir" ]` guard per entry, idempotent via `case ":$PATH:"` | Prevents pollution on Linux puro; idempotent re-source via `case` guard (existing pattern in `.bashrc`) |
| Agent NEXUS_ENV fix | Check `NEXUS_TERMUX_ACCESSIBLE` before parent-defer; numpy pre-install via `TERMUX_PKG` | Existing self-contained detection in agents would set `NEXUS_ENV=linux` (because `PREFIX`/`PROOT` absent); env.sh already loaded by nexus-install.sh, so the var flows through |
| `install_via_apt` mapping | Read `NEXUS_TERMUX_ACCESSIBLE`, not `NEXUS_ENV` | Existing code checks `NEXUS_ENV=termux` → would miss proot+Termux hybrid; `ACCESSIBLE` captures hybrid condition explicitly |

## Data Flow

```
env.sh load
  │
  ├─ detect NEXUS_ENV → proot-ubuntu
  ├─ [ -x /data/data/com.termux/files/usr/bin ]
  │     ├─ true  → NEXUS_TERMUX_ACCESSIBLE=true
  │     │           export TERMUX_BIN, TERMUX_PREFIX, TERMUX_PKG
  │     │           prepend TERMUX_BIN, TERMUX_PREFIX/local/bin to PATH
  │     └─ false → NEXUS_TERMUX_ACCESSIBLE=false
  │
  ├─ consumed by nexus-install.sh (sourced via env.sh)
  │     ├─ install_via_pip → TERMUX_PIP install --user
  │     ├─ install_via_apt → TERMUX_PKG install -y
  │     └─ both fallback → system pip3/apt
  │
  ├─ consumed by agent installers (modules/*/install.sh)
  │     ├─ numpy pre-install → TERMUX_PKG install python-numpy
  │     └─ NEXUS_ENV remains proot-ubuntu (no override)
  │
  └─ consumed by shell configs (.bashrc/.zshrc)
        └─ PATH guard: [ -d TERMUX_BIN ] → prepend
```

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `config/env.sh` | Modify | Add Termux accessibility block after line 78 (NEXUS_ENV detection) |
| `lib/nexus-install.sh` | Modify | `install_via_pip` check `NEXUS_TERMUX_ACCESSIBLE` first; `install_via_apt` map to TERMUX_PKG |
| `modules/aider/install.sh` | Modify | Replace `[ "$NEXUS_ENV" = "termux" ]` numpy guard with `NEXUS_TERMUX_ACCESSIBLE` check |
| `modules/fabric/install.sh` | Modify | Same detection fix — use `NEXUS_TERMUX_ACCESSIBLE` |
| `modules/sgpt/install.sh` | Modify | Same detection fix |
| `shell/.bashrc` | Modify | Add Termux PATH block after NEXUS_ROOT/bin PATH guard (line 29) |
| `shell/.zshrc` | Modify | Add Termux PATH block after PATH line (line 31) |
| `install.sh` | Modify | Add Termux bind-mount dirs to hardcoded PATH block (lines 505-540) |

## Interfaces / Contracts

```bash
# config/env.sh exports:
export NEXUS_TERMUX_ACCESSIBLE=true  # or false
# When true, also exports:
export TERMUX_BIN=/data/data/com.termux/files/usr/bin
export TERMUX_PREFIX=/data/data/com.termux/files/usr
export TERMUX_PKG=/data/data/com.termux/files/usr/bin/pkg
export TERMUX_PIP=/data/data/com.termux/files/usr/bin/pip3

# PATH additions (when accessible):
#   $TERMUX_BIN:/data/data/com.termux/files/usr/local/bin:$PATH
```

## Testing Strategy

| Layer | What to Test | Approach |
|-------|-------------|----------|
| Unit | `NEXUS_TERMUX_ACCESSIBLE` detection logic | Source env.sh with mocked dir existence; assert var values |
| Integration | `install_via_pip` selects TERMUX_PIP when ACCESSIBLE=true | Set var in sub-shell, source nexus-install.sh, test command resolution |
| Smoke | Linux puro: zero PATH change | Source env.sh on Linux — assert no `/data/data/com.termux` PATH entries |

## Migration / Rollout

No migration required. All changes are runtime-detection: existing installs pick up Termux bind-mounts on next `source env.sh` or re-login. Rollback: revert the 8 modified files to their current content.

## Open Questions

- None identified. Detection logic, fallback chains, and idempotency are fully specified.
