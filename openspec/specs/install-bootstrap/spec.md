# install-bootstrap Specification

## Purpose

Single-entry installer for NEXUS AI — detects the runtime environment, supports remote execution (via `curl | bash`, `bash <(curl ...)`, or `source /dev/stdin`), installs dependencies, configures the shell, and presents the welcome screen. Designed to work in Termux native, proot-distro Ubuntu, or standard Linux.

## Requirements

### Requirement: Remote install detection

The installer MUST detect when it is being run remotely (via `curl ... | bash`, `bash <(curl ...)`, or `source /dev/stdin`) and auto-clone the repository to a local directory before proceeding with normal local installation. Detection MUST happen BEFORE `set -u` is enabled to avoid unbound-variable errors from `${BASH_SOURCE[0]}`.

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

### Requirement: Environment detection before action

The installer MUST detect the environment before performing any modifications. Detection MUST classify as `"termux"` (via `$PREFIX`), `"proot-ubuntu"` (via proot markers), or `"linux"` (otherwise), and select the appropriate package manager (`pkg` for Termux, `apt` otherwise). When generating shell configs, the hardcoded PATH block MUST include Termux bind-mount directories when `/data/data/com.termux/files/usr/bin` exists at install time.

#### Scenario: Termux native detection

- GIVEN the script runs in Termux where `$PREFIX` is set
- WHEN the installer checks the environment
- THEN it MUST use `pkg` for package management
- AND NOT use `apt`

#### Scenario: Install in proot + bind-mounts

- GIVEN the script runs in proot-Ubuntu with `/data/data/com.termux/files/usr/bin` present
- WHEN the installer generates shell configs
- THEN `/data/data/com.termux/files/usr/bin` and `/data/data/com.termux/files/usr/local/bin` MUST be prepended to the hardcoded PATH
- AND each entry SHALL be guarded by `[ -d "$dir" ]`

#### Scenario: Install in proot no bind-mounts

- GIVEN `/data/data/com.termux/files/usr/bin` does NOT exist at install time
- WHEN the installer generates shell configs
- THEN no Termux PATH entries MUST be written

#### Scenario: Unsupported environment

- GIVEN the script runs on an environment that is neither Termux nor Ubuntu/Debian
- WHEN the installer checks the environment
- THEN it MUST emit a warning about the unsupported OS
- AND attempt to continue with `apt`

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
- THEN `SKIP_GUM` MUST be set to `true`
- AND Step 9 MUST be skipped without error

### Requirement: Progress display

The installer MUST show numbered steps with visible progress: `[1/9] Verificando entorno...`, `[2/9] Instalando dependencias...`, etc. Step 8 "Configurando CLI NEXUS AI" MUST remain as the final configuration step. Step 9 "Instalando Gum..." MUST be the last step before completion.

#### Scenario: Normal installation with 9 steps

- GIVEN the installer is running with gum installation enabled
- WHEN it proceeds through each step
- THEN each step MUST display its number, total count of 9, and description
- AND failed steps MUST be clearly marked
- AND Step 9 MUST be "Instalando Gum..."

### Requirement: Supported CLI flags

The installer MUST support `--help` (show usage), `--no-zsh` (skip ZSH configuration), `--no-bashrc` (skip Bash config), `--no-starship` (use vcs_info fallback), `--no-motd` (skip welcome screen), `--no-gum` (skip gum installation), and `--dir PATH` (custom install directory).

#### Scenario: Help flag

- GIVEN the user runs `install.sh --help`
- WHEN the script processes arguments
- THEN it MUST print usage information
- AND exit without making any changes

#### Scenario: Custom install directory

- GIVEN the user runs `install.sh --dir /data/data/com.termux/files/home/nexus`
- WHEN the installer runs
- THEN `NEXUS_ROOT` MUST be set to the specified path
- AND the project MUST be cloned or copied there

#### Scenario: --no-gum accepted as valid flag

- GIVEN the user runs `install.sh --no-gum`
- WHEN the flag parser processes arguments
- THEN it MUST NOT produce an error for unknown flag
- AND `SKIP_GUM` MUST be set to `true`
- AND gum installation MUST be skipped

#### Scenario: Combined flags with --no-gum

- GIVEN the user runs `install.sh --no-zsh --no-gum --no-motd`
- WHEN the installer runs
- THEN Zsh config MUST be skipped
- AND gum install MUST be skipped
- AND MOTD MUST be skipped
- AND no error MUST occur

#### Scenario: Skip all optional features

- GIVEN the user runs `install.sh --no-zsh --no-starship --no-motd`
- WHEN the installer runs
- THEN it MUST NOT configure Zsh
- AND it MUST NOT install Starship (fallback directly to vcs_info)
- AND it MUST NOT display the welcome screen

### Requirement: Post-install actions

After successful completion, the installer MUST install the CLI skeleton (`core/nexus.sh` + `bin/nxai` relative symlink pointing to `../core/nexus.sh`), create the registry foundation (`config/agents.registry.sh` + empty `modules/` directory), display the MOTD with real command tips (e.g., `nxai help`, `nxai status`, `nxai install --all`), show a welcome message in Spanish, and print instructions to apply changes.

#### Scenario: Step 8 creates CLI skeleton

- GIVEN the installer completes steps 1-7 successfully
- WHEN Step 8 runs
- THEN `core/nexus.sh` MUST be present (created via git clone or project copy)
- AND `bin/nxai` symlink MUST point to `../core/nexus.sh` (relative path, created with `ln -sf`)
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
- THEN at least one tip MUST mention `nxai list` or `nxai install --all`
- AND tips MUST be in Spanish
