# Delta for env-config

## ADDED Requirements

### Requirement: Termux accessibility detection

After `NEXUS_ENV` detection, check for Termux bind-mounts. When `NEXUS_ENV=proot-ubuntu` and `TERMUX_BIN` exists and is executable, set `NEXUS_TERMUX_ACCESSIBLE=true` and export `TERMUX_BIN`, `TERMUX_PREFIX`, `TERMUX_PKG`. Otherwise set `false`. Must NOT run on Linux puro or Termux native.

| Scenario | Condition | Result |
|----------|-----------|--------|
| proot + bind-mounts | `TERMUX_BIN` exists + executable | `NEXUS_TERMUX_ACCESSIBLE=true`, vars exported |
| proot no Termux | `TERMUX_BIN` missing | `NEXUS_TERMUX_ACCESSIBLE=false` |
| Linux puro | `NEXUS_ENV=linux` | `NEXUS_TERMUX_ACCESSIBLE=false` |
| Termux native | `NEXUS_ENV=termux` | `NEXUS_TERMUX_ACCESSIBLE=false` |

### Requirement: PATH unification

When `NEXUS_TERMUX_ACCESSIBLE=true`, MUST prepend `TERMUX_BIN` and `TERMUX_PREFIX/local/bin` to PATH. Each dir guarded by `[ -d "$dir" ]`.

| Scenario | Condition | Behavior |
|----------|-----------|----------|
| PATH includes Termux bins | `NEXUS_TERMUX_ACCESSIBLE=true` | Termux dirs prepended before system bin |
| Re-source idempotent | Sourced twice | No duplicate entries, no error |
