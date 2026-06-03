# zsh-config Specification

## Purpose

Zsh shell configuration for NEXUS AI — installs and loads a curated plugin stack without modifying the user's existing `.zshrc`. Each plugin failure is handled independently.

## Requirements

### Requirement: Non-destructive install

The system MUST NOT overwrite an existing `~/.zshrc`. Configuration MUST be appended between block markers `# >>> NEXUS AI BEGIN >>>` and `# <<< NEXUS AI END <<<` for clean uninstall.

#### Scenario: Existing .zshrc present

- GIVEN the user already has a `~/.zshrc`
- WHEN the installer runs
- THEN the existing file MUST be preserved
- AND NEXUS config MUST be appended after the existing content with block markers

#### Scenario: Clean uninstall

- GIVEN the user wants to remove NEXUS AI
- WHEN they delete the lines between block markers
- THEN the original `.zshrc` MUST function as before installation
- AND no orphan NEXUS references remain

### Requirement: Plugin installation isolation

The system MUST install Zsh plugins into `$NEXUS_ROOT/shell/plugins/`, not into `~/.oh-my-zsh` or system paths.

#### Scenario: Plugin install

- GIVEN the installer runs
- WHEN it clones `zsh-autosuggestions`
- THEN the clone target MUST be `$NEXUS_ROOT/shell/plugins/zsh-autosuggestions`

### Requirement: Required plugin stack

The system MUST attempt to install and load: `zsh-autosuggestions`, `zsh-syntax-highlighting`, `zsh-vi-mode`, `fzf` + `fzf-tab`, `zoxide`, `atuin`, `thefuck`, and `starship`.

#### Scenario: All plugins install successfully

- GIVEN network connectivity and compatible system
- WHEN the installer processes the plugin list
- THEN all 8 plugins MUST be installed and loadable from `$NEXUS_ROOT/shell/plugins/`

### Requirement: Graceful failure on plugin errors

If a plugin fails to clone or install, the system MUST emit a warning and continue to the next plugin. One failure MUST NOT abort the entire installation.

#### Scenario: Single plugin clone fails

- GIVEN a plugin's git repository is unreachable
- WHEN the installer attempts to clone it
- THEN a warning MUST be shown with the plugin name
- AND the installer MUST continue with the remaining plugins

### Requirement: PATH setup

The system MUST prepend `$NEXUS_ROOT/bin` to `PATH` in the shell config.

#### Scenario: PATH contains NEXUS bin

- GIVEN the `.zshrc` has been loaded
- WHEN inspecting `$PATH`
- THEN `$NEXUS_ROOT/bin` MUST appear in `$PATH`
