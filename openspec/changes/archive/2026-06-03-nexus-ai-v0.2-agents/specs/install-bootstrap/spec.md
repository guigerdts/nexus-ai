# Delta for install-bootstrap

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
