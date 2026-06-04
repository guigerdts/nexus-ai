# Spec: update-checker

**Domain**: update-checker
**Change**: v0.5-update-system
**Version**: 1.0.0
**Status**: Final

## Overview

Silent background version checker that checks for new Nexus AI releases after every command. Non-blocking, cached, with graceful failure.

## Requirements

### UC-1: Silent check after banner

The system MUST run `check_update_silent` immediately after every `show_banner` call, for every command.

- **Rationale**: Users get timely update notifications without any user action.
- **Command scope**: `install`, `remove`, `list`, `status`, `agent`, `memory`, `update`, and unknown commands (`*`).

### UC-2: Version comparison

The system SHALL compare local vs remote versions using semver comparison.

- Versions SHALL be compared as `major.minor.patch` triplets.
- The `v` prefix SHALL be stripped before comparison.
- Empty or invalid versions SHALL be handled gracefully (return error code `2`).
- **Function**: `_nexus_version_compare <local> <remote>`
- **Returns**: `0` if equal, `1` if local < remote, `2` on error.

### UC-3: Cache

The system MUST cache the remote version check result to avoid repeated network requests.

- **Cache file**: `${TMPDIR:-/tmp}/nexus-version-check`
- **Cache format**: `<timestamp> <version>` (space-separated)
- **TTL**: 86400 seconds (24 hours)
- If the cache is valid (within TTL), the system MUST NOT make a network request.
- If the cache is expired or absent, the system SHALL fetch the remote version.
- **Functions**: `_nexus_update_cache_read`, `_nexus_update_cache_write`

### UC-4: Timeout

The system MUST time out network requests after 3 seconds (`--max-time 3` with `--connect-timeout 2`).

- A timeout MUST NOT produce an error visible to the user.
- On timeout, the check SHALL silently abort and wait for the next command.

### UC-5: Logging

The system SHOULD log each check to `$NEXUS_ROOT/logs/update-check.log`.

- **Log format**: `[YYYY-MM-DD HH:MM:SS] check: local=<version> remote=<version> cmp=<result>`
- If the log directory cannot be created or written, the error SHALL be silently ignored.

### UC-6: Display discreet notification

When a new version is found, the system MUST display a discreet single-line notice.

- **Format**: `[!] Nueva versión disponible: v<remote_version>`
- The notice MUST appear inline, not as a blocking dialog.
- If there is no internet or the check fails, no notice SHALL be shown.

## Scenarios

### SC-UC-1: New version available

```
Given the local version is 0.4.0
And the remote version is 0.5.0
When check_update_silent runs
Then it should display "[!] Nueva versión disponible: v0.5.0"
```

### SC-UC-2: Already up to date

```
Given the local version is 0.5.0
And the remote version is 0.5.0
When check_update_silent runs
Then it should NOT show any update notice
```

### SC-UC-3: Cache hit (within TTL)

```
Given the cache file has a valid timestamp within 86400s
And the cached version is 0.5.0
When check_update_silent runs
Then it should NOT make a network request
And it should compare the cached version
```

### SC-UC-4: Cache expired

```
Given the cache file has a timestamp older than 86400s
When check_update_silent runs
Then it SHOULD make a network request
And update the cache with the new version
```

### SC-UC-5: Network timeout

```
Given there is no network connectivity
When check_update_silent runs
Then it MUST not block or hang
And it MUST NOT display any error to the user
And it SHOULD abort silently
```

### SC-UC-6: Invalid remote version

```
Given the remote server returns an empty or non-semver response
When check_update_silent runs
Then it MUST handle the error silently
And it MUST NOT display any notice
```

### SC-UC-7: Version comparison — equal versions

```
Given local version is 0.5.0
And remote version is 0.5.0
When _nexus_version_compare is called
Then it MUST return 0
```

### SC-UC-8: Version comparison — local older

```
Given local version is 0.4.0
And remote version is 0.5.0
When _nexus_version_compare is called
Then it MUST return 1
```

### SC-UC-9: Cache corruption

```
Given the cache file contains garbage (non-numeric timestamp)
When _nexus_update_cache_read runs
Then it MUST return empty string
And the system SHALL fetch the remote version
```

### SC-UC-10: Logging on check

```
Given check_update_silent completes
When it has fetched a remote version
Then the log entry SHOULD be written to logs/update-check.log
With the format [YYYY-MM-DD HH:MM:SS] check: local=0.5.0 remote=0.5.0 cmp=0
```

## Constraints

- MUST NOT block the CLI — always non-blocking
- MUST NOT expose network errors to the user in silent mode
- Cache TTL SHALL be 24 hours (configurable via `_nexus_update_cache_ttl`)
- Network timeout SHALL be 3 seconds for silent checks
