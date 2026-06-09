# Delta for nexus-cli

## ADDED Requirements

### Requirement: Doctor command (nxai doctor)

The system MUST implement a `doctor` subcommand that runs system diagnostics and reports health status. The logic MUST live in `lib/nexus-doctor.sh` and be sourced by `core/nexus.sh`. The doctor MUST check: directory permissions, curl connectivity to GitHub, Termux bind-mount integrity, disk space, critical tool versions (python3, node, bash), and consistency between `installed.txt` and actual binary state.

The doctor MUST exit with 0 if all checks pass, 1 if warnings are found, and 2 if critical errors exist.

#### Scenario: Doctor shows healthy system

- GIVEN all directories have correct permissions
- AND curl can reach `github.com`
- AND all `installed.txt` entries have matching binaries
- WHEN `nxai doctor` is executed
- THEN the output MUST show all checks as PASS
- AND exit with code 0

#### Scenario: Doctor detects missing binary

- GIVEN an agent exists in `installed.txt`
- BUT its binary is NOT found via `command -v`
- WHEN `nxai doctor` runs
- THEN the checker MUST flag this inconsistency as a WARNING
- AND exit with code 1

#### Scenario: Doctor detects connectivity failure

- GIVEN there is no internet connectivity
- WHEN `nxai doctor` runs
- THEN the connectivity check MUST report FAIL
- AND exit with code 1 (non-blocking — other checks still run)

#### Scenario: Doctor shows disk space warning

- GIVEN available disk space is below 500MB
- WHEN `nxai doctor` runs
- THEN the disk check MUST emit a WARNING
- AND show available space in human-readable format
