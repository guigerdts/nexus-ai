#!/usr/bin/env bash
# NEXUS AI — core/nexus.sh
# CLI principal: ruteo de subcomandos via case/esac
# Version: 0.6.0
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

# shellcheck source=lib/nexus-update.sh
source "$NEXUS_ROOT/lib/nexus-update.sh"

# shellcheck source=lib/nexus-guide.sh
source "$NEXUS_ROOT/lib/nexus-guide.sh"

# ── show_help: muestra uso del CLI ─────────────────
show_help() {
    printf "\n"
    printf "\033[1mUso:\033[0m \033[1;36mnxai\033[0m \033[1m<comando>\033[0m [opciones]\n"
    printf "\n"
    printf "\033[1mComandos disponibles:\033[0m\n"
    printf "  \033[1m%-12s\033[0m %s\n" "install"   "Instalar agentes y herramientas"
    printf "  \033[1m%-12s\033[0m %s\n" "remove"    "Desinstalar agentes"
    printf "  \033[1m%-12s\033[0m %s\n" "list"      "Listar agentes disponibles"
    printf "  \033[1m%-12s\033[0m %s\n" "status"    "Estado del sistema"
    printf "  \033[1m%-12s\033[0m %s\n" "update"    "Actualizar NEXUS AI"
    printf "  \033[1m%-12s\033[0m %s\n" "guide"     "Guia de uso por categorias"
    printf "  \033[1m%-12s\033[0m %s\n" "dashboard" "Abrir panel TUI"
    printf "  \033[1m%-12s\033[0m %s\n" "agent"     "Gestionar agentes custom"
    printf "  \033[1m%-12s\033[0m %s\n" "help"      "Mostrar esta ayuda"
    printf "\n"
    printf "\033[1mInicio rapido:\033[0m\n"
    printf "  \033[1;36mnxai guide\033[0m              Ver guia completa\n"
    printf "  \033[1;36mnxai install --all\033[0m      Instalar todos los agentes\n"
    printf "  \033[1;36mnxai list\033[0m               Ver agentes disponibles\n"
    printf "  \033[1;36mnxai dashboard\033[0m          Abrir panel visual\n"
    printf "\n"
    printf "\033[1mModulos por categoria (\033[1;36mnxai install\033[0m \033[1m<modulo>\033[0m\033[1m):\033[0m\n"
    printf "  \033[1m%-12s\033[0m opencode, codex, gemini-cli, claude-code, ollama, engram,\n" "ai"
    printf "  %-12s  sgpt, fabric, antigravity, pi, gentle-ai, qwen-code,\n" ""
    printf "  %-12s  minimax-cli, codegraph, openclaude, mistral-vibe\n" ""
    printf "  \033[1m%-12s\033[0m neovim, nvchad\n" "editor"
    printf "  \033[1m%-12s\033[0m zsh, starship, oh-my-zsh, sgpt\n" "shell"
    printf "  \033[1m%-12s\033[0m gh, bat, eza, lazygit, jq, fzf, gum, curl, git, wget\n" "tools"
    printf "  \033[1m%-12s\033[0m nodejs, python, rust, golang, perl, php, clang\n" "language"
    printf "  \033[1m%-12s\033[0m sqlite, postgresql, mariadb, mongodb\n" "db"
    printf "  \033[1m%-12s\033[0m typescript, pm2, nodemon\n" "node"
    printf "  \033[1m%-12s\033[0m termux-styling, nerd-fonts, banner\n" "ui"
    printf "  \033[1m%-12s\033[0m n8n\n" "automation"
}

# ── list_agents: lista agentes y su estado ─────────
list_agents() {
    if [ ${#AGENTS[@]} -eq 0 ]; then
        log_info "No hay agentes registrados en $NEXUS_MODULES_DIR"
        return 0
    fi

    if [ "$NEXUS_GUM_AVAILABLE" = "true" ]; then
        # ── Header ──
        printf '  \033[1m%-15s %-14s %s\033[0m\n' "Nombre" "Estado" "Descripcion"
        printf '  \033[2m'; printf '%59s' '' | tr ' ' '-'; printf '\033[0m\n'

        for _name in "${AGENT_ORDER[@]}"; do
            local _dir="${AGENTS[$_name]}"
            local _meta="$_dir/metadata.sh"

            if [ -f "$_meta" ]; then
                # shellcheck source=/dev/null
                source "$_meta"
            fi

            # ── Three-state detection ─────────────────
            # 1. Manifest check: installed.txt (nxai-tracked)
            local _in_manifest=false
            if [ -f "${NEXUS_ROOT}/logs/installed.txt" ] && grep -Fx "$_name" "${NEXUS_ROOT}/logs/installed.txt" &>/dev/null; then
                _in_manifest=true
            fi

            # 2. Binary check: command -v or test.sh fallback
            local _in_path=false
            if [ -n "${AGENT_BINARY:-}" ] && command -v "$AGENT_BINARY" &>/dev/null; then
                _in_path=true
            elif [ -f "$_dir/test.sh" ] && bash "$_dir/test.sh" &>/dev/null; then
                _in_path=true
            fi

            # Status text and colors — ANSI codes go in printf FORMAT string,
            # plain text goes as arguments, so alignment is calculated correctly
            local _c_name _c_status _t_status
            if [ "$_in_manifest" = true ] && [ "$_in_path" = true ]; then
                _c_name='\033[96m'
                _c_status='\033[32m'
                _t_status="INSTALADO"
            elif [ "$_in_path" = true ]; then
                _c_name='\033[95m'
                _c_status='\033[36m'
                _t_status="EXTERNO"
            else
                _c_name='\033[97m'
                _c_status='\033[33m'
                _t_status="NO INSTALADO"
            fi

            # Truncate description to 35 chars
            local _desc="${AGENT_DESC:-}"
            if [ ${#_desc} -gt 35 ]; then
                _desc="${_desc:0:32}..."
            fi

            # ANSI codes in format string = alignment correct,
            # plain text args = no width miscalculation
            printf "  ${_c_name}%-15s\033[0m ${_c_status}%-14s\033[0m %s\n" \
                "${AGENT_NAME:-$_name}" "$_t_status" "$_desc"
        done
    else
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

            # ── Three-state detection ─────────────────
            local _in_manifest=false
            if [ -f "${NEXUS_ROOT}/logs/installed.txt" ] && grep -Fx "$_name" "${NEXUS_ROOT}/logs/installed.txt" &>/dev/null; then
                _in_manifest=true
            fi

            local _in_path=false
            if [ -n "${AGENT_BINARY:-}" ] && command -v "$AGENT_BINARY" &>/dev/null; then
                _in_path=true
            elif [ -f "$_dir/test.sh" ] && bash "$_dir/test.sh" &>/dev/null; then
                _in_path=true
            fi

            if [ "$_in_manifest" = true ] && [ "$_in_path" = true ]; then
                _status="${NEXUS_COLOR_GREEN}[INSTALADO]${NEXUS_COLOR_RESET}"
            elif [ "$_in_path" = true ]; then
                _status="${NEXUS_COLOR_CYAN}[EXTERNO]${NEXUS_COLOR_RESET}"
            else
                _status="${NEXUS_COLOR_YELLOW}[NO INSTALADO]${NEXUS_COLOR_RESET}"
            fi

            echo -e "  ${AGENT_NAME:-$_name} (Tier ${AGENT_TIER:-?}) $_status"
            if [ -n "${AGENT_DESC:-}" ]; then
                echo -e "    -> ${AGENT_DESC}"
            fi
        done
        unset _name _dir _meta _status
    fi
}

# ── install_agent: instala uno o todos los agentes ─
install_agent() {
    local target="${1:-}"

    if [ "$target" = "--all" ] || [ -z "$target" ]; then
        log_info "Instalando todos los agentes..."
        for _name in "${AGENT_ORDER[@]}"; do
            local _dir="${AGENTS[$_name]}"
            if [ -f "$_dir/install.sh" ]; then
                # Stubs: ejecutar directamente para mostrar mensaje (gum spin oculta output)
                local _method
                _method=$(sed -n 's/^export AGENT_METHOD="\(.*\)"/\1/p' "$_dir/metadata.sh" 2>/dev/null || echo "")
                if [ "$_method" = "stub" ]; then
                    bash "$_dir/install.sh"
                elif [ "$NEXUS_GUM_AVAILABLE" = "true" ]; then
                    gum spin --spinner dot --title "Instalando ${_name}..." -- env \
                        NEXUS_ROOT="$NEXUS_ROOT" \
                        NEXUS_ENV="$NEXUS_ENV" \
                        NEXUS_TERMUX_ACCESSIBLE="${NEXUS_TERMUX_ACCESSIBLE:-}" \
                        TERMUX_PREFIX="${TERMUX_PREFIX:-}" \
                        TERMUX_BIN="${TERMUX_BIN:-}" \
                        TERMUX_PIP="${TERMUX_PIP:-}" \
                        TERMUX_PKG="${TERMUX_PKG:-}" \
                        PREFIX="${PREFIX:-}" \
                        PATH="${PATH:-}" \
                        TMPDIR="${TMPDIR:-}" \
                        HOME="${HOME:-}" \
                        bash "$_dir/install.sh" || { log_warn "Fallo al instalar $_name"; continue; }
                else
                    log_info "Instalando $_name..."
                    # shellcheck source=/dev/null
                    (source "$_dir/install.sh") || log_warn "Fallo al instalar $_name"
                fi
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

    # Per-agent install with optional gum confirm+spin
    # Stubs: detectar para evitar gum spin que oculta el output
    local _method
    _method=$(sed -n 's/^export AGENT_METHOD="\(.*\)"/\1/p' "$_dir/metadata.sh" 2>/dev/null || echo "")

    if [ "$_method" = "stub" ]; then
        # Stub: ejecutar install.sh directamente para mostrar mensaje al usuario
        if [ -f "$_dir/install.sh" ]; then
            bash "$_dir/install.sh"
        else
            log_warn "$target no tiene install.sh"
        fi
    elif [ "$NEXUS_GUM_AVAILABLE" = "true" ] && [ -t 0 ]; then
        if [ -f "$_dir/install.sh" ]; then
            if gum spin --spinner dot --title "Instalando ${target}..." -- env \
                NEXUS_ROOT="$NEXUS_ROOT" \
                NEXUS_ENV="$NEXUS_ENV" \
                NEXUS_TERMUX_ACCESSIBLE="${NEXUS_TERMUX_ACCESSIBLE:-}" \
                TERMUX_PREFIX="${TERMUX_PREFIX:-}" \
                TERMUX_BIN="${TERMUX_BIN:-}" \
                TERMUX_PIP="${TERMUX_PIP:-}" \
                TERMUX_PKG="${TERMUX_PKG:-}" \
                PREFIX="${PREFIX:-}" \
                PATH="${PATH:-}" \
                TMPDIR="${TMPDIR:-}" \
                HOME="${HOME:-}" \
                bash "$_dir/install.sh"; then
                gum style --foreground 42 "[OK] ${target} instalado correctamente" 2>/dev/null
            else
                gum style --foreground 196 "[ERROR] Fallo al instalar ${target}" 2>/dev/null
                return 1
            fi
        else
            log_warn "$target no tiene install.sh"
        fi
    else
        if [ -f "$_dir/install.sh" ]; then
            log_info "Instalando $target..."
            # shellcheck source=/dev/null
            (source "$_dir/install.sh")
        else
            log_warn "$target no tiene install.sh"
        fi
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

    # Gum confirm (mandatory when interactive + gum available)
    if [ "$NEXUS_GUM_AVAILABLE" = "true" ] && [ -t 0 ]; then
        gum confirm "Eliminar ${target}?" || { log_info "Eliminacion cancelada"; return 0; }
        # Wrap removal in gum spin with TERMUX env passthrough
        if gum spin --spinner dot --title "Eliminando ${target}..." -- env \
            NEXUS_ROOT="$NEXUS_ROOT" \
            NEXUS_ENV="$NEXUS_ENV" \
            NEXUS_TERMUX_ACCESSIBLE="${NEXUS_TERMUX_ACCESSIBLE:-}" \
            TERMUX_PREFIX="${TERMUX_PREFIX:-}" \
            TERMUX_BIN="${TERMUX_BIN:-}" \
            TERMUX_PIP="${TERMUX_PIP:-}" \
            TERMUX_PKG="${TERMUX_PKG:-}" \
            bash -c "
                source \"\$NEXUS_ROOT/config/env.sh\"
                source \"\$NEXUS_ROOT/lib/nexus-install.sh\"
                source '$_dir/metadata.sh' 2>/dev/null
                _pkg=\"\${AGENT_PACKAGE:-\$AGENT_NAME}\"
                case \"\${AGENT_METHOD:-}\" in
                    pip)  uninstall_via_pip \"\$_pkg\" ;;
                    npm)  uninstall_via_npm \"\$_pkg\" ;;
                    pkg)  uninstall_via_apt \"\$_pkg\" ;;
                    apt)  uninstall_via_apt \"\$_pkg\" ;;
                    git)
                        echo \"[INFO] Agente instalado via git. Elimina el directorio clonado manualmente.\"
                        ;;
                    stub)
                        echo \"[INFO] Agente stub — no requiere desinstalacion. Elimina el binario manualmente si lo instalaste.\"
                        ;;
                    curl|cargo|binary)
                        if [ -n \"\${AGENT_BINARY:-}\" ] && command -v \"\$AGENT_BINARY\" &>/dev/null; then
                            rm -f \"\$(command -v \"\$AGENT_BINARY\")\" 2>/dev/null || true
                        fi ;;
                    *)
                        if [ -n \"\${AGENT_BINARY:-}\" ] && command -v \"\$AGENT_BINARY\" &>/dev/null; then
                            echo \"[INFO] Metodo '\${AGENT_METHOD:-}' sin desinstalador. Eliminando binario...\"
                            rm -f \"\$(command -v \"\$AGENT_BINARY\")\" 2>/dev/null || true
                        else
                            echo \"[INFO] No se encontro binario ni desinstalador para '\${AGENT_METHOD:-}'.\"
                        fi ;;
                esac
            "; then
            mark_removed "$target"
            gum style --foreground 42 "✓ Agente '${target}' desinstalado." 2>/dev/null
        else
            gum style --foreground 196 "✗ Error al desinstalar '${target}'" 2>/dev/null
        fi
    else
        case "${AGENT_METHOD:-}" in
            pip)
                uninstall_via_pip "$_pkg"
                ;;
            npm)
                uninstall_via_npm "$_pkg"
                ;;
            pkg)
                uninstall_via_apt "$_pkg"
                ;;
            apt)
                uninstall_via_apt "$_pkg"
                ;;
            git)
                log_info "Agente instalado via git. Elimina el directorio clonado manualmente."
                ;;
            stub)
                log_info "Agente stub — no requiere desinstalacion."
                log_info "Elimina el binario manualmente si lo instalaste."
                ;;
            curl|cargo|binary)
                if [ -n "${AGENT_BINARY:-}" ] && command -v "$AGENT_BINARY" &>/dev/null; then
                    rm -f "$(command -v "$AGENT_BINARY")" 2>/dev/null || true
                fi
                ;;
            *)
                log_warn "Metodo '$AGENT_METHOD' no tiene desinstalador automatico."
                if [ -n "${AGENT_BINARY:-}" ] && command -v "$AGENT_BINARY" &>/dev/null; then
                    log_info "Eliminando binario $AGENT_BINARY..."
                    rm -f "$(command -v "$AGENT_BINARY")" 2>/dev/null || true
                fi
                ;;
        esac
        mark_removed "$target"
        log_ok "Agente '$target' desinstalado."
    fi
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

    # NOTA: no usar gum spin — no hereda env vars en Termux.
    # Ejecucion directa con env PATH="$PATH" garantiza que
    # ~/.local/bin y paths de Termux esten disponibles.
    local _exit_code=0
    local _start_time _end_time _elapsed
    _start_time=$(date +%s)

    if [ "$NEXUS_GUM_AVAILABLE" = "true" ]; then
        printf "  Probando %s... " "$_test_name" >&2
    fi

    timeout 10 env PATH="$PATH" bash "$_test_sh" 2>/dev/null || _exit_code=$?

    _end_time=$(date +%s)
    _elapsed=$(( _end_time - _start_time ))

    if [ "$NEXUS_GUM_AVAILABLE" = "true" ]; then
        if [ "$_exit_code" -eq 124 ]; then
            gum style --foreground 196 "TIMEOUT (>10s)" 2>/dev/null
        elif [ "$_exit_code" -eq 0 ]; then
            gum style --foreground 42 "PASS (${_elapsed}.0s)" 2>/dev/null
        else
            gum style --foreground 196 "FAIL (${_elapsed}.0s)" 2>/dev/null
        fi
    else
        if [ "$_exit_code" -eq 124 ]; then
            log_error "$_test_name: TIMEOUT (>10s)"
        elif [ "$_exit_code" -eq 0 ]; then
            log_ok "$_test_name: PASS (${_elapsed}.0s)"
        else
            log_error "$_test_name: FAIL (${_elapsed}.0s)"
        fi
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

    local _info
    _info="=== Estado del Sistema NEXUS AI ===
Version:      ${NEXUS_VERSION}
Entorno:      ${NEXUS_ENV}
Arquitectura: ${NEXUS_ARCH}
Directorio:   ${NEXUS_ROOT}
Agentes:      ${installed_count}/${agent_count} instalados
Language:     ${NEXUS_LANG}

Modulos cargados:
  env.sh    -> ${NEXUS_ROOT}/config/env.sh
  registry  -> ${NEXUS_REGISTRY}
  log       -> ${NEXUS_ROOT}/lib/nexus-log.sh
  install   -> ${NEXUS_ROOT}/lib/nexus-install.sh
  update    -> ${NEXUS_ROOT}/lib/nexus-update.sh"

    if [ "$NEXUS_GUM_AVAILABLE" = "true" ]; then
        echo "$_info" | gum style --border rounded --padding "1 2" 2>/dev/null
    else
        echo "$_info"
    fi
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
        show_banner
        check_update_silent
        install_agent "$@"
        ;;
    remove)
        show_banner
        check_update_silent
        remove_agent "$@"
        ;;
    list)
        show_banner
        check_update_silent
        list_agents
        ;;
    status)
        show_banner
        check_update_silent
        system_status
        ;;
    agent)
        show_banner
        check_update_silent
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
        show_banner
        check_update_silent
        log_error "No implementado aun. Fase 5."
        ;;
    update)
        show_banner
        check_update_silent
        case "${1:-}" in
            --check|-c)
                check_update_verbose
                ;;
            *)
                apply_update
                ;;
        esac
        ;;
    guide)
        show_banner
        check_update_silent
        case "${1:-}" in
            --interactive|-i)
                show_guide_rich --interactive
                ;;
            ai|editor|shell|tools|language|db|node|ui|automation)
                show_guide_category "$1"
                ;;
            "")
                show_guide
                ;;
            *)
                echo "Categoria desconocida: $1"
                echo "Uso: nxai guide [categoria|--interactive]"
                echo "Categorias: ai, editor, shell, tools, language, db, node, ui, automation"
                exit 1
                ;;
        esac
        ;;
    help|--help|"")
        show_banner
        show_help
        ;;
    *)
        show_banner
        check_update_silent
        log_error "Comando desconocido: ${COMMAND}"
        echo ""
        show_help
        exit 1
        ;;
esac
