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

# ── Array asociativo: AGENTE -> directorio ─────────
declare -A AGENTS
declare -a AGENT_ORDER

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

# ── Source categories.sh (relies on AGENT_CATEGORY from metadata) ─
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
