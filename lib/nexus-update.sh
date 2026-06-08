#!/usr/bin/env bash
# NEXUS AI — lib/nexus-update.sh
# Módulo de actualizaciones: check silencioso, check verbose, apply
# Version: 0.8.0
#
# Dependencias: NEXUS_ROOT, NEXUS_VERSION (desde config/env.sh)
# Cache temporal en ${TMPDIR:-/tmp}/nexus-version-check (TTL: 24h)

# ── Config ────────────────────────────────────────
_nexus_update_cache_file="${TMPDIR:-/tmp}/nexus-version-check"
_nexus_update_cache_ttl=86400  # 24 horas en segundos
_nexus_update_log_dir="$NEXUS_ROOT/logs"
_nexus_update_log_file="$_nexus_update_log_dir/update-check.log"

# ── _nexus_version_compare: compara dos versiones semver ──
# Uso: _nexus_version_compare "local" "remote"
# Returns: 0 si iguales, 1 si local < remote, 2 si error
_nexus_version_compare() {
    local _local="${1:-}"
    local _remote="${2:-}"

    # Limpiar prefijo v si existe
    _local="${_local#v}"
    _remote="${_remote#v}"

    # Validar que no estén vacíos
    if [ -z "$_local" ] || [ -z "$_remote" ]; then
        return 2
    fi

    # Validar formato semver básico (n.n.n)
    if ! echo "$_local" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$' || \
       ! echo "$_remote" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
        return 2
    fi

    # Comparar
    if [ "$_local" = "$_remote" ]; then
        return 0
    fi

    # Sort version: la que aparece primero en sort -V es la menor
    local _sorted
    _sorted="$(printf '%s\n%s\n' "$_local" "$_remote" | sort -V 2>/dev/null | head -1)"
    if [ "$_sorted" = "$_local" ]; then
        return 1  # local < remote
    else
        return 0  # local >= remote (ya cubrimos igualdad arriba)
    fi
}

# ── _nexus_update_cache_read: lee cache de version check ──
# Returns: version remota cacheadacd  o vacio si expirado/ausente
_nexus_update_cache_read() {
    if [ ! -f "$_nexus_update_cache_file" ]; then
        echo ""
        return 0
    fi

    local _timestamp _cached_version _now
    IFS=' ' read -r _timestamp _cached_version < "$_nexus_update_cache_file" 2>/dev/null || {
        echo ""
        return 0
    }

    _now=$(date +%s)

    # Si el timestamp no es un numero o esta vencido, cache invalido
    if ! echo "$_timestamp" | grep -qE '^[0-9]+$' 2>/dev/null; then
        echo ""
        return 0
    fi

    if [ $(( _now - _timestamp )) -lt "$_nexus_update_cache_ttl" ]; then
        echo "$_cached_version"
    else
        echo ""
    fi
}

# ── _nexus_update_cache_write: escribe cache de version check ──
# Uso: _nexus_update_cache_write "v0.8.0"
_nexus_update_cache_write() {
    local _version="${1:-unknown}"
    local _now
    _now=$(date +%s)
    echo "$_now $_version" > "$_nexus_update_cache_file" 2>/dev/null || true
}

# ── check_update_silent: verifica silenciosamente si hay nueva version ──
# Se ejecuta despues del banner. Nunca bloquea, nunca muestra errores.
check_update_silent() {
    # Leer cache
    local _cached
    _cached="$(_nexus_update_cache_read)"

    if [ -n "$_cached" ]; then
        # Cache valido — ver si hay actualizacion
        _nexus_version_compare "$NEXUS_VERSION" "$_cached"
        local _cmp=$?
        if [ "$_cmp" -eq 1 ]; then
            echo "[!] Nueva versión disponible: v$_cached"
        fi
        return 0
    fi

    # Cache expirado o ausente — fetch remoto
    local _remote_version
    _remote_version="$(curl --silent --fail --max-time 3 --connect-timeout 2 \
        "https://raw.githubusercontent.com/guigerdts/nexus-ai/main/VERSION" 2>/dev/null || true)"

    # Validar que recibimos algo con formato de version
    if [ -z "$_remote_version" ] || ! echo "$_remote_version" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+'; then
        return 0  # Silently ignore fetch failures
    fi

    # Escribir cache
    _nexus_update_cache_write "$_remote_version"

    # Comparar
    _nexus_version_compare "$NEXUS_VERSION" "$_remote_version"
    local _cmp=$?
    if [ "$_cmp" -eq 1 ]; then
        echo "[!] Nueva versión disponible: v$_remote_version"
    fi

    # Log
    mkdir -p "$_nexus_update_log_dir" 2>/dev/null || true
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] check: local=$NEXUS_VERSION remote=$_remote_version cmp=$_cmp" >> "$_nexus_update_log_file" 2>/dev/null || true
}

# ── check_update_verbose: muestra informacion detallada de version ──
# Se ejecuta con nxai update --check
check_update_verbose() {
    echo "Versión actual: v$NEXUS_VERSION"

    local _remote_version
    _remote_version="$(curl --silent --fail --max-time 5 --connect-timeout 3 \
        "https://raw.githubusercontent.com/guigerdts/nexus-ai/main/VERSION" 2>/dev/null || true)"

    if [ -z "$_remote_version" ] || ! echo "$_remote_version" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+'; then
        echo "[ERROR] No se pudo obtener la versión remota. Verifica tu conexión."
        return 1
    fi

    echo "Versión disponible: v$_remote_version"

    _nexus_version_compare "$NEXUS_VERSION" "$_remote_version"
    local _cmp=$?

    if [ "$_cmp" -eq 1 ]; then
        echo "¡Nueva versión disponible!"
        # Fetch release info from GitHub API
        local _release_info
        _release_info="$(curl --silent --fail --max-time 5 --connect-timeout 3 \
            "https://api.github.com/repos/guigerdts/nexus-ai/releases/latest" 2>/dev/null || true)"

        if [ -n "$_release_info" ]; then
            local _release_name _release_body
            _release_name="$(echo "$_release_info" | grep '"tag_name"' | head -1 | cut -d'"' -f4 2>/dev/null || true)"
            _release_body="$(echo "$_release_info" | grep '"body"' | head -1 | cut -d'"' -f4 2>/dev/null || true)"

            if [ -n "$_release_name" ]; then
                echo ""
                echo "=== $_release_name ==="
            fi
            if [ -n "$_release_body" ]; then
                echo "$_release_body"
            fi
        fi

        echo ""
        echo "Actualiza con: nxai update"
    elif [ "$_cmp" -eq 0 ]; then
        echo "Tienes la versión más reciente."
    fi
}

# ── apply_update: aplica la actualizacion ──
# Se ejecuta con nxai update (sin flags)
apply_update() {
    echo "Actualizando NEXUS AI..."

    if [ -d "$NEXUS_ROOT/.git" ]; then
        echo "  Repositorio Git detectado. Ejecutando git pull --ff-only..."
        if git -C "$NEXUS_ROOT" pull --ff-only origin main 2>/dev/null; then
            echo "[OK] Actualización completada."
            # Limpiar cache para forzar re-check en el proximo comando
            rm -f "$_nexus_update_cache_file" 2>/dev/null || true
        else
            echo "[ERROR] Falló la actualización via Git."
            echo "        Intenta manualmente: cd $NEXUS_ROOT && git pull"
            return 1
        fi
    else
        echo "  Sin repositorio Git. Descargando instalador..."
        if curl -fsSL "https://raw.githubusercontent.com/guigerdts/nexus-ai/main/install.sh" | bash -s -- --no-zsh --no-starship; then
            echo "[OK] Actualización completada."
            rm -f "$_nexus_update_cache_file" 2>/dev/null || true
        else
            echo "[ERROR] Falló la actualización."
            return 1
        fi
    fi
}

# ── module_update: actualiza un modulo especifico ──
# Uso: module_update "agent-name"
# Si el modulo tiene update.sh, lo ejecuta
module_update() {
    local agent="$1"
    local dir="${AGENTS[$agent]:-}"

    if [ -z "$dir" ]; then
        log_warn "Agente '${agent}' no encontrado."
        return 1
    fi

    if [ -f "$dir/update.sh" ]; then
        log_info "Actualizando ${agent}..."
        (source "$dir/update.sh")
    elif [ -f "$dir/install.sh" ]; then
        log_info "${agent} no tiene update.sh, reinstalando..."
        (source "$dir/install.sh")
    else
        log_warn "${agent} no tiene install.sh ni update.sh."
        return 1
    fi
}

# ── module_update_category: actualiza todos los agentes de una categoria ──
# Uso: module_update_category "ai" [--flags...]
module_update_category() {
    local category="$1"
    shift
    local agents_list="${CATEGORIES[$category]:-}"

    if [ -z "$agents_list" ]; then
        log_error "Categoria '${category}' no encontrada."
        return 1
    fi

    if [ $# -gt 0 ]; then
        # Flags especificos → resolver via FLAG_TO_AGENT
        local _parsed=()
        for _flag in "$@"; do
            local _name="${_flag#--}"
            local _agent="${FLAG_TO_AGENT[$_name]:-}"
            [ -n "$_agent" ] && _parsed+=("$_agent")
        done
        agents_list="${_parsed[*]}"
        unset _flag _name _agent _parsed
    fi

    for _agent in $agents_list; do
        module_update "$_agent"
    done
    unset _agent
}
