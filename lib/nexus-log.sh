#!/usr/bin/env bash
# NEXUS AI — lib/nexus-log.sh
# Funciones de salida con formato [OK]/[WARN]/[ERROR]/[INFO]
# Version: 0.1.0
#
# Colores solo cuando la salida es un terminal ([ -t 1 ]).
# En pipas (pipes) no se usan codigos ANSI.

# ── Constantes de color ────────────────────────────
if [ -t 1 ]; then
    _NEXUS_CYAN='\033[0;36m'
    _NEXUS_YELLOW='\033[0;33m'
    _NEXUS_RED='\033[0;31m'
    _NEXUS_RESET='\033[0m'
else
    _NEXUS_CYAN=''
    _NEXUS_YELLOW=''
    _NEXUS_RED=''
    _NEXUS_RESET=''
fi

# ── log_ok: [OK] mensaje ──────────────────────────
log_ok() {
    echo -e "${_NEXUS_CYAN}[OK]${_NEXUS_RESET} $*"
}

# ── log_warn: [WARN] mensaje ──────────────────────
log_warn() {
    echo -e "${_NEXUS_YELLOW}[WARN]${_NEXUS_RESET} $*"
}

# ── log_error: [ERROR] mensaje ────────────────────
log_error() {
    echo -e "${_NEXUS_RED}[ERROR]${_NEXUS_RESET} $*"
}

# ── log_info: [INFO] mensaje ──────────────────────
log_info() {
    echo -e "${_NEXUS_CYAN}[INFO]${_NEXUS_RESET} $*"
}
