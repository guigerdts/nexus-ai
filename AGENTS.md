# NEXUS AI — Code Review Rules

## Shell
- Use `#!/usr/bin/env bash` shebang
- Use `set -euo pipefail` for scripts with errors
- Use `local` for function-scoped variables
- Use `[[ ]]` over `[ ]` for conditionals
- No `sudo`, no hardcoded paths
- `echo -e` for ANSI escape sequences
- `BASH_SOURCE[0]` not `$0` for script path detection

## Functions
- camelCase for function names
- Document with `# ── comment ──` section headers
- One function per concern

## Variables
- UPPER_CASE for exports and globals
- snake_case for locals
- Prefix with `_` for script-internal variables
- `declare` inside a function creates **local** scope — use `declare -gA` / `declare -ga` for data serialized to be sourced later (see `logs/registry.cache.sh`)
- Never `source` a file with `declare -A` inside a function; either source at outer scope or write `declare -gA` in the sourced file
