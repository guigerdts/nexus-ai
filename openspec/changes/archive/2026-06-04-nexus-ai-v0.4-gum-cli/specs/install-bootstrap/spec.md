# Delta for install-bootstrap

## ADDED Requirements

### Requirement: Gum installation step

The installer MUST optionally install Gum v0.17.0+ in a new Step 9. In Termux (`NEXUS_ENV=termux`) it MUST use `pkg install gum`. In proot-Ubuntu/linux (`NEXUS_ENV=proot-ubuntu` or `linux`) it MUST download `gum_linux_arm64.tar.gz` from the Charm.sh GitHub releases to `$NEXUS_ROOT/bin/` and extract the binary. If gum is already installed (`command -v gum` succeeds), the step MUST be skipped silently.

#### Scenario: Gum install on Termux

- GIVEN the environment is Termux
- WHEN Step 9 executes and gum is not installed
- THEN `pkg install gum` MUST run
- AND the installation MUST complete without error

#### Scenario: Gum install on proot-Ubuntu

- GIVEN the environment is proot-ubuntu and gum is not installed
- WHEN Step 9 executes
- THEN the GitHub tarball `gum_linux_arm64.tar.gz` MUST download
- AND the gum binary MUST be placed in `$NEXUS_ROOT/bin/`

#### Scenario: Gum already installed

- GIVEN `command -v gum` succeeds before Step 9
- WHEN Step 9 executes
- THEN the step MUST be skipped silently
- AND no download or package install MUST occur

### Requirement: --no-gum flag

The installer MUST support `--no-gum` to explicitly skip gum installation. When this flag is set, Step 9 MUST be skipped entirely without attempting any gum download or install.

#### Scenario: --no-gum skips gum install

- GIVEN the user runs `install.sh --no-gum`
- WHEN the installer processes flags
- THEN `INSTALL_GUM` MUST be set to `false`
- AND Step 9 MUST be skipped without error

## MODIFIED Requirements

### Requirement: Progress display

The installer MUST show numbered steps with visible progress: `[1/9] Verificando entorno...`, `[2/9] Instalando dependencias...`, etc. Step 8 "Configurando CLI NEXUS AI" MUST remain as the final configuration step. Step 9 "Instalando Gum..." MUST be the last step before completion.
(Previously: 8 steps, Step 8 was final)

#### Scenario: Normal installation with 9 steps

- GIVEN the installer is running with gum installation enabled
- WHEN it proceeds through each step
- THEN each step MUST display its number, total count of 9, and description
- AND failed steps MUST be clearly marked
- AND Step 9 MUST be "Instalando Gum..."

#### Scenario: 8 steps when --no-gum is set

- GIVEN the installer runs with `--no-gum`
- WHEN it proceeds through each step
- THEN the step counter MUST still show 9 total with Step 9 skipped
- OR the total count MUST reflect the actual number of executed steps
- (Implementation choice: consistent 9-step count with skip, or dynamic)

### Requirement: Supported CLI flags

The installer MUST support `--help` (show usage), `--no-zsh` (skip ZSH configuration), `--no-bashrc` (skip Bash config), `--no-starship` (use vcs_info fallback), `--no-motd` (skip welcome screen), `--no-gum` (skip gum installation), and `--dir PATH` (custom install directory).
(Previously: no --no-gum flag)

#### Scenario: --no-gum accepted as valid flag

- GIVEN the user runs `install.sh --no-gum`
- WHEN the flag parser processes arguments
- THEN it MUST NOT produce an error for unknown flag
- AND gum installation MUST be skipped

#### Scenario: Combined flags with --no-gum

- GIVEN the user runs `install.sh --no-zsh --no-gum --no-motd`
- WHEN the installer runs
- THEN Zsh config MUST be skipped
- AND gum install MUST be skipped
- AND MOTD MUST be skipped
- AND no error MUST occur
