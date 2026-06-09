# nexus-log Specification

## Purpose

Logging library at `lib/nexus-log.sh` providing color-formatted output functions. Supports plain-text (default) and JSON-structured output for TUI consumption.

## Requirements

### Requirement: Level-based log functions

The library MUST provide `log_ok`, `log_warn`, `log_error`, and `log_info` functions. Each MUST emit a level prefix: `[OK]`, `[WARN]`, `[ERROR]`, `[INFO]`. In text mode, ANSI color codes MUST only emit when output is a TTY (`[ -t 1 ]`).

#### Scenario: Text mode on TTY shows colors (unchanged)

- GIVEN output is a terminal
- WHEN `log_ok "ready"` is called
- THEN output MUST include ANSI cyan `[OK]`
- AND the message `ready`

#### Scenario: Text mode in pipe strips colors (unchanged)

- GIVEN output is piped (not a TTY)
- WHEN `log_ok "ready"` is called
- THEN output MUST be plain `[OK] ready`
- AND NOT contain ANSI escape sequences

### Requirement: JSON log format

When `NEXUS_LOG_FORMAT=json`, each log function MUST emit a JSON object with `timestamp`, `level`, and `message` fields. The `timestamp` MUST be ISO 8601. This MUST NOT change the function's exit code or side effects.

#### Scenario: JSON format emits structured output

- GIVEN `NEXUS_LOG_FORMAT=json`
- WHEN `log_ok "ready"` is called
- THEN output MUST be `{"timestamp":"2026-06-09T...","level":"OK","message":"ready"}`
- AND the JSON MUST be valid per `python3 -c "import sys,json; json.load(sys.stdin)"`

#### Scenario: JSON format in pipe works

- GIVEN `NEXUS_LOG_FORMAT=json` and output is piped
- WHEN `log_error "fail"` is called
- THEN output MUST be valid JSON
- AND MUST NOT include ANSI codes

### Requirement: Backward compatibility

When `NEXUS_LOG_FORMAT` is unset or set to `text`, the library MUST behave identically to the current implementation. Setting `NEXUS_LOG_FORMAT` MUST NOT break any existing caller.

#### Scenario: Unset format defaults to text

- GIVEN `NEXUS_LOG_FORMAT` is not set
- WHEN any log function is called
- THEN behavior MUST match current text-only implementation
