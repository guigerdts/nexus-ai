# Spec: update-command

**Domain**: update-command
**Change**: v0.5-update-system
**Version**: 1.0.0
**Status**: Final

## Overview

User-facing update commands for Nexus AI: `nxai update` (apply update) and `nxai update --check` (verbose check with changelog).

## Requirements

### UD-1: `nxai update --check` — Verbose version check

When the user runs `nxai update --check` (or `-c`), the system MUST display:

- Local version (`Versión actual: v<version>`)
- Available remote version (`Versión disponible: v<version>`)
- If a new version exists: a changelog summary fetched from the GitHub release API
- If already up to date: a message indicating the user has the latest version

**Network**: `check_update_verbose` SHALL use `--max-time 5` and `--connect-timeout 3` (more permissive than silent mode, since the user explicitly requested this).

**Error handling**: If the remote version cannot be fetched, display `[ERROR] No se pudo obtener la versión remota. Verifica tu conexión.` and return 1.

### UD-2: `nxai update` — Apply update

When the user runs `nxai update` (without flags), the system MUST apply the latest version:

- **If `.git` directory exists** at `$NEXUS_ROOT`: run `git pull --ff-only origin main`
- **If no `.git` directory**: download and pipe `install.sh` via `curl`
- On success: display `[OK] Actualización completada.` and clear the version cache
- On failure: display an error message with instructions for manual recovery

### UD-3: Error handling

The system MUST handle the following error cases:

| Scenario | Condition | Behavior |
|----------|-----------|----------|
| UD-3a: No `.git` | `.git` directory missing | Fall back to `curl install.sh` |
| UD-3b: `git pull` fails | Remote unreachable, merge conflict, or other git error | Display `[ERROR] Falló la actualización via Git.` with manual instructions |
| UD-3c: No internet | `curl` fails in update check or apply | Show `[ERROR] No se pudo obtener la versión remota.` or `[ERROR] Falló la actualización.` |
| UD-3d: Already up-to-date | Local version equals remote | `check_update_verbose` returns "Tienes la versión más reciente." |

## Scenarios

### SC-UD-1: Update available — verbose check

```
Given the local version is 0.4.0
And a newer version 0.5.0 exists remotely
When the user runs "nxai update --check"
Then it SHOULD display "Versión actual: v0.4.0"
And it SHOULD display "Versión disponible: v0.5.0"
And it SHOULD display the changelog from the GitHub release
And it SHOULD display "Actualiza con: nxai update"
```

### SC-UD-2: Apply update via git pull

```
Given $NEXUS_ROOT/.git exists
And the remote has newer commits
When the user runs "nxai update"
Then it SHOULD run "git pull --ff-only origin main"
And it SHOULD display "[OK] Actualización completada."
And it SHOULD clear the version cache
```

### SC-UD-3: Apply update via curl (no .git)

```
Given $NEXUS_ROOT/.git does NOT exist
When the user runs "nxai update"
Then it SHOULD download install.sh via curl
And pipe it to bash
And it SHOULD display "[OK] Actualización completada."
```

### SC-UD-4: Git pull failure

```
Given $NEXUS_ROOT/.git exists
And git pull fails (network error or conflict)
When the user runs "nxai update"
Then it SHOULD display "[ERROR] Falló la actualización via Git."
And it SHOULD provide manual instructions
And it MUST return exit code 1
```

### SC-UD-5: No internet during verbose check

```
Given there is no network connectivity
When the user runs "nxai update --check"
Then it SHOULD display "[ERROR] No se pudo obtener la versión remota."
And it MUST return exit code 1
```

### SC-UD-6: Already up to date

```
Given the local version is 0.5.0
And the remote version is 0.5.0
When the user runs "nxai update --check"
Then it SHOULD display "Tienes la versión más reciente."
```

## Constraints

- Verbose check SHALL use 5s timeout (not 3s as in silent mode) — the user explicitly asked for it
- Apply update SHALL prefer git pull over curl when `.git` is present
- On success, cache SHALL be cleared so the next command triggers a fresh silent check
- All user-facing messages SHALL be in Spanish
