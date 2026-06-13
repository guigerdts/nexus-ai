#!/usr/bin/env bash
# NEXUS AI — lib/nexus-ui.sh
# UI toolkit: spinner, progress bar, table, box, confirm
# Version: 0.8.2
#
# Dependencias: NEXUS_COLOR_* vars de config/env.sh (via nexus_require)
#              gum (opcional — fallback nativo cuando no esta disponible)

set -euo pipefail

# ── Config ────────────────────────────────────────
_UI_SPINNER_FRAMES=('/' '\\' '|' '—' '\\' '/')
_UI_SPINNER_DELAY=0.15
_UI_BAR_WIDTH=20

# ── _ui_is_pipe: detecta si stdout NO es terminal ──
_ui_is_pipe() {
    [ ! -t 1 ]
}

# ── _ui_build_bar: construye barra de progreso ANSI ──
# Uso: _ui_build_bar <current> <total> [width]
_ui_build_bar() {
    local _cur="${1:-0}"
    local _total="${2:-100}"
    local _width="${3:-$_UI_BAR_WIDTH}"
    local _pct=0

    if [ "$_total" -gt 0 ]; then
        _pct=$(( _cur * 100 / _total ))
    fi

    local _filled=$(( _cur * _width / _total ))
    [ "$_filled" -gt "$_width" ] && _filled="$_width"

    local _bar=""
    local _i=0
    for ((_i=0; _i<_filled; _i++)); do
        _bar="${_bar}█"
    done
    for ((_i=_filled; _i<_width; _i++)); do
        _bar="${_bar}░"
    done

    echo "${NEXUS_COLOR_CYAN:-}[${_bar}]${NEXUS_COLOR_RESET:-} ${_pct}%%"
}

# ── Public API ─────────────────────────────────────

# ── ui_spinner_start: inicia spinner animado ──
# Uso: ui_spinner_start <label>
ui_spinner_start() {
    local _label="${1:-}"

    if _ui_is_pipe; then
        [ -n "$_label" ] && echo "$_label..."
        return 0
    fi

    # Delegar a gum si esta disponible
    if command -v gum &>/dev/null; then
        gum spin --spinner dot --title "$_label" -- sleep 9999 &
    else
        # Native bash spinner
        (
            local _frame_idx=0
            while true; do
                local _frame="${_UI_SPINNER_FRAMES[$_frame_idx]}"
                printf "\r${NEXUS_COLOR_CYAN}%s${NEXUS_COLOR_RESET} %s" "$_frame" "$_label"
                _frame_idx=$(( (_frame_idx + 1) % ${#_UI_SPINNER_FRAMES[@]} ))
                sleep "$_UI_SPINNER_DELAY"
            done
        ) &
    fi

    _UI_SPINNER_PID=$!
}

# ── ui_spinner_stop: detiene spinner con resultado ──
# Uso: ui_spinner_stop <ok|fail> [mensaje]
ui_spinner_stop() {
    local _result="${1:-ok}"
    local _msg="${2:-}"

    # Matar spinner si existe
    if [ -n "${_UI_SPINNER_PID:-}" ]; then
        kill "$_UI_SPINNER_PID" 2>/dev/null || true
        wait "$_UI_SPINNER_PID" 2>/dev/null || true
        unset _UI_SPINNER_PID
    fi

    if _ui_is_pipe; then
        [ -n "$_msg" ] && echo "$_msg"
        return 0
    fi

    printf "\r"

    case "$_result" in
        ok)
            echo -e "${NEXUS_COLOR_GREEN}✓${NEXUS_COLOR_RESET} ${_msg}"
            ;;
        fail)
            echo -e "${NEXUS_COLOR_RED}✗${NEXUS_COLOR_RESET} ${_msg}"
            ;;
        warn)
            echo -e "${NEXUS_COLOR_YELLOW}⚠${NEXUS_COLOR_RESET} ${_msg}"
            ;;
        *)
            echo -e "${NEXUS_COLOR_GRAY}•${NEXUS_COLOR_RESET} ${_msg}"
            ;;
    esac
}

# ── ui_progress_bar: muestra barra de progreso ──
# Uso: ui_progress_bar <current> <total> [label]
ui_progress_bar() {
    local _cur="${1:-0}"
    local _total="${2:-100}"
    local _label="${3:-}"

    if _ui_is_pipe; then
        [ -n "$_label" ] && echo "$_label: $_cur/$_total"
        return 0
    fi

    local _bar
    _bar="$(_ui_build_bar "$_cur" "$_total")"

    if [ -n "$_label" ]; then
        printf "\r%s %s" "$_label" "$_bar"
    else
        printf "\r%s" "$_bar"
    fi

    if [ "$_cur" -ge "$_total" ]; then
        echo ""
    fi
}

# ── ui_table: renderiza tabla con columnas ──
# Uso: ui_table --header "Col1" "Col2" ... [--row "v1" "v2" ...]...
ui_table() {
    local -a _headers=()
    local -a _rows=()
    local _section=""

    # Parse args
    while [ $# -gt 0 ]; do
        case "$1" in
            --header)
                _section="header"
                shift
                ;;
            --row)
                _section="row"
                shift
                ;;
            *)
                case "$_section" in
                    header) _headers+=("$1") ;;
                    row)    _rows+=("$1") ;;
                esac
                shift
                ;;
        esac
    done

    # No columns → nothing to render
    if [ ${#_headers[@]} -eq 0 ]; then
        return 0
    fi

    local _cols=${#_headers[@]}

    # Pipe mode: simple output
    if _ui_is_pipe; then
        local _sep=" | "
        echo "${_headers[*]}"
        echo "${_headers[*]}" | sed 's/[^|]/-/g'
        for _row in "${_rows[@]}"; do
            echo "$_row"
        done
        return 0
    fi

    # Calculate max width per column from headers + rows
    local -a _widths=()
    local _c=0
    for ((_c=0; _c<_cols; _c++)); do
        _widths[_c]=${#_headers[_c]}
    done

    for _row in "${_rows[@]}"; do
        IFS='|' read -ra _fields <<< "$_row"
        for ((_c=0; _c<_cols; _c++)); do
            local _len=${#_fields[_c]}
            [ "${_widths[_c]:-0}" -lt "$_len" ] && _widths[_c]=$_len
        done
    done

    # Render header
    local _line=""
    for ((_c=0; _c<_cols; _c++)); do
        local _hdr="${_headers[_c]}"
        printf -v _padded "%-${_widths[_c]}s" "$_hdr"
        _line="${_line} ${NEXUS_COLOR_CYAN}${_padded}${NEXUS_COLOR_RESET}"
        [ "$(( _c + 1 ))" -lt "$_cols" ] && _line="${_line} │"
    done
    echo "$_line"

    # Separator
    _line=""
    for ((_c=0; _c<_cols; _c++)); do
        local _dashes=""
        printf -v _dashes '%*s' "${_widths[_c]}" ''
        _dashes="${_dashes// /─}"
        _line="${_line}${NEXUS_COLOR_GRAY}${_dashes}${NEXUS_COLOR_RESET}"
        [ "$(( _c + 1 ))" -lt "$_cols" ] && _line="${_line}─┼─"
    done
    echo "$_line"

    # Render rows
    for _row in "${_rows[@]}"; do
        IFS='|' read -ra _fields <<< "$_row"
        _line=""
        for ((_c=0; _c<_cols; _c++)); do
            local _val="${_fields[_c]:-}"
            printf -v _padded "%-${_widths[_c]}s" "$_val"
            _line="${_line} ${_padded}"
            [ "$(( _c + 1 ))" -lt "$_cols" ] && _line="${_line} │"
        done
        echo "$_line"
    done
}

# ── ui_box: dibuja caja con bordes ──
# Uso: ui_box <title> [content]
ui_box() {
    local _title="${1:-}"
    local _content="${2:-}"

    if _ui_is_pipe; then
        [ -n "$_title" ] && echo "=== $_title ==="
        [ -n "$_content" ] && echo "$_content"
        return 0
    fi

    local _color="${NEXUS_COLOR_PRIMARY:-${NEXUS_COLOR_CYAN:-}}"
    local _reset="${NEXUS_COLOR_RESET:-}"

    # Calcular ancho
    local _max_width=60
    local _title_len=0
    [ -n "$_title" ] && _title_len=${#_title}

    local _content_width=0
    if [ -n "$_content" ]; then
        while IFS= read -r _cl; do
            local _cl_len=${#_cl}
            [ "$_cl_len" -gt "$_content_width" ] && _content_width=$_cl_len
        done <<< "$_content"
    fi

    local _box_width=$(( _title_len > _content_width ? _title_len : _content_width ))
    _box_width=$(( _box_width + 4 ))  # padding
    [ "$_box_width" -gt "$_max_width" ] && _box_width="$_max_width"
    [ "$_box_width" -lt 20 ] && _box_width=20

    # Top border
    echo -e "${_color}╭─ ${_title} ${_color}"
    printf '%*s' "$(( _box_width - _title_len - 3 ))" '' | tr ' ' '─'
    echo -e "${_reset}"

    # Content
    if [ -n "$_content" ]; then
        while IFS= read -r _cl; do
            echo -e "${_color}│${_reset} ${_cl}"
        done <<< "$_content"
    fi

    # Bottom border
    echo -e "${_color}╰─${_reset}"
}

# ── ui_confirm: prompt de confirmacion ──
# Uso: ui_confirm "Mensaje"  # returns 0 (yes) / 1 (no)
ui_confirm() {
    local _msg="${1:-¿Continuar?}"

    if _ui_is_pipe; then
        echo "$_msg [y/N]"
        return 1  # default no en pipe
    fi

    echo -e "${NEXUS_COLOR_YELLOW}?${NEXUS_COLOR_RESET} $_msg ${NEXUS_COLOR_GRAY}[y/N]${NEXUS_COLOR_RESET} "
    read -r _resp || true
    case "${_resp:-}" in
        y|Y|s|S|yes|YES)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}
