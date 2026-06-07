#!/usr/bin/env bash
# modules/history-substring/update.sh
# Actualiza history-substring a la version mas reciente

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/nexus-install.sh" 2>/dev/null || {
    echo "[ERROR] nexus-install.sh no encontrado"
    exit 1
}
source "$SCRIPT_DIR/metadata.sh" 2>/dev/null || true

log_info "Verificando actualizacion para ${AGENT_NAME:-history-substring}..."

if [ -f "$SCRIPT_DIR/install.sh" ]; then
    (source "$SCRIPT_DIR/install.sh") && {
        mark_installed "$AGENT_NAME"
        log_ok "${AGENT_NAME} actualizado correctamente."
    }
else
    log_info "${AGENT_NAME} es stub — sin instalador. Salteando."
fi

exit 0
