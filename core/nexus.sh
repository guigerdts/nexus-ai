#!/usr/bin/env bash
# NEXUS AI — core/nexus.sh
# CLI principal: ruteo de subcomandos via case/esac
# Version: 0.2.0
#
# Symlink: bin/nxai -> ../core/nexus.sh
# Uso: nxai <comando> [opciones]



set -euo pipefail

# ── Auto-deteccion de NEXUS_ROOT ──────────────────
# Resuelve el directorio raiz desde la ubicacion del script
NEXUS_ROOT="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)/.."
export NEXUS_ROOT

# ── Source de modulos esenciales ──────────────────
# shellcheck source=config/env.sh
source "$NEXUS_ROOT/config/env.sh"

# shellcheck source=config/agents.registry.sh
source "$NEXUS_ROOT/config/agents.registry.sh"

# shellcheck source=lib/nexus-log.sh
source "$NEXUS_ROOT/lib/nexus-log.sh"

# shellcheck source=lib/nexus-install.sh
source "$NEXUS_ROOT/lib/nexus-install.sh"

# ── show_help: muestra uso del CLI ─────────────────
show_help() {
    cat <<EOF
NEXUS AI v${NEXUS_VERSION} — CLI de gestion de agentes

Uso: nxai <comando> [opciones]

Comandos:
  install [--all|<agente>]  Instala uno o todos los agentes
  remove <agente>           Desinstala un agente
  list                      Lista agentes registrados
  status                    Muestra estado del sistema
  agent add <nombre> <url>  Anade un nuevo agente (esqueleto)
  agent test <nombre>       Prueba un agente instalado
  dashboard, ui            Inicia el Dashboard TUI
  memory                    Gestion de memoria engram (proximamente)
  update                    Actualiza componentes (proximamente)
  help, --help              Muestra esta ayuda

Ejemplos:
  nxai install --all       Instala todos los agentes
  nxai install aider       Instala solo aider
  nxai remove aider        Desinstala aider
  nxai list                Lista agentes y su estado
  nxai status              Info del sistema
  nxai agent test aider    Prueba si aider funciona
  nxai help                Muestra esta ayuda
EOF
}

# ── list_agents: lista agentes y su estado ─────────
list_agents() {
    if [ ${#AGENTS[@]} -eq 0 ]; then
        log_info "No hay agentes registrados en $NEXUS_MODULES_DIR"
        return 0
    fi

    echo "Agentes registrados:"
    echo "---"
    for _name in "${AGENT_ORDER[@]}"; do
        local _dir="${AGENTS[$_name]}"
        local _meta="$_dir/metadata.sh"
        local _status=""

        if [ -f "$_meta" ]; then
            # shellcheck source=/dev/null
            source "$_meta"
        fi

        # Verificar si el binario existe
        if [ -n "${AGENT_BINARY:-}" ] && command -v "$AGENT_BINARY" &>/dev/null; then
            _status="${_NEXUS_CYAN}[INSTALADO]${_NEXUS_RESET}"
        elif [ -f "$_dir/test.sh" ] && bash "$_dir/test.sh" &>/dev/null; then
            _status="${_NEXUS_CYAN}[INSTALADO]${_NEXUS_RESET}"
        else
            _status="${_NEXUS_YELLOW}[NO INSTALADO]${_NEXUS_RESET}"
        fi

        echo -e "  ${AGENT_NAME:-$_name} (Tier ${AGENT_TIER:-?}) $_status"
        if [ -n "${AGENT_DESC:-}" ]; then
            echo -e "    -> ${AGENT_DESC}"
        fi
    done
    unset _name _dir _meta _status
}

# ── install_agent: instala uno o todos los agentes ─
install_agent() {
    local target="${1:-}"

    if [ "$target" = "--all" ] || [ -z "$target" ]; then
        log_info "Instalando todos los agentes..."
        for _name in "${AGENT_ORDER[@]}"; do
            local _dir="${AGENTS[$_name]}"
            if [ -f "$_dir/install.sh" ]; then
                log_info "Instalando $_name..."
                # shellcheck source=/dev/null
                (source "$_dir/install.sh") || log_warn "Fallo al instalar $_name"
            else
                log_warn "$_name no tiene install.sh, saltando"
            fi
        done
        unset _name _dir
        log_ok "Instalacion completada."
        return 0
    fi

    # Instalar un agente especifico
    local _dir="${AGENTS[$target]:-}"
    if [ -z "$_dir" ]; then
        log_error "Agente '$target' no encontrado en el registro."
        log_info "Agentes disponibles: ${AGENT_ORDER[*]}"
        return 1
    fi

    if [ -f "$_dir/install.sh" ]; then
        log_info "Instalando $target..."
        # shellcheck source=/dev/null
        (source "$_dir/install.sh")
    else
        log_warn "$target no tiene install.sh"
    fi
}

# ── remove_agent: desinstala un agente ─────────────
remove_agent() {
    local target="${1:-}"

    if [ -z "$target" ]; then
        log_error "Uso: nxai remove <agente>"
        return 1
    fi

    local _dir="${AGENTS[$target]:-}"
    if [ -z "$_dir" ]; then
        log_error "Agente '$target' no encontrado."
        return 1
    fi

    # Source metadata para obtener metodo y binario
    if [ -f "$_dir/metadata.sh" ]; then
        # shellcheck source=/dev/null
        source "$_dir/metadata.sh"
    fi

    local _pkg="${AGENT_PACKAGE:-$AGENT_NAME}"

    case "${AGENT_METHOD:-}" in
        pip)
            uninstall_via_pip "$_pkg"
            ;;
        npm)
            uninstall_via_npm "$_pkg"
            ;;
        curl|cargo|apt)
            if [ -n "${AGENT_BINARY:-}" ] && command -v "$AGENT_BINARY" &>/dev/null; then
                rm -f "$(command -v "$AGENT_BINARY")" 2>/dev/null || true
            fi
            ;;
        *)
            log_warn "Metodo '$AGENT_METHOD' no tiene desinstalador automatico."
            if [ -n "${AGENT_BINARY:-}" ] && command -v "$AGENT_BINARY" &>/dev/null; then
                rm -f "$(command -v "$AGENT_BINARY")" 2>/dev/null || true
            fi
            ;;
    esac

    mark_removed "$target"
    log_ok "Agente '$target' desinstalado."
    unset _pkg
}

# ── agent_add: agrega un agente custom ─────────────
agent_add() {
    local _add_name="${1:-}"
    local _add_url="${2:-}"

    if [ -z "$_add_name" ] || [ -z "$_add_url" ]; then
        log_error "Uso: nxai agent add <nombre> <url>"
        return 1
    fi

    local _add_target_dir="$NEXUS_MODULES_DIR/$_add_name"

    if [ -d "$_add_target_dir" ]; then
        log_error "El agente '$_add_name' ya existe."
        return 1
    fi

    log_info "Clonando repositorio desde $_add_url..."
    if ! git clone "$_add_url" "$_add_target_dir" 2>/dev/null; then
        log_error "Error al clonar el repositorio."
        return 1
    fi

    if [ ! -f "$_add_target_dir/metadata.sh" ]; then
        log_warn "El repositorio clonado no contiene metadata.sh. Eliminando..."
        rm -rf "$_add_target_dir"
        log_info "Directorio '$_add_name' eliminado."
        return 1
    fi

    log_ok "Agente '$_add_name' agregado correctamente."
    unset _add_name _add_url _add_target_dir
}

# ── agent_test: prueba un agente ───────────────────
agent_test() {
    local _test_name="${1:-}"

    if [ -z "$_test_name" ]; then
        log_error "Uso: nxai agent test <nombre>"
        return 1
    fi

    local _test_dir="${AGENTS[$_test_name]:-}"
    if [ -z "$_test_dir" ]; then
        log_error "Agente '$_test_name' no encontrado."
        return 1
    fi

    local _test_sh="$_test_dir/test.sh"
    if [ ! -f "$_test_sh" ]; then
        log_warn "$_test_name no tiene test.sh"
        return 0
    fi

    local _start_time _end_time _elapsed _exit_code=0
    _start_time=$(date +%s)

    timeout 10 bash "$_test_sh" || _exit_code=$?

    _end_time=$(date +%s)
    _elapsed=$(( _end_time - _start_time ))

    if [ "$_exit_code" -eq 124 ]; then
        log_error "$_test_name: TIMEOUT (>10s)"
    elif [ "$_exit_code" -eq 0 ]; then
        log_ok "$_test_name: PASS (${_elapsed}.0s)"
    else
        log_error "$_test_name: FAIL (${_elapsed}.0s)"
    fi
    unset _test_name _test_dir _test_sh _start_time _end_time _elapsed _exit_code
}

# ── system_status: muestra estado del sistema ──────
system_status() {
    local agent_count=${#AGENTS[@]}
    local installed_count=0

    for _name in "${AGENT_ORDER[@]}"; do
        local _dir="${AGENTS[$_name]}"
        if [ -f "$_dir/metadata.sh" ]; then
            # shellcheck source=/dev/null
            source "$_dir/metadata.sh"
        fi
        if [ -n "${AGENT_BINARY:-}" ] && command -v "$AGENT_BINARY" &>/dev/null; then
            installed_count=$((installed_count + 1))
        elif [ -f "$_dir/test.sh" ] && bash "$_dir/test.sh" &>/dev/null 2>&1; then
            installed_count=$((installed_count + 1))
        fi
    done
    unset _name _dir

    echo "=== Estado del Sistema NEXUS AI ==="
    echo "Version:      ${NEXUS_VERSION}"
    echo "Entorno:      ${NEXUS_ENV}"
    echo "Arquitectura: ${NEXUS_ARCH}"
    echo "Directorio:   ${NEXUS_ROOT}"
    echo "Agentes:      ${installed_count}/${agent_count} instalados"
    echo "Language:     ${NEXUS_LANG}"
    echo ""
    echo "Modulos cargados:"
    echo "  env.sh    -> ${NEXUS_ROOT}/config/env.sh"
    echo "  registry  -> ${NEXUS_REGISTRY}"
    echo "  log       -> ${NEXUS_ROOT}/lib/nexus-log.sh"
    echo "  install   -> ${NEXUS_ROOT}/lib/nexus-install.sh"
}

# ═══════════════════════════════════════════════════
#  MAIN: Ruteo de subcomandos
# ═══════════════════════════════════════════════════

COMMAND="${1:-}"
shift 2>/dev/null || true

case "${COMMAND}" in
    dashboard|ui)
        # --help flag: show usage without requiring textual
        for _arg in "$@"; do
            case "$_arg" in
                --help|-h)
                    echo "Uso: nxai dashboard [opciones]"
                    echo "  Inicia el Dashboard TUI de NEXUS AI"
                    echo ""
                    echo "Opciones:"
                    echo "  --help    Muestra esta ayuda"
                    echo ""
                    echo "Alias: nxai ui"
                    exit 0
                    ;;
            esac
        done
        unset _arg

        # shellcheck source=config/env.sh
        source "$NEXUS_ROOT/config/env.sh"
        export NEXUS_ROOT

        if ! python3 -c "import textual" 2>/dev/null; then
            echo "=== NEXUS AI Dashboard ==="
            echo "Requiere Textual (framework TUI para Python)."
            echo ""
            echo "Instalalo con:"
            echo "  pip install 'textual>=0.50.0'"
            echo ""
            echo "Despues volve a ejecutar: nxai dashboard"
            exit 1
        fi

        exec python3 "$NEXUS_ROOT/tui/dashboard.py" "$@"
        ;;
    install)
        install_agent "$@"
        ;;
    remove)
        remove_agent "$@"
        ;;
    list)
        list_agents
        ;;
    status)
        system_status
        ;;
    agent)
        SUBCOMMAND="${1:-}"
        shift 2>/dev/null || true
        case "${SUBCOMMAND}" in
            add)
                agent_add "$@"
                ;;
            test)
                agent_test "$@"
                ;;
            *)
                log_error "Uso: nxai agent add <nombre> <url> | nxai agent test <nombre>"
                exit 1
                ;;
        esac
        ;;
    memory)
        log_error "No implementado aun. Fase 5."
        ;;
    update)
        log_error "No implementado aun."
        ;;
    help|--help|"")
        show_help
        ;;
    *)
        log_error "Comando desconocido: ${COMMAND}"
        echo ""
        show_help
        exit 1
        ;;
esac
