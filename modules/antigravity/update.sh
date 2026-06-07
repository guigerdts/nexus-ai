#!/usr/bin/env bash
# modules/antigravity/update.sh
# Actualiza antigravity a la version mas reciente

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/nexus-install.sh" 2>/dev/null || {
    echo "[ERROR] nexus-install.sh no encontrado"
    exit 1
}
source "$SCRIPT_DIR/metadata.sh" 2>/dev/null || true

log_info "Verificando actualizacion para ${AGENT_NAME:-antigravity}..."

# Re-install via the same method as install.sh
if [ -f "$SCRIPT_DIR/install.sh" ]; then
    (source "$SCRIPT_DIR/install.sh") && {
        mark_installed "$AGENT_NAME"
        log_ok "${AGENT_NAME} actualizado correctamente."
    }
else
    log_warn "${AGENT_NAME} no tiene install.sh — no se puede actualizar."
fi

exit 0
