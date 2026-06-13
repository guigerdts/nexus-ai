# Delta for update-checker

## ADDED Requirements

### Requirement: Update marker file

When a new version is detected, the system MUST write the version string to a marker file at `$NEXUS_ROOT/logs/update-available.txt`. The marker SHALL contain only the version string (e.g., `v0.5.0`) without timestamp or formatting. When local version is up to date, the marker file MUST be removed if it exists.

#### Scenario: Marker written on new version

- GIVEN local version is 0.4.0 and remote is 0.5.0
- WHEN `check_update_silent` detects a newer version
- THEN `$NEXUS_ROOT/logs/update-available.txt` MUST contain `v0.5.0`

#### Scenario: Marker removed on up-to-date

- GIVEN the marker file exists from a previous check
- AND local version is now up to date
- WHEN `check_update_silent` runs
- THEN the marker file MUST be deleted

#### Scenario: No network, marker preserved

- GIVEN the marker file exists with v0.5.0
- AND there is no network connectivity
- WHEN `check_update_silent` runs and fails silently
- THEN the existing marker file MUST NOT be modified

### Requirement: Marker read function

The system MUST provide `nexus_update_marker_read()` that reads `logs/update-available.txt` and prints its content. If the marker does not exist, it SHALL print nothing and return exit code 1.

#### Scenario: Marker exists

- GIVEN `logs/update-available.txt` contains `v0.5.0`
- WHEN `nexus_update_marker_read` runs
- THEN stdout MUST contain `v0.5.0`
- AND return exit code 0

#### Scenario: Marker absent

- GIVEN `logs/update-available.txt` does not exist
- WHEN `nexus_update_marker_read` runs
- THEN stdout MUST be empty
- AND return exit code 1

## MODIFIED Requirements

### Requirement: Display update notification

When a new version is found, the system MUST display a discreet single-line notice AND persist the version to the marker file.

- **Format**: `[!] Nueva versión disponible: v<remote_version>`
- The notice MUST appear inline, not as a blocking dialog.
- If there is no internet or the check fails, no notice SHALL be shown.
- On new version detection, the system MUST write `v<remote_version>` to `logs/update-available.txt`.
- On up-to-date detection, the system MUST remove `logs/update-available.txt` if it exists.
(Previously: only displayed inline notice, no marker file)

#### Scenario: New version available — notice and marker

- GIVEN the local version is 0.4.0
- AND the remote version is 0.5.0
- WHEN `check_update_silent` runs
- THEN it should display `[!] Nueva versión disponible: v0.5.0`
- AND write `v0.5.0` to `logs/update-available.txt`

#### Scenario: Already up to date — no notice, marker removed

- GIVEN the local version is 0.5.0
- AND the remote version is 0.5.0
- AND `logs/update-available.txt` exists from a previous check
- WHEN `check_update_silent` runs
- THEN it should NOT show any update notice
- AND remove `logs/update-available.txt`

#### Scenario: Invalid remote version

- GIVEN the remote server returns an empty or non-semver response
- WHEN `check_update_silent` runs
- THEN it MUST handle the error silently
- AND it MUST NOT display any notice
- AND it MUST NOT write a marker file
