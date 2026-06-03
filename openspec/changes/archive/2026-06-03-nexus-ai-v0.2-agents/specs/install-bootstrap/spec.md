# Delta for install-bootstrap

## ADDED Requirements

### Requirement: Remote install detection

The installer MUST detect when it is being run remotely (via `curl ... | bash`, `bash <(curl ...)`, or `source /dev/stdin`) and auto-clone the repository to a local directory before proceeding with the normal local installation. Detection MUST happen BEFORE `set -u` is enabled to avoid unbound-variable errors from `${BASH_SOURCE[0]}`.

#### Scenario: Pipe mode — curl | bash -s

- GIVEN the user runs `curl -fsSL https://raw.githubusercontent.com/guigerdts/nexus-ai/main/install.sh | bash -s -- [opts]`
- WHEN the script starts
- THEN `${BASH_SOURCE[0]:-}` MUST be empty/unset
- AND the script MUST detect this as remote mode
- AND it MUST clone the repository to the target directory
- AND it MUST re-execute via `exec bash install.sh "$@"` from the cloned directory

#### Scenario: Process substitution — bash <(curl ...)

- GIVEN the user runs `bash <(curl -fsSL https://raw.githubusercontent.com/guigerdts/nexus-ai/main/install.sh)`
- WHEN the script starts
- THEN `${BASH_SOURCE[0]}` MUST match `/dev/fd/*`
- AND the script MUST detect this as remote mode
- AND it MUST clone the repository to the target directory
- AND it MUST re-execute via `exec bash install.sh "$@"` from the cloned directory

#### Scenario: Source from stdin

- GIVEN the user runs `source /dev/stdin` after piping the script
- WHEN the script starts
- THEN `${BASH_SOURCE[0]}` MUST equal `/dev/stdin`
- AND the script MUST detect this as remote mode
- AND it MUST clone the repository to the target directory
- AND it MUST re-execute via `exec bash install.sh "$@"` from the cloned directory

#### Scenario: Remote install with custom directory

- GIVEN the user runs `curl ... | bash -s -- --dir ~/custom-dir`
- WHEN remote mode is detected
- THEN the `--dir` flag MUST be parsed before cloning
- AND the repository MUST be cloned to the specified custom directory
- AND re-execution MUST use the custom directory

#### Scenario: Remote install with --help

- GIVEN the user runs `curl ... | bash -s -- --help`
- WHEN remote mode is detected
- THEN the script MUST print a remote-specific help message
- AND exit WITHOUT cloning the repository

#### Scenario: Remote clone is idempotent

- GIVEN the target directory already has a `.git` directory (from a previous remote install)
- WHEN remote mode is detected
- THEN the script MUST run `git pull --ff-only` instead of cloning fresh
- AND re-execute from the existing directory

### Requirement: Relative symlink for CLI entry point

Step 8 MUST create the CLI symlink as a relative path (`../core/nexus.sh`) using `ln -sf` unconditionally, to support custom install directories via `--dir`. Previously used absolute symlink + `[ ! -f ]` guard.

#### Scenario: Symlink is always relative

- GIVEN Step 8 runs
- WHEN the symlink is created
- THEN `bin/nxai` MUST point to `../core/nexus.sh` (relative, not absolute)
- AND `ln -sf` MUST be used (no `[ ! -f ]` guard that could skip a stale absolute symlink)

#### Scenario: Symlink is recreated on re-run

- GIVEN the installer is run a second time
- WHEN Step 8 executes
- THEN `ln -sf` MUST overwrite any existing symlink at `bin/nxai`
- AND the target MUST remain `../core/nexus.sh`

## MODIFIED Requirements

### Requirement: Progress display

The installer MUST show numbered steps with visible progress: `[1/8] Verificando entorno...`, `[2/8] Instalando dependencias...`, etc.
(Previously: steps displayed as [1/7] through [7/7]; Step 8 added for CLI and registry bootstrap)

#### Scenario: Normal installation with 8 steps

- GIVEN the installer is running
- WHEN it proceeds through each step
- THEN each step MUST display its number, total count of 8, and description
- AND failed steps MUST be clearly marked

### Requirement: Post-install actions

After successful completion, the installer MUST install the CLI skeleton (`core/nexus.sh` + `bin/nexus` symlink), create the registry foundation (`config/agents.registry.sh` + empty `modules/` directory), display the MOTD with real command tips (e.g., `nexus help`, `nexus status`, `nexus install --all`), show a welcome message in Spanish, and print instructions to apply changes.
(Previously: no CLI or registry bootstrap; MOTD displayed forward-looking tips with "(proximamente)" placeholders)

#### Scenario: Step 8 creates CLI skeleton

- GIVEN the installer completes steps 1-7 successfully
- WHEN Step 8 runs
- THEN `core/nexus.sh` MUST be created
- AND `bin/nexus` symlink MUST point to `../core/nexus.sh`
- AND `config/agents.registry.sh` MUST be created with empty agent array
- AND `modules/` directory MUST exist

#### Scenario: MOTD shows real commands

- GIVEN Step 8 completes and the MOTD is displayed
- WHEN the user inspects MOTD tips
- THEN tips MUST reference actual working commands
- AND MUST NOT contain "(proximamente)" or forward-looking placeholders

#### Scenario: MOTD tips include agent management

- GIVEN the MOTD displays after a fresh install
- WHEN checking the tips section
- THEN at least one tip MUST mention `nexus list` or `nexus install --all`
- AND tips MUST be in Spanish
