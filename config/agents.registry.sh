#!/usr/bin/env bash
# NEXUS AI — config/agents.registry.sh
# Registro de agentes: construye un array asociativo desde modules/*/metadata.sh
# Version: 0.8.0
#
# Uso: source config/agents.registry.sh
# Luego se accede via: ${AGENTS[nombre]} -> ruta del directorio
# Las variables AGENT_* se exportan desde cada metadata.sh

# ── Verificar que NEXUS_MODULES_DIR existe ─────────
if [ -z "${NEXUS_MODULES_DIR:-}" ]; then
    echo "[ERROR] NEXUS_MODULES_DIR no definido. Sourcea config/env.sh primero." >&2
    return 1 2>/dev/null || exit 1
fi

# ── Registry cache functions ──────────────────────
# Cache serializes AGENTS + AGENT_ORDER as valid Bash for fast load.
# Invalidated when any modules/*/metadata.sh is newer than the cache.
_registry_cache_generate() {
    local cache_file="${NEXUS_ROOT}/logs/registry.cache.sh"
    mkdir -p "$(dirname "$cache_file")" 2>/dev/null || true
    {
        echo "# NEXUS AI — Registry cache (generated $(date '+%Y-%m-%d %H:%M:%S'))"
        echo "# This file is auto-generated. Do not edit."
        declare -p AGENTS 2>/dev/null
        declare -p AGENT_ORDER 2>/dev/null
    } > "$cache_file" 2>/dev/null || true
}

_registry_cache_load() {
    local cache_file="${NEXUS_ROOT}/logs/registry.cache.sh"
    [ -f "$cache_file" ] || return 1

    # Check if any metadata.sh is newer than the cache (stale)
    if find "$NEXUS_MODULES_DIR" -name 'metadata.sh' -newer "$cache_file" 2>/dev/null | grep -q .; then
        return 1
    fi

    source "$cache_file" 2>/dev/null || return 1

    # Validate: cached paths must exist on disk.
    # Handles stale caches from placeholder NEXUS_ROOT or moved installations.
    if [ ${#AGENTS[@]} -gt 0 ] && [ ${#AGENT_ORDER[@]} -gt 0 ]; then
        local _first_name="${AGENT_ORDER[0]}"
        local _first_dir="${AGENTS[$_first_name]:-}"
        if [ -n "$_first_dir" ] && [ ! -d "$_first_dir" ]; then
            rm -f "$cache_file" 2>/dev/null || true
            AGENTS=()
            AGENT_ORDER=()
            return 1
        fi
    fi

    return 0
}

# ── Array asociativo: AGENTE -> directorio ─────────
declare -A AGENTS
declare -a AGENT_ORDER

# ── Fast path: cargar cache si está fresco ────────
if _registry_cache_load; then
    # Cache loaded successfully — skip module iteration
    # shellcheck source=config/categories.sh
    source "$NEXUS_ROOT/config/categories.sh"
    return 0 2>/dev/null || exit 0
fi

if [ -d "$NEXUS_MODULES_DIR" ]; then
    for _agent_dir in "$NEXUS_MODULES_DIR"/*/; do
        [ -d "$_agent_dir" ] || continue

        # No usar local fuera de funciones en bash
        _agent_name=""
        _agent_version=""
        _agent_desc=""
        _agent_url=""
        _agent_tier=""
        _agent_category=""
        _agent_method=""
        _agent_binary=""

        if [ -f "$_agent_dir/metadata.sh" ]; then
            # Unset ALL AGENT_* vars to prevent cross-module leakage (BUG1)
            unset AGENT_NAME AGENT_VERSION AGENT_DESC AGENT_URL AGENT_TIER AGENT_CATEGORY AGENT_FLAG AGENT_METHOD AGENT_BINARY AGENT_PACKAGE AGENT_DEPRECATED AGENT_SUCCESSOR
            # shellcheck source=/dev/null
            source "$_agent_dir/metadata.sh"

            _agent_name="${AGENT_NAME:-$(basename "$_agent_dir")}"
            _agent_version="${AGENT_VERSION:-0.0.0}"
            _agent_desc="${AGENT_DESC:-}"
            _agent_url="${AGENT_URL:-}"
            _agent_tier="${AGENT_TIER:-3}"
            _agent_category="${AGENT_CATEGORY:-}"
            _agent_flag="${AGENT_FLAG:-}"
            _agent_method="${AGENT_METHOD:-unknown}"
            _agent_binary="${AGENT_BINARY:-}"
        else
            _agent_name="$(basename "$_agent_dir")"
            log_warn "Agente '$_agent_name' no tiene metadata.sh (INCOMPLETO)"
        fi

        AGENTS["$_agent_name"]="$_agent_dir"
        AGENT_ORDER+=("$_agent_name")

        export AGENT_NAME="$_agent_name"
        export AGENT_VERSION="$_agent_version"
        export AGENT_DESC="$_agent_desc"
        export AGENT_URL="$_agent_url"
        export AGENT_TIER="$_agent_tier"
        export AGENT_CATEGORY="$_agent_category"
        export AGENT_FLAG="$_agent_flag"
        export AGENT_METHOD="$_agent_method"
        export AGENT_BINARY="$_agent_binary"
    done
fi

# ── Generar cache antes de categories.sh ──────────
_registry_cache_generate

# ── Source categories.sh ──────────────────────────
# shellcheck source=config/categories.sh
source "$NEXUS_ROOT/config/categories.sh"

# Limpiar variables temporales y metadatos que puedan filtrarse
unset _agent_dir _agent_name _agent_version _agent_desc _agent_url _agent_tier _agent_category _agent_flag _agent_method _agent_binary
unset AGENT_DEPRECATED AGENT_SUCCESSOR

# ── Funcion helper: listar agentes registrados ────
registry_list() {
    if [ ${#AGENTS[@]} -eq 0 ]; then
        echo "No hay agentes registrados."
        return 0
    fi

    for _name in "${AGENT_ORDER[@]}"; do
        local _dir="${AGENTS[$_name]}"
        local _meta="$_dir/metadata.sh"
        if [ -f "$_meta" ]; then
            # shellcheck source=/dev/null
            source "$_meta"
            echo "${AGENT_NAME:-$_name} | ${AGENT_TIER:-3} | ${AGENT_CATEGORY:-} | ${AGENT_METHOD:-unknown} | ${AGENT_DESC:-}"
        else
            echo "$_name | ? | ? | (INCOMPLETO - sin metadata.sh)"
        fi
    done
}

# ── Funcion helper: obtener metadata de un agente ──
registry_get() {
    local name="$1"
    local dir="${AGENTS[$name]:-}"

    if [ -z "$dir" ]; then
        echo "[ERROR] Agente '$name' no encontrado en el registro." >&2
        return 1
    fi

    if [ -f "$dir/metadata.sh" ]; then
        # shellcheck source=/dev/null
        source "$dir/metadata.sh"
        echo "$AGENT_NAME|$AGENT_VERSION|$AGENT_DESC|$AGENT_URL|$AGENT_TIER|$AGENT_CATEGORY|$AGENT_METHOD|$AGENT_BINARY"
    else
        echo "[WARN] Agente '$name' no tiene metadata.sh" >&2
        return 1
    fi
}
