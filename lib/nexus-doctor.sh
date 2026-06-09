#!/usr/bin/env bash
# NEXUS AI — lib/nexus-doctor.sh
# Diagnostico del sistema: checks de salud para NEXUS AI
# Version: 0.1.0
#
# Uso: nxai doctor
# Exit: 0 = todo OK, 1 = warnings, 2 = errores criticos

# ── Colores locales (independientes de nexus-log.sh) ──
_DOCTOR_COLOR_GREEN='\033[0;32m'
_DOCTOR_COLOR_YELLOW='\033[0;33m'
_DOCTOR_COLOR_RED='\033[0;31m'
_DOCTOR_COLOR_CYAN='\033[0;36m'
_DOCTOR_COLOR_GRAY='\033[0;37m'
_DOCTOR_COLOR_BOLD='\033[1m'
_DOCTOR_COLOR_RESET='\033[0m'

_DOCTOR_EXIT=0  # 0=pass, 1=warn, 2=critical

_DOCTOR_PASSED=0
_DOCTOR_WARNED=0
_DOCTOR_FAILED=0

# ── Helper: imprimir resultado con color ────────────
_doctor_result() {
    local _status="$1"   # PASS, WARN, FAIL
    local _check="$2"
    local _detail="$3"
    local _color

    case "$_status" in
        PASS) _color="$_DOCTOR_COLOR_GREEN" ;;
        WARN) _color="$_DOCTOR_COLOR_YELLOW" ;;
        FAIL) _color="$_DOCTOR_COLOR_RED" ;;
    esac

    if [ -t 1 ]; then
        printf "  ${_color}[%s]${_DOCTOR_COLOR_RESET} ${_DOCTOR_COLOR_BOLD}%-30s${_DOCTOR_COLOR_RESET} %s\n" \
            "$_status" "$_check" "$_detail"
    else
        printf "  [%s] %-30s %s\n" "$_status" "$_check" "$_detail"
    fi

    case "$_status" in
        PASS) _DOCTOR_PASSED=$((_DOCTOR_PASSED + 1)) ;;
        WARN) _DOCTOR_WARNED=$((_DOCTOR_WARNED + 1))
              [ "$_DOCTOR_EXIT" -lt 1 ] && _DOCTOR_EXIT=1 ;;
        FAIL) _DOCTOR_FAILED=$((_DOCTOR_FAILED + 1))
              _DOCTOR_EXIT=2 ;;
    esac
}

# ── doctor_check_permissions: escritura en directorios ──
doctor_check_permissions() {
    local _dirs=("$NEXUS_ROOT" "$NEXUS_ROOT/logs" "$NEXUS_ROOT/bin" "$NEXUS_ROOT/config")
    local _all_ok=true

    for _d in "${_dirs[@]}"; do
        if [ ! -d "$_d" ]; then
            _doctor_result "FAIL" "Directorio $_d" "No existe"
            _all_ok=false
        elif [ ! -w "$_d" ]; then
            _doctor_result "FAIL" "Directorio $_d" "Sin permiso de escritura"
            _all_ok=false
        fi
    done

    [ "$_all_ok" = true ] && _doctor_result "PASS" "Permisos de directorios" "Todos accesibles"
}

# ── doctor_check_connectivity: conexion a internet ──
doctor_check_connectivity() {
    if command -v curl &>/dev/null; then
        if curl -s --max-time 5 --connect-timeout 3 "https://api.github.com" &>/dev/null; then
            _doctor_result "PASS" "Conectividad" "GitHub API accesible"
        elif curl -s --max-time 5 --connect-timeout 3 "https://google.com" &>/dev/null; then
            _doctor_result "WARN" "Conectividad" "GitHub no accesible, pero hay internet"
        else
            _doctor_result "WARN" "Conectividad" "Sin acceso a internet"
        fi
    else
        _doctor_result "WARN" "Conectividad" "curl no disponible"
    fi
}

# ── doctor_check_termux_bindmounts: verificacion de bind-mounts ──
doctor_check_termux_bindmounts() {
    if [ "${NEXUS_ENV:-}" = "proot-ubuntu" ]; then
        if [ "${NEXUS_TERMUX_ACCESSIBLE:-false}" = "true" ]; then
            local _issues=""
            [ ! -d "${TERMUX_BIN:-}" ] && _issues="$_issues TERMUX_BIN no existe"
            [ ! -d "${TERMUX_PREFIX:-}" ] && _issues="$_issues TERMUX_PREFIX no existe"
            [ ! -x "${TERMUX_PKG:-}" ] && _issues="$_issues pkg no ejecutable"

            if [ -n "$_issues" ]; then
                _doctor_result "WARN" "Bind-mounts Termux" "${_issues# }"
            else
                _doctor_result "PASS" "Bind-mounts Termux" "Todos accesibles"
            fi
        else
            _doctor_result "WARN" "Bind-mounts Termux" "Termux no accesible via bind-mount"
        fi
    else
        _doctor_result "PASS" "Bind-mounts Termux" "No aplica (entorno: ${NEXUS_ENV:-linux})"
    fi
}

# ── doctor_check_disk_space: espacio en disco ──
doctor_check_disk_space() {
    if command -v df &>/dev/null; then
        local _avail_kb _avail_mb
        _avail_kb="$(df -k "$NEXUS_ROOT" 2>/dev/null | awk 'NR==2{print $4}')"
        if [ -n "$_avail_kb" ] && [ "$_avail_kb" -gt 0 ] 2>/dev/null; then
            _avail_mb=$(( _avail_kb / 1024 ))
            if [ "$_avail_mb" -lt 500 ]; then
                _doctor_result "WARN" "Espacio en disco" "${_avail_mb}MB disponible (< 500MB)"
            else
                _doctor_result "PASS" "Espacio en disco" "${_avail_mb}MB disponibles"
            fi
        else
            _doctor_result "WARN" "Espacio en disco" "No se pudo determinar"
        fi
    else
        _doctor_result "WARN" "Espacio en disco" "df no disponible"
    fi

    # Mostrar particion de datos
    if command -v df &>/dev/null && [ -d "/data/data/com.termux" ]; then
        local _data_avail
        _data_avail="$(df -h /data/data/com.termux 2>/dev/null | awk 'NR==2{print $4}')"
        [ -n "$_data_avail" ] && _doctor_result "PASS" "Particion datos (Termux)" "${_data_avail} libres"
    fi
}

# ── doctor_check_versions: versiones de herramientas criticas ──
doctor_check_versions() {
    local _tools=("bash" "curl" "git" "python3" "zsh" "node")

    for _tool in "${_tools[@]}"; do
        if command -v "$_tool" &>/dev/null; then
            local _ver
            case "$_tool" in
                bash) _ver="$(bash --version 2>/dev/null | head -1 | sed 's/.*version //;s/ .*//')" ;;
                curl) _ver="$(curl --version 2>/dev/null | head -1 | awk '{print $2}')" ;;
                git)  _ver="$(git --version 2>/dev/null | sed 's/git version //')" ;;
                python3) _ver="$(python3 --version 2>/dev/null | sed 's/Python //')" ;;
                zsh)  _ver="$(zsh --version 2>/dev/null | sed 's/zsh //;s/ .*//')" ;;
                node) _ver="$(node --version 2>/dev/null | sed 's/^v//')" ;;
            esac
            _doctor_result "PASS" "Version ${_tool}" "${_ver:-disponible}"
        else
            _doctor_result "WARN" "Version ${_tool}" "No instalado"
        fi
    done
}

# ── doctor_check_manifest: consistencia installed.txt vs PATH ──
doctor_check_manifest() {
    local _manifest="${NEXUS_ROOT}/logs/installed.txt"

    if [ ! -f "$_manifest" ]; then
        _doctor_result "PASS" "Manifest de instalacion" "Vacio (sin agentes instalados)"
        return 0
    fi

    local _total=0 _ok=0 _missing=0
    while IFS= read -r _agent; do
        [ -z "$_agent" ] && continue
        _total=$((_total + 1))

        # Obtener AGENT_BINARY del metadata
        local _meta="${NEXUS_ROOT}/modules/${_agent}/metadata.sh"
        local _binary=""
        [ -f "$_meta" ] && _binary="$(sed -n 's/^export AGENT_BINARY="\(.*\)"/\1/p' "$_meta" 2>/dev/null || true)"

        if [ -n "$_binary" ] && command -v "$_binary" &>/dev/null; then
            _ok=$((_ok + 1))
        elif [ -f "${NEXUS_ROOT}/modules/${_agent}/test.sh" ] && bash "${NEXUS_ROOT}/modules/${_agent}/test.sh" &>/dev/null; then
            _ok=$((_ok + 1))
        else
            _missing=$((_missing + 1))
            _doctor_result "WARN" "Agente faltante" "$_agent (binario no encontrado en PATH)"
        fi
    done < "$_manifest"

    if [ "$_missing" -eq 0 ]; then
        if [ "$_total" -gt 0 ]; then
            _doctor_result "PASS" "Manifest de instalacion" "${_ok}/${_total} agentes verificados"
        else
            _doctor_result "PASS" "Manifest de instalacion" "Vacio (sin agentes instalados)"
        fi
    else
        _doctor_result "WARN" "Manifest de instalacion" "${_missing}/${_total} agentes con binario faltante"
    fi
}

# ── doctor_run: funcion principal ──────────────────
doctor_run() {
    echo ""
    echo -e "${_DOCTOR_COLOR_CYAN}╔══════════════════════════════════════════════╗${_DOCTOR_COLOR_RESET}"
    echo -e "${_DOCTOR_COLOR_CYAN}║     NEXUS AI — Diagnostico del Sistema      ║${_DOCTOR_COLOR_RESET}"
    echo -e "${_DOCTOR_COLOR_CYAN}╚══════════════════════════════════════════════╝${_DOCTOR_COLOR_RESET}"
    echo ""

    # Resumen de entorno
    echo -e "  ${_DOCTOR_COLOR_GRAY}Entorno:${_DOCTOR_COLOR_RESET} ${NEXUS_ENV:-desconocido}"
    echo -e "  ${_DOCTOR_COLOR_GRAY}Version:${_DOCTOR_COLOR_RESET} ${NEXUS_VERSION:-?}"
    echo -e "  ${_DOCTOR_COLOR_GRAY}Directorio:${_DOCTOR_COLOR_RESET} ${NEXUS_ROOT:-?}"
    echo ""

    # Ejecutar checks
    doctor_check_permissions
    doctor_check_connectivity
    doctor_check_termux_bindmounts
    doctor_check_disk_space
    doctor_check_versions
    doctor_check_manifest

    # Resumen final
    echo ""
    echo -e "  ${_DOCTOR_COLOR_GRAY}Resumen:${_DOCTOR_COLOR_RESET} ${_DOCTOR_COLOR_GREEN}${_DOCTOR_PASSED} passed${_DOCTOR_COLOR_RESET}, ${_DOCTOR_COLOR_YELLOW}${_DOCTOR_WARNED} warnings${_DOCTOR_COLOR_RESET}, ${_DOCTOR_COLOR_RED}${_DOCTOR_FAILED} failed${_DOCTOR_COLOR_RESET}"
    echo ""

    return $_DOCTOR_EXIT
}
