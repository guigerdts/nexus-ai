# install-bootstrap Specification

## Purpose

Single-entry installer for NEXUS AI — detects the runtime environment, installs dependencies, configures the shell, and presents the welcome screen. Designed to work in Termux native, proot-distro Ubuntu, or standard Linux.

## Requirements

### Requirement: Environment detection before action

The installer MUST detect the environment before performing any modifications. Detection MUST classify as `"termux"` (via `$PREFIX`), `"proot-ubuntu"` (via proot markers), or `"linux"` (otherwise), and select the appropriate package manager (`pkg` for Termux, `apt` otherwise).

#### Scenario: Termux native detection

- GIVEN the script runs in Termux where `$PREFIX` is set
- WHEN the installer checks the environment
- THEN it MUST use `pkg` for package management
- AND NOT use `apt`

#### Scenario: Unsupported environment

- GIVEN the script runs on an environment that is neither Termux nor Ubuntu/Debian
- WHEN the installer checks the environment
- THEN it MUST emit a warning about the unsupported OS
- AND attempt to continue with `apt`

### Requirement: Progress display

The installer MUST show numbered steps with visible progress: `[1/8] Verificando entorno...`, `[2/8] Instalando dependencias...`, etc.

#### Scenario: Normal installation with 8 steps

- GIVEN the installer is running
- WHEN it proceeds through each step
- THEN each step MUST display its number, total count of 8, and description
- AND failed steps MUST be clearly marked

### Requirement: Supported CLI flags

The installer MUST support `--help` (show usage), `--no-zsh` (skip ZSH configuration), `--no-starship` (use vcs_info fallback directly), `--no-motd` (skip welcome screen), and `--dir PATH` (custom install directory).

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

#### Scenario: Skip all optional features

- GIVEN the user runs `install.sh --no-zsh --no-starship --no-motd`
- WHEN the installer runs
- THEN it MUST NOT configure Zsh
- AND it MUST NOT install Starship (fallback directly to vcs_info)
- AND it MUST NOT display the welcome screen

### Requirement: Post-install actions

After successful completion, the installer MUST install the CLI skeleton (`core/nexus.sh` + `bin/nexus` symlink), create the registry foundation (`config/agents.registry.sh` + empty `modules/` directory), display the MOTD with real command tips (e.g., `nexus help`, `nexus status`, `nexus install --all`), show a welcome message in Spanish, and print instructions to apply changes.

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
