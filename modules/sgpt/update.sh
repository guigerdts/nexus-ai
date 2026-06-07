#!/usr/bin/env bash
# modules/sgpt/update.sh
# Actualiza sgpt a la version mas reciente

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/nexus-install.sh" 2>/dev/null || {
    echo "[ERROR] nexus-install.sh no encontrado"
    exit 1
}
source "$SCRIPT_DIR/metadata.sh" 2>/dev/null || true

log_info "Verificando actualizacion para ${AGENT_NAME:-sgpt}..."

_pkg="${AGENT_PACKAGE:-sgpt}"

# pip3 install --upgrade — pip maneja versiones
if command -v pip3 &>/dev/null; then
    log_info "Actualizando $_pkg via pip..."
    pip3 install --upgrade "$_pkg" 2>/dev/null && {
        mark_installed "$AGENT_NAME"
        log_ok "${AGENT_NAME} actualizado correctamente."
    } || log_warn "Fallo al actualizar $_pkg"
elif [ -f "$SCRIPT_DIR/install.sh" ]; then
    log_info "pip3 no disponible, reinstalando..."
    (source "$SCRIPT_DIR/install.sh") && {
        mark_installed "$AGENT_NAME"
        log_ok "${AGENT_NAME} actualizado correctamente."
    }
else
    log_warn "pip3 no disponible y no hay install.sh."
fi

exit 0
