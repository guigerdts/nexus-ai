#!/usr/bin/env bash
# modules/gemini-cli/update.sh
# Actualiza gemini-cli a la version mas reciente

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/nexus-install.sh" 2>/dev/null || {
    echo "[ERROR] nexus-install.sh no encontrado"
    exit 1
}
source "$SCRIPT_DIR/metadata.sh" 2>/dev/null || true

log_info "Verificando actualizacion para ${AGENT_NAME:-gemini-cli}..."

_pkg="${AGENT_PACKAGE:-gemini-cli}"

# Check npm outdated first
if command -v npm &>/dev/null; then
    if npm outdated -g "$_pkg" 2>/dev/null | grep -q "$_pkg"; then
        log_info "Nueva version disponible. Actualizando..."
        npm update -g "$_pkg" 2>/dev/null || npm install -g "$_pkg"@latest 2>/dev/null || {
            log_warn "Fallo la actualizacion via npm, reintentando con install.sh..."
            if [ -f "$SCRIPT_DIR/install.sh" ]; then
                (source "$SCRIPT_DIR/install.sh")
            fi
        }
        mark_installed "$AGENT_NAME"
        log_ok "${AGENT_NAME} actualizado correctamente."
    else
        log_ok "${AGENT_NAME} ya esta en la ultima version."
    fi
elif [ -f "$SCRIPT_DIR/install.sh" ]; then
    log_info "npm no disponible, reinstalando..."
    (source "$SCRIPT_DIR/install.sh") && {
        mark_installed "$AGENT_NAME"
        log_ok "${AGENT_NAME} actualizado correctamente."
    }
else
    log_warn "${AGENT_NAME} no tiene install.sh — no se puede actualizar."
fi

exit 0
