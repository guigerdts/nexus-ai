# Delta for nexus-cli

## MODIFIED Requirements

### Requirement: Global entry point

The system MUST register a `nxai` command via a **relative** symlink at `$NEXUS_ROOT/bin/nxai` pointing to `../core/nexus.sh`. The symlink MUST be created with `ln -sf` (unconditional overwrite) in Step 8 of the installer. Subcommand routing MUST use a `case/esac` block on `$1`.

(Previously: absolute symlink was created with `[ ! -f ]` guard that skipped stale absolute symlinks. Post-archive fix: relative symlink + always `ln -sf`.)

#### Scenario: Symlink resolves to core script

- GIVEN `bin/nxai` exists as a symlink
- WHEN `readlink bin/nxai` is executed
- THEN it MUST show `../core/nexus.sh`
- AND `readlink -f bin/nxai` MUST resolve to `core/nexus.sh`
- AND the symlink MUST work correctly regardless of install directory (`--dir PATH`)

#### Scenario: Symlink recreated on re-install

- GIVEN the installer re-runs on an existing installation
- WHEN Step 8 executes
- THEN `ln -sf` MUST overwrite the existing symlink
- AND the target MUST remain the relative `../core/nexus.sh`
