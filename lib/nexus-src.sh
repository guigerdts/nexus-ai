#!/usr/bin/env bash
# NEXUS AI — lib/nexus-src.sh
# Centralized sourcing system with declare -A redeclaration guards
# Version: 0.8.2

set -euo pipefail

# ── Auto-detect NEXUS_ROOT if not already set ────────────────────
# Resolves from BASH_SOURCE[0] when loaded for the first time
if [ -z "${NEXUS_ROOT:-}" ]; then
    _nexus_src_path="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)/.."
    export NEXUS_ROOT="$_nexus_src_path"
    unset _nexus_src_path
fi

# ── Redeclaration guard: associative array for sourced modules ────
# Key: module name (e.g., "env", "log", "install")
# Value: 1 = already sourced
declare -A _NEXUS_SOURCED

# ── Module map: logical name → relative path from NEXUS_ROOT/lib/ ──
# Keep this in sync with available lib files
declare -A _NEXUS_SRC_MODULES=(
    ["env"]="config/env.sh"
    ["log"]="lib/nexus-log.sh"
    ["install"]="lib/nexus-install.sh"
    ["figlet"]="lib/nexus-figlet.sh"
    ["update"]="lib/nexus-update.sh"
    ["guide"]="lib/nexus-guide.sh"
    ["ui"]="lib/nexus-ui.sh"
    ["c-helper"]="lib/nexus-c-helper.sh"
    ["proot"]="lib/nexus-proot.sh"
    ["pg"]="lib/nexus-pg.sh"
)

# ── nexus_require: source a module once with guard ──────────────
# Uso: nexus_require <module_name>
# Module name must exist in _NEXUS_SRC_MODULES
nexus_require() {
    local _module="${1:-}"

    if [ -z "$_module" ]; then
        echo "[ERROR] nexus_require: module name required" >&2
        return 1
    fi

    # Return immediately if already sourced
    if [[ -v _NEXUS_SOURCED["$_module"] ]]; then
        return 0
    fi

    # Resolve path from module map
    local _rel_path="${_NEXUS_SRC_MODULES[$_module]:-}"
    if [ -z "$_rel_path" ]; then
        echo "[ERROR] nexus_require: unknown module '$_module'" >&2
        return 1
    fi

    local _full_path="$NEXUS_ROOT/$_rel_path"
    if [ ! -f "$_full_path" ]; then
        echo "[ERROR] nexus_require: module '$_module' not found at $_full_path" >&2
        return 1
    fi

    # Implicit dependency: env must be loaded before any color-dependent lib
    if [ "$_module" != "env" ] && [[ ! -v _NEXUS_SOURCED["env"] ]]; then
        nexus_require "env"
    fi

    # Source the module
    # shellcheck source=/dev/null
    source "$_full_path"

    # Mark as sourced
    _NEXUS_SOURCED["$_module"]=1
}

# ── nexus_require_path: source arbitrary path with guard ─────────
# Uso: nexus_require_path <absolute_or_relative_path> [guard_name]
# If guard_name not provided, uses basename of path
nexus_require_path() {
    local _path="${1:-}"
    local _guard="${2:-}"

    if [ -z "$_path" ]; then
        echo "[ERROR] nexus_require_path: path required" >&2
        return 1
    fi

    # Resolve to absolute path
    if [[ "$_path" != /* ]]; then
        _path="$NEXUS_ROOT/$_path"
    fi

    if [ ! -f "$_path" ]; then
        echo "[ERROR] nexus_require_path: file not found at $_path" >&2
        return 1
    fi

    # Default guard name from basename without extension
    if [ -z "$_guard" ]; then
        _guard="$(basename "$_path" .sh)"
    fi

    if [[ -v _NEXUS_SOURCED["$_guard"] ]]; then
        return 0
    fi

    # shellcheck source=/dev/null
    source "$_path"
    _NEXUS_SOURCED["$_guard"]=1
}
