# proot-management Specification

## Purpose

Proot-distro lifecycle management: detect, list, ensure installed, run commands, and create wrapper scripts for common distributions inside Termux environment.

## Requirements

### Requirement: Proot detection

`nexus_proot_detect` MUST check whether `proot-distro` is installed. If present, it MUST also detect the currently active proot session by inspecting `/proc/self/status` for proot-related namespaces or environment variables.

#### Scenario: Proot-distro installed

- GIVEN `proot-distro` is in PATH
- WHEN `nexus_proot_detect` runs
- THEN it MUST return exit code 0
- AND set `NEXUS_PROOT_AVAILABLE=true`

#### Scenario: Proot-distro missing

- GIVEN `proot-distro` is NOT in PATH
- WHEN `nexus_proot_detect` runs
- THEN it MUST return exit code 1
- AND set `NEXUS_PROOT_AVAILABLE=false`

### Requirement: List installed distros

`nexus_proot_list` MUST list proot-distro installations by invoking `proot-distro list`. Output SHALL be formatted using `ui_table` when available, plain text otherwise.

#### Scenario: Distros listed

- GIVEN proot-distro has 2 installed distributions
- WHEN `nexus_proot_list` runs
- THEN it MUST display each distro name and status
- AND use `ui_table` for formatting if loaded

### Requirement: Distro ensure lifecycle

`nexus_proot_ensure <distro>` MUST install the named distribution if not already present. If already installed, it SHALL be a no-op.

#### Scenario: Install missing distro

- GIVEN Ubuntu is not installed via proot-distro
- WHEN `nexus_proot_ensure ubuntu` runs
- THEN `proot-distro install ubuntu` MUST be invoked
- AND the function MUST wait for completion

#### Scenario: Distro already installed

- GIVEN Ubuntu is already installed
- WHEN `nexus_proot_ensure ubuntu` runs
- THEN no installation SHALL occur
- AND the function MUST return immediately with success

### Requirement: Run and wrapper

`nexus_proot_run <distro> <command>` MUST execute a command inside the proot-distro environment. `nexus_proot_wrapper <distro> <name>` MUST create a shell script in `$NEXUS_ROOT/bin/` that proxies `proot-distro login <distro>`.

#### Scenario: Run command inside proot

- GIVEN Ubuntu distro is installed
- WHEN `nexus_proot_run ubuntu "echo ok"` runs
- THEN `proot-distro login ubuntu -- echo ok` MUST execute
- AND output MUST show "ok"

#### Scenario: Wrapper script creation

- GIVEN `nexus_proot_wrapper ubuntu mycmd` runs
- THEN a file `$NEXUS_ROOT/bin/mycmd` MUST be created
- AND it MUST be executable
- AND running `mycmd` SHALL proxy into `proot-distro login ubuntu` with forwarded arguments
