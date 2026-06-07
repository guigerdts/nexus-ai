#!/usr/bin/env bash
# modules/sqlite/update.sh
# Actualiza sqlite a la version mas reciente

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/nexus-install.sh" 2>/dev/null || {
    echo "[ERROR] nexus-install.sh no encontrado"
    exit 1
}
source "$SCRIPT_DIR/metadata.sh" 2>/dev/null || true

log_info "Verificando actualizacion para ${AGENT_NAME:-sqlite}..."

_pkg="${AGENT_PACKAGE:-sqlite}"

# pkg/apt — el gestor ya maneja versiones
if [ "${NEXUS_ENV:-}" = "termux" ] || [ "${NEXUS_TERMUX_ACCESSIBLE:-false}" = "true" ]; then
    log_info "Actualizando $_pkg via pkg..."
    pkg upgrade "$_pkg" -y 2>/dev/null && {
        mark_installed "$AGENT_NAME"
        log_ok "${AGENT_NAME} actualizado correctamente."
    } || log_warn "Fallo al actualizar $_pkg"
elif command -v apt &>/dev/null; then
    log_info "Actualizando $_pkg via apt..."
    apt update -y 2>/dev/null || true
    apt install --only-upgrade -y "$_pkg" 2>/dev/null && {
        mark_installed "$AGENT_NAME"
        log_ok "${AGENT_NAME} actualizado correctamente."
    } || log_warn "Fallo al actualizar $_pkg"
else
    log_warn "No se detecto gestor de paquetes (pkg/apt)."
fi

exit 0
