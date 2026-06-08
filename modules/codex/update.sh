#!/usr/bin/env bash
# modules/codex/update.sh
# Actualiza codex a la version mas reciente
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/nexus-install.sh" 2>/dev/null || {
    echo "[ERROR] nexus-install.sh no encontrado"
    exit 1
}
source "$SCRIPT_DIR/metadata.sh" 2>/dev/null || true

log_info "Verificando actualizacion para ${AGENT_NAME:-codex}..."

if ! command -v npm &>/dev/null; then
    log_error "npm no disponible"
    exit 1
fi

if [ "${NEXUS_ENV:-}" = "termux" ]; then
    _pkg="@mmmbuto/codex-cli-termux"
else
    _pkg="@openai/codex"
fi

if npm outdated -g "$_pkg" 2>/dev/null | grep -q "$_pkg"; then
    log_info "Nueva version disponible. Actualizando..."
    npm update -g "$_pkg" 2>/dev/null || npm install -g "$_pkg"@latest 2>/dev/null || {
        log_warn "Fallo la actualizacion via npm, reintentando con install.sh..."
        (source "$SCRIPT_DIR/install.sh")
    }
    mark_installed "$AGENT_NAME"
    log_ok "${AGENT_NAME} actualizado correctamente."
else
    log_ok "${AGENT_NAME} ya esta en la ultima version."
fi

exit 0
