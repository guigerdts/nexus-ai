# update-checker Specification

## Purpose

Silent background version checker that checks for new Nexus AI releases after every command. Non-blocking, cached, with graceful failure.

## Requirements

### Requirement: Silent update check

The system MUST run `check_update_silent` after every `show_banner` call. The check MUST be asynchronous: spawn a background process with `&`, use a lockfile (`$TMPDIR/nexus-update.lock`) to prevent concurrent checks, and read cached result if the check is still running.
(Previously: synchronous curl fetch adding ~300ms latency per command)

#### Scenario: Background check does not block CLI

- GIVEN the user runs `nxai list`
- WHEN `check_update_silent` is called
- THEN the curl fetch MUST execute in background (`&`)
- AND the command output MUST appear immediately
- AND NOT wait for the network request

#### Scenario: Lockfile prevents concurrent checks

- GIVEN a background check is already running
- WHEN another command triggers `check_update_silent`
- THEN the lockfile check MUST skip the new request
- AND read the existing cache instead

#### Scenario: Cache available while check runs

- GIVEN a background check is running (lockfile present)
- AND a previous cache exists (even if stale)
- WHEN the update notification would be displayed
- THEN the system MUST use the cached result
- AND NOT wait for the background process to finish

### Requirement: Version comparison

The system SHALL compare local vs remote versions using semver comparison.

- Versions SHALL be compared as `major.minor.patch` triplets.
- The `v` prefix SHALL be stripped before comparison.
- Empty or invalid versions SHALL be handled gracefully (return error code `2`).
- **Function**: `_nexus_version_compare <local> <remote>`
- **Returns**: `0` if equal, `1` if local < remote, `2` on error.

#### Scenario: Version comparison — equal versions

- GIVEN local version is 0.5.0
- AND remote version is 0.5.0
- WHEN `_nexus_version_compare` is called
- THEN it MUST return 0

#### Scenario: Version comparison — local older

- GIVEN local version is 0.4.0
- AND remote version is 0.5.0
- WHEN `_nexus_version_compare` is called
- THEN it MUST return 1

### Requirement: Update cache

The system MUST cache the remote version check result to avoid repeated network requests.

- **Cache file**: `${TMPDIR:-/tmp}/nexus-version-check`
- **Cache format**: `<timestamp> <version>` (space-separated)
- **TTL**: 86400 seconds (24 hours)
- If the cache is valid (within TTL), the system MUST NOT make a network request.
- If the cache is expired or absent, the system SHALL fetch the remote version.
- **Functions**: `_nexus_update_cache_read`, `_nexus_update_cache_write`

#### Scenario: Cache hit (within TTL)

- GIVEN the cache file has a valid timestamp within 86400s
- AND the cached version is 0.5.0
- WHEN `check_update_silent` runs
- THEN it MUST NOT make a network request
- AND it should compare the cached version

#### Scenario: Cache expired

- GIVEN the cache file has a timestamp older than 86400s
- WHEN `check_update_silent` runs
- THEN it SHOULD make a network request
- AND update the cache with the new version

#### Scenario: Cache corruption

- GIVEN the cache file contains garbage (non-numeric timestamp)
- WHEN `_nexus_update_cache_read` runs
- THEN it MUST return empty string
- AND the system SHALL fetch the remote version

### Requirement: Network timeout

The system MUST time out network requests after 3 seconds (`--max-time 3` with `--connect-timeout 2`).

- A timeout MUST NOT produce an error visible to the user.
- On timeout, the check SHALL silently abort and wait for the next command.

#### Scenario: Network timeout

- GIVEN there is no network connectivity
- WHEN `check_update_silent` runs
- THEN it MUST not block or hang
- AND it MUST NOT display any error to the user
- AND it SHOULD abort silently

### Requirement: Update logging

The system SHOULD log each check to `$NEXUS_ROOT/logs/update-check.log`.

- **Log format**: `[YYYY-MM-DD HH:MM:SS] check: local=<version> remote=<version> cmp=<result>`
- If the log directory cannot be created or written, the error SHALL be silently ignored.

#### Scenario: Logging on check

- GIVEN `check_update_silent` completes
- WHEN it has fetched a remote version
- THEN the log entry SHOULD be written to `logs/update-check.log`
- WITH the format `[YYYY-MM-DD HH:MM:SS] check: local=0.5.0 remote=0.5.0 cmp=0`

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

### Requirement: Verbose check with GitHub API

When `check_update_verbose` runs, the system MUST parse the GitHub release JSON. It SHOULD use `jq` when available, fall back to `python3 -c "import sys,json; ..."`, and use `grep`/`cut` only as last resort. Single-line body in JSON MUST NOT break parsing.
(Previously: only `grep '"body"' | head -1 | cut -d'"' -f4` — fragile with multiline or escaped quotes)

#### Scenario: jq available parses release body

- GIVEN `jq` is installed
- WHEN `check_update_verbose` fetches the release API
- THEN the body MUST be extracted via `jq -r '.body'`
- AND NOT use grep/cut parsing

#### Scenario: Python fallback parses body

- GIVEN `jq` is NOT available but `python3` is
- WHEN `check_update_verbose` fetches the release API
- THEN the body MUST be extracted via `python3 -c "import sys,json; json.load(sys.stdin)['body']"`
- AND multiline body content MUST NOT break parsing

#### Scenario: No parser available (last resort grep)

- GIVEN neither `jq` nor `python3` are available
- WHEN `check_update_verbose` runs
- THEN the system MAY use grep/cut as last resort
- AND SHOULD NOT crash on multiline body

## Constraints

- MUST NOT block the CLI — always non-blocking
- MUST NOT expose network errors to the user in silent mode
- Cache TTL SHALL be 24 hours (configurable via `_nexus_update_cache_ttl`)
- Network timeout SHALL be 3 seconds for silent checks
