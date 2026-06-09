#!/usr/bin/env bash
# NEXUS AI — lib/nexus-log.sh
# Funciones de salida con formato [OK]/[WARN]/[ERROR]/[INFO]
# Version: 0.1.0
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

# ── show_banner: muestra el banner de NEXUS AI ────
show_banner() {
    echo -e "\n\033[96m _   _ ________   ___    _  _____            _____"
    echo -e "| \ | |  ____\ \ / / |  | |/ ____|     /\   |_   _|"
    echo -e "|  \| | |__   \ V /| |  | | (___      /  \    | |"
    echo -e "| . \` | |__   > < | |  | |\___ \    / /\ \   | |"
    echo -e "| |\  | |____ / . \| |__| |____) |  / ____ \ _| |_"
    echo -e "|_| \_|______/_/ \_\\\\____/|_____/  /_/    \_\_____|"
    if [ "$NEXUS_GUM_AVAILABLE" = "true" ]; then
        echo "by GUIGERDTS" | gum style --foreground 245 2>/dev/null
    else
        echo -e "\033[1;37mby GUIGERDTS\033[0m"
    fi
    echo -e "\033[0m"
}

