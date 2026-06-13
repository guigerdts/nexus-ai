#!/usr/bin/env bash
# NEXUS AI — lib/nexus-pg.sh
# PostgreSQL cluster management: init, start, stop, create/drop databases and users
# Version: 0.8.2
#
# Dependencias: PostgreSQL instalado (pkg install postgresql o apt install postgresql)
#               NEXUS_COLOR_* vars de config/env.sh

set -euo pipefail

# ── Config ────────────────────────────────────────
_NEXUS_PG_DEFAULT_DATA="${NEXUS_ROOT:-$HOME}/nexus-ai/data/pg"
_NEXUS_PG_DEFAULT_PORT=5432
_NEXUS_PG_LOG="${NEXUS_ROOT:-$HOME}/nexus-ai/logs/pg.log"

# ── nexus_pg_detect: encuentra pg_ctl binary ──
# Returns: path a pg_ctl en stdout, exit 0 si ok, exit 1 si no encontrado
nexus_pg_detect() {
    # 1. Env var override
    if [ -n "${NEXUS_PG_CTL:-}" ] && [ -x "$NEXUS_PG_CTL" ]; then
        echo "$NEXUS_PG_CTL"
        return 0
    fi

    # 2. pg_config (official PostgreSQL discovery, cross-distro)
    if command -v pg_config &>/dev/null; then
        local _bindir
        _bindir="$(pg_config --bindir 2>/dev/null || true)"
        if [ -n "$_bindir" ] && [ -x "$_bindir/pg_ctl" ]; then
            echo "$_bindir/pg_ctl"
            return 0
        fi
    fi

    # 3. Fallback: pg_ctl in PATH
    if command -v pg_ctl &>/dev/null; then
        echo "pg_ctl"
        return 0
    fi

    log_error "PostgreSQL no encontrado. Instala con: pkg install postgresql"
    return 1
}

# ── nexus_pg_detect_data: encuentra data directory ──
# Returns: path del data directory en stdout, exit 1 si no encontrado
nexus_pg_detect_data() {
    local _candidates=(
        "$_NEXUS_PG_DEFAULT_DATA"
        "${PREFIX:-/data/data/com.termux/files/usr}/var/lib/postgresql"
        "${PREFIX:-/data/data/com.termux/files/usr}/var/lib/postgresql/data"
        "$HOME/.nexus-pg/data"
        "/var/lib/postgresql"
        "/var/lib/postgresql/16/main"
        "/var/lib/postgresql/17/main"
        "/var/lib/postgresql/14/main"
    )

    for _dir in "${_candidates[@]}"; do
        if [ -d "$_dir" ] && [ -f "$_dir/PG_VERSION" ]; then
            echo "$_dir"
            return 0
        fi
    done

    return 1
}

# ── nexus_pg_init: inicializa cluster PostgreSQL ──
# Uso: nexus_pg_init [data_dir]
nexus_pg_init() {
    local _data_dir="${1:-$_NEXUS_PG_DEFAULT_DATA}"
    local _pg_ctl
    _pg_ctl="$(nexus_pg_detect)" || return 1

    # Check if already initialized
    if [ -f "$_data_dir/PG_VERSION" ]; then
        log_warn "PostgreSQL ya inicializado en: $_data_dir"
        return 0
    fi

    log_info "Inicializando PostgreSQL en $_data_dir..."
    mkdir -p "$(dirname "$_data_dir")" 2>/dev/null || true

    if initdb -D "$_data_dir" 2>>"$_NEXUS_PG_LOG"; then
        log_success "PostgreSQL inicializado correctamente"
        echo "  Data dir: $_data_dir"
        echo "  Para iniciar: nxai pg start"
        return 0
    else
        log_error "Fallo la inicializacion. Revisa: $_NEXUS_PG_LOG"
        return 1
    fi
}

# ── nexus_pg_start: inicia servidor PostgreSQL ──
# Uso: nexus_pg_start [data_dir] [port]
nexus_pg_start() {
    local _data_dir="${1:-}"
    local _port="${2:-$_NEXUS_PG_DEFAULT_PORT}"
    local _pg_ctl
    _pg_ctl="$(nexus_pg_detect)" || return 1

    # Auto-detect data dir if not provided
    if [ -z "$_data_dir" ]; then
        _data_dir="$(nexus_pg_detect_data || true)"
        if [ -z "$_data_dir" ]; then
            log_warn "No se encontro data directory. Ejecuta: nxai pg init"
            return 1
        fi
    fi

    # Check if already running
    if "$_pg_ctl" -D "$_data_dir" status &>/dev/null; then
        log_info "PostgreSQL ya esta corriendo"
        return 0
    fi

    log_info "Iniciando PostgreSQL en puerto $_port..."
    mkdir -p "$(dirname "$_NEXUS_PG_LOG")" 2>/dev/null || true

    if "$_pg_ctl" -D "$_data_dir" -l "$_NEXUS_PG_LOG" -o "-p $_port" start 2>/dev/null; then
        sleep 1
        log_success "PostgreSQL iniciado (puerto $_port)"
        return 0
    else
        log_error "Fallo al iniciar PostgreSQL. Revisa: $_NEXUS_PG_LOG"
        return 1
    fi
}

# ── nexus_pg_stop: detiene servidor PostgreSQL ──
# Uso: nexus_pg_stop [data_dir]
nexus_pg_stop() {
    local _data_dir="${1:-}"
    local _pg_ctl
    _pg_ctl="$(nexus_pg_detect)" || return 1

    # Auto-detect data dir
    if [ -z "$_data_dir" ]; then
        _data_dir="$(nexus_pg_detect_data || true)"
        if [ -z "$_data_dir" ]; then
            log_warn "No se encontro data directory"
            return 1
        fi
    fi

    log_info "Deteniendo PostgreSQL..."
    if "$_pg_ctl" -D "$_data_dir" stop 2>/dev/null; then
        log_success "PostgreSQL detenido"
        return 0
    else
        log_warn "PostgreSQL no estaba corriendo"
        return 0
    fi
}

# ── nexus_pg_status: muestra estado del servidor ──
nexus_pg_status() {
    local _pg_ctl
    _pg_ctl="$(nexus_pg_detect)" || return 1

    local _data_dir
    _data_dir="$(nexus_pg_detect_data || true)"

    if [ -n "$_data_dir" ]; then
        if "$_pg_ctl" -D "$_data_dir" status &>/dev/null; then
            log_success "PostgreSQL: RUNNING"
            echo "  Data dir: $_data_dir"
            return 0
        else
            log_warn "PostgreSQL: STOPPED"
            echo "  Data dir: $_data_dir"
            return 0
        fi
    else
        log_info "PostgreSQL no inicializado. Ejecuta: nxai pg init"
        return 1
    fi
}

# ── nexus_pg_create_db: crea base de datos ──
# Uso: nexus_pg_create_db <name> [owner]
nexus_pg_create_db() {
    local _db_name="${1:-}"
    local _owner="${2:-}"

    if [ -z "$_db_name" ]; then
        log_error "Uso: nexus_pg_create_db <name> [owner]"
        return 1
    fi

    nexus_pg_detect >/dev/null || return 1

    if [ -n "$_owner" ]; then
        if createdb "$_db_name" -O "$_owner" 2>/dev/null; then
            log_success "Base de datos '$_db_name' creada (owner: $_owner)"
        else
            log_error "Fallo al crear base de datos '$_db_name'"
            return 1
        fi
    else
        if createdb "$_db_name" 2>/dev/null; then
            log_success "Base de datos '$_db_name' creada"
        else
            log_error "Fallo al crear base de datos '$_db_name'"
            return 1
        fi
    fi
}

# ── nexus_pg_drop_db: elimina base de datos ──
# Uso: nexus_pg_drop_db <name>
nexus_pg_drop_db() {
    local _db_name="${1:-}"

    if [ -z "$_db_name" ]; then
        log_error "Uso: nexus_pg_drop_db <name>"
        return 1
    fi

    nexus_pg_detect >/dev/null || return 1

    log_warn "Esto eliminara permanentemente la base de datos: $_db_name"
    if ! ui_confirm "¿Continuar?"; then
        log_info "Operacion cancelada"
        return 0
    fi

    if dropdb "$_db_name" 2>/dev/null; then
        log_success "Base de datos '$_db_name' eliminada"
    else
        log_error "Fallo al eliminar base de datos '$_db_name'"
        return 1
    fi
}

# ── nexus_pg_create_user: crea usuario de PostgreSQL ──
# Uso: nexus_pg_create_user <name> [password]
nexus_pg_create_user() {
    local _user="${1:-}"
    local _pass="${2:-}"

    if [ -z "$_user" ]; then
        log_error "Uso: nexus_pg_create_user <name> [password]"
        return 1
    fi

    nexus_pg_detect >/dev/null || return 1

    if [ -n "$_pass" ]; then
        if psql -c "CREATE USER $_user WITH PASSWORD '$_pass';" 2>/dev/null; then
            log_success "Usuario '$_user' creado"
        else
            log_error "Fallo al crear usuario '$_user' (puede que ya exista)"
            return 1
        fi
    else
        if psql -c "CREATE USER $_user;" 2>/dev/null; then
            log_success "Usuario '$_user' creado"
        else
            log_error "Fallo al crear usuario '$_user' (puede que ya exista)"
            return 1
        fi
    fi
}
