# Delta for install-bootstrap

## MODIFIED Requirements

### Requirement: Gum installation step

The installer MUST optionally install Gum v0.17.0+ in Step 9. In Termux it MUST use `pkg install gum`. In proot-Ubuntu/linux it MUST use `mktemp -d` for safe temporary extraction and copy the binary to `$NEXUS_ROOT/bin/`. The temp directory MUST be cleaned up after extraction.
(Previously: used hardcoded `/tmp/gum.tar.gz` and glob `/tmp/gum_*/` — unsafe for concurrent processes)

#### Scenario: Gum install on proot-Ubuntu uses mktemp (replaces old)

- GIVEN the environment is proot-ubuntu and gum is not installed
- WHEN Step 9 executes
- THEN `mktemp -d` MUST create an isolated temp directory
- AND the tarball MUST download to that directory (NOT to `/tmp/gum.tar.gz`)
- AND the binary MUST be placed in `$NEXUS_ROOT/bin/`
- AND the temp directory MUST be removed after copying

#### Scenario: Concurrent installs do not collide

- GIVEN two install.sh processes run simultaneously
- WHEN both download and extract gum
- THEN each MUST use a different `mktemp` directory
- AND NOT overwrite each other's temp files
- AND `rm -rf /tmp/gum_*` MUST NOT be used (unsafe glob)

#### Scenario: Gum already installed (unchanged)

- GIVEN `command -v gum` succeeds before Step 9
- WHEN Step 9 executes
- THEN the step MUST be skipped silently
- AND no download or package install MUST occur
