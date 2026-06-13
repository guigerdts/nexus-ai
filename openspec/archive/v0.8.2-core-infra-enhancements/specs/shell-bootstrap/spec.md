# Delta for shell-bootstrap

## ADDED Requirements

### Requirement: Starship update indicator module

The system SHOULD include an optional custom module in `shell/starship.toml` that shows an update indicator in the shell prompt. The module SHALL check for the existence of `$NEXUS_ROOT/logs/update-available.txt`. If the marker exists, the prompt SHALL display `⬆` (or a text equivalent if ASCII-only mode is preferred) in a configurable format and color. The module MUST be commented out by default and MAY be enabled by the user.

#### Scenario: Marker exists, module enabled

- GIVEN `logs/update-available.txt` contains `v0.5.0`
- AND the Starship module is enabled (uncommented)
- WHEN the Starship prompt renders
- THEN the prompt MUST show the update indicator
- AND the indicator MUST be styled per the module configuration

#### Scenario: Marker absent, module enabled

- GIVEN `logs/update-available.txt` does NOT exist
- AND the Starship module is enabled
- WHEN the Starship prompt renders
- THEN the indicator MUST NOT appear
- AND the prompt SHALL render normally

#### Scenario: Module commented out (default)

- GIVEN the module is commented out in `starship.toml`
- WHEN the Starship prompt renders
- THEN no update indicator SHALL appear
- AND the module configuration SHALL NOT be loaded
