# engram-memory Specification

## Purpose

Bridge between the NEXUS AI CLI and Engram's persistent memory system. Investigates whether Engram exposes a CLI or HTTP API accessible from bash. If available, creates a wrapper at `lib/nexus-engram.sh`. If not, creates a stub module with manual configuration instructions. MUST NOT block the v0.2 release.

## Requirements

### Requirement: Engram interface investigation

The design phase MUST determine whether Engram exposes a standalone CLI binary, an HTTP API, or only MCP tools. The approach SHALL be chosen based on this finding.

#### Scenario: CLI available

- GIVEN Engram provides a standalone `engram` CLI binary
- WHEN the binary is invoked with `--help`
- THEN the system MUST parse its output
- AND use it as the backend for `nexus memory` subcommands

#### Scenario: Only MCP tools available

- GIVEN Engram is only accessible as an MCP server
- WHEN no standalone CLI or HTTP API is found
- THEN a Python bridge (`lib/nexus-engram.py`) MUST be implemented
- AND it MUST communicate with the MCP server from the terminal

#### Scenario: No interface found

- GIVEN no Engram CLI, HTTP API, or MCP server is accessible
- WHEN the investigation completes
- THEN a stub module MUST be created with README explaining manual setup
- AND `nexus memory status` MUST report "NO DISPONIBLE"

### Requirement: Memory subcommands (when available)

If a working bridge is possible, `nexus memory` MUST support `save`, `search`, `context`, `summary`, and `status`.

#### Scenario: Save a memory

- GIVEN the Engram bridge is operational
- WHEN `nexus memory save "title" --content "text"` is executed
- THEN the bridge MUST send the observation to Engram
- AND confirm "Memoria guardada" on success

#### Scenario: Search memories

- GIVEN memories exist in Engram
- WHEN `nexus memory search "keyword"` is executed
- THEN matching memories MUST be displayed
- AND output MUST be pure ASCII

### Requirement: Release non-blocking

The engram-memory module MUST NOT block the v0.2 release. If the bridge is incomplete, `nexus memory` MUST show a clear "no disponible" message and point to documentation.

#### Scenario: Bridge unavailable at release

- GIVEN v0.2 is being shipped
- WHEN the Engram bridge is not yet functional
- THEN `nexus memory` MUST print "Modulo de memoria no disponible"
- AND link to the setup documentation
- AND NOT error or crash
