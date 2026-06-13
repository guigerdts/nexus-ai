#!/usr/bin/env bash
# modules/mimo-code/update.sh
# Actualiza MiMo Code a la version mas reciente
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/nexus-install.sh" 2>/dev/null || {
    echo "[ERROR] nexus-install.sh no encontrado"
    exit 1
}
source "$SCRIPT_DIR/metadata.sh" 2>/dev/null || true

log_info "Verificando actualizacion para ${AGENT_NAME:-mimo-code}..."

if [ -f "$SCRIPT_DIR/install.sh" ]; then
    (source "$SCRIPT_DIR/install.sh") && {
        mark_installed "$AGENT_NAME" "$AGENT_VERSION"
        log_ok "${AGENT_NAME} actualizado correctamente."
    }
else
    log_error "install.sh no encontrado"
    exit 1
fi

exit 0
