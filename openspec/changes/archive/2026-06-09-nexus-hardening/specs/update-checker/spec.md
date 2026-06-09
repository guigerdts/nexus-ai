# Delta for update-checker

## MODIFIED Requirements

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
