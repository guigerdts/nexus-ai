#!/usr/bin/env bash
# NEXUS AI — lib/nexus-log.sh
# Funciones de salida: log_ok/log_warn/log_error/log_info, show_banner, show_system_bars
# Version: 0.1.1
#
# Colores desde config/env.sh (NEXUS_COLOR_*).
# Solo se emiten codigos ANSI cuando la salida es un terminal ([ -t 1 ]).
# En pipas (pipes) no se usan codigos ANSI.

# ── Formato de salida ─────────────────────────────
# text (default): [OK] mensaje (con colores en TTY)
# json: {"timestamp":"ISO8601","level":"OK","message":"..."}
export NEXUS_LOG_FORMAT="${NEXUS_LOG_FORMAT:-text}"

# ── _nexus_log_json: emite JSON estructurado ──────
# Uso: _nexus_log_json "LEVEL" "mensaje"
_nexus_log_json() {
    local _level="$1"
    shift
    local _timestamp
    _timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    local _message="$*"

    # JSON escaping basico
    _message="${_message//\\/\\\\}"
    _message="${_message//\"/\\\"}"

    printf '{"timestamp":"%s","level":"%s","message":"%s"}\n' \
        "$_timestamp" "$_level" "$_message"
}

# ── log_ok: [OK] mensaje ──────────────────────────
log_ok() {
    if [ "${NEXUS_LOG_FORMAT:-text}" = "json" ]; then
        _nexus_log_json "OK" "$*"
    elif [ -t 1 ]; then
        echo -e "${NEXUS_COLOR_CYAN}[OK]${NEXUS_COLOR_RESET} $*"
    else
        echo "[OK] $*"
    fi
}

# ── log_warn: [WARN] mensaje ──────────────────────
log_warn() {
    if [ "${NEXUS_LOG_FORMAT:-text}" = "json" ]; then
        _nexus_log_json "WARN" "$*"
    elif [ -t 1 ]; then
        echo -e "${NEXUS_COLOR_YELLOW}[WARN]${NEXUS_COLOR_RESET} $*"
    else
        echo "[WARN] $*"
    fi
}

# ── log_error: [ERROR] mensaje ────────────────────
log_error() {
    if [ "${NEXUS_LOG_FORMAT:-text}" = "json" ]; then
        _nexus_log_json "ERROR" "$*"
    elif [ -t 1 ]; then
        echo -e "${NEXUS_COLOR_RED}[ERROR]${NEXUS_COLOR_RESET} $*"
    else
        echo "[ERROR] $*"
    fi
}

# ── log_info: [INFO] mensaje ──────────────────────
log_info() {
    if [ "${NEXUS_LOG_FORMAT:-text}" = "json" ]; then
        _nexus_log_json "INFO" "$*"
    elif [ -t 1 ]; then
        echo -e "${NEXUS_COLOR_CYAN}[INFO]${NEXUS_COLOR_RESET} $*"
    else
        echo "[INFO] $*"
    fi
}

# ── log_fatal: error critico con banner figlet ────
# Uso: log_fatal "mensaje de error"
# Imprime "ERROR" en figlet rojo + mensaje, luego exit 1
# Reservado exclusivamente para fallos catastróficos (no para warnings)
log_fatal() {
    local _msg="$*"
    if [ -t 1 ]; then
        declare -f figlet_render >/dev/null && figlet_render "ERROR" 91 "" "" "" 30 50
    fi
    echo -e "\033[1;91m[FATAL]\033[0m $_msg" >&2
    exit 1
}

# ── show_banner: muestra el banner de NEXUS AI ────
show_banner() {
    if [ -t 1 ]; then
        if [ "$NEXUS_GUM_AVAILABLE" = "true" ]; then
            local _pad="" _cols _banner_width=51 _pad_len
            _cols=$(tput cols 2>/dev/null || echo 80)
            _pad_len=$(( (_cols - _banner_width) / 2 ))
            [ "$_pad_len" -gt 0 ] && _pad=$(printf '%*s' "$_pad_len" '')
            echo -e "\n${_pad}\033[96m _   _ ________   ___    _  _____            _____"
            echo -e "${_pad}| \ | |  ____\ \ / / |  | |/ ____|     /\   |_   _|"
            echo -e "${_pad}|  \| | |__   \ V /| |  | | (___      /  \    | |"
            echo -e "${_pad}| . \` | |__   > < | |  | |\___ \    / /\ \   | |"
            echo -e "${_pad}| |\  | |____ / . \| |__| |____) |  / ____ \ _| |_"
            echo -e "${_pad}|_| \_|______/_/ \_\\____/|_____/  /_/    \_\_____|"
            echo "by GUIGERDTS" | gum style --foreground 245 --align center --width "$_cols" 2>/dev/null
            echo -e "\033[0m"
        else
            echo -e "\n\033[96m _   _ ________   ___    _  _____            _____"
            echo -e "| \ | |  ____\ \ / / |  | |/ ____|     /\   |_   _|"
            echo -e "|  \| | |__   \ V /| |  | | (___      /  \    | |"
            echo -e "| . \` | |__   > < | |  | |\___ \    / /\ \   | |"
            echo -e "| |\  | |____ / . \| |__| |____) |  / ____ \ _| |_"
            echo -e "|_| \_|______/_/ \_\\____/|_____/  /_/    \_\_____|"
            echo -e "\033[1;37mby GUIGERDTS\033[0m"
            echo -e "\033[0m"
        fi
    else
        echo "NEXUS AI v${NEXUS_VERSION:-0.8.0}"
    fi
}

# ── show_system_bars: barras de RAM y disco ───────
show_system_bars() {
    local _ram_total _ram_avail _ram_usage _disk_usage
    local _bar_len=30 _pct

    # RAM desde /proc/meminfo
    _ram_total=$(awk '/MemTotal/ {print $2}' /proc/meminfo 2>/dev/null)
    _ram_avail=$(awk '/MemAvailable/ {print $2}' /proc/meminfo 2>/dev/null)
    if [ -n "$_ram_total" ] && [ -n "$_ram_avail" ] && [ "$_ram_total" -gt 0 ]; then
        _ram_usage=$(( 100 * (_ram_total - _ram_avail) / _ram_total ))
    else
        _ram_usage=0
    fi

    # Disco desde df $HOME
    _disk_usage=$(df "$HOME" 2>/dev/null | awk 'NR==2 {print $5}' | tr -d '%')
    _disk_usage=${_disk_usage:-0}

    # Delegar a _ui_build_bar (lib/nexus-ui.sh)
    # Si la lib no esta cargada (motd standalone), usar fallback inline
    if ! command -v _ui_build_bar &>/dev/null && [ -f "${NEXUS_ROOT:-}/lib/nexus-ui.sh" ]; then
        # shellcheck source=lib/nexus-ui.sh
        source "${NEXUS_ROOT}/lib/nexus-ui.sh" 2>/dev/null || true
    fi

    local _ram_bar _disk_bar
    if command -v _ui_build_bar &>/dev/null; then
        _ram_bar=$(_ui_build_bar "$_ram_usage" 100 "$_bar_len")
        _disk_bar=$(_ui_build_bar "$_disk_usage" 100 "$_bar_len")
    else
        # Fallback simple sin color thresholds
        _ram_bar="$_ram_usage%"
        _disk_bar="$_disk_usage%"
    fi

    if [ "$NEXUS_GUM_AVAILABLE" = "true" ] && [ -t 1 ]; then
        local _cols _bw _inner _i
        _cols=$(tput cols 2>/dev/null || echo 80)
        _bw=$(( _cols - 2 ))      # ancho total del cuadro (╭ a ╮)
        [ "$_bw" -lt 52 ] && _bw=52
        [ "$_bw" -gt 68 ] && _bw=68
        _inner=$(( _bw - 2 ))      # espacio entre │ y │

        # ── Borde superior ──
        printf '\033[38;5;51m╭'
        for ((_i=0; _i<_inner; _i++)); do printf '─'; done
        printf '╮\033[0m\n'

        # ── Linea en blanco ──
        printf '\033[38;5;51m│\033[0m%*s\033[38;5;51m│\033[0m\n' "$_inner" ''

        # ── Titulo ──
        printf '\033[38;5;51m│\033[0m  \033[1mSistema\033[0m%*s\033[38;5;51m│\033[0m\n' \
            $((_inner - 9)) ''

        # ── Linea en blanco ──
        printf '\033[38;5;51m│\033[0m%*s\033[38;5;51m│\033[0m\n' "$_inner" ''

        # ── RAM ──
        printf '\033[38;5;51m│\033[0m  RAM:  %s %d%%%*s\033[38;5;51m│\033[0m\n' \
            "$_ram_bar" "$_ram_usage" \
            $((_inner - 8 - _bar_len - 1 - ${#_ram_usage} - 1)) ''

        # ── DISK ──
        printf '\033[38;5;51m│\033[0m  DISK: %s %d%%%*s\033[38;5;51m│\033[0m\n' \
            "$_disk_bar" "$_disk_usage" \
            $((_inner - 8 - _bar_len - 1 - ${#_disk_usage} - 1)) ''

        # ── Linea en blanco ──
        printf '\033[38;5;51m│\033[0m%*s\033[38;5;51m│\033[0m\n' "$_inner" ''

        # ── Borde inferior ──
        printf '\033[38;5;51m╰'
        for ((_i=0; _i<_inner; _i++)); do printf '─'; done
        printf '╯\033[0m\n'
    else
        echo ""
        printf '\033[1mSistema\033[0m\n'
        printf 'RAM:  %s %d%%\n' "$_ram_bar" "$_ram_usage"
        printf 'DISK: %s %d%%\n' "$_disk_bar" "$_disk_usage"
        echo ""
    fi
}

