#!/usr/bin/env bash
# modules/openclaw/uninstall.sh
# Desinstala openclaw y sus dependencias extra
set -euo pipefail

# Source functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/nexus-install.sh" 2>/dev/null || {
    echo "[ERROR] nexus-install.sh no encontrado"
    exit 1
}
source "$SCRIPT_DIR/metadata.sh" 2>/dev/null || true

log_info "Desinstalando ${AGENT_NAME:-openclaw}..."

# Desinstalar paquete principal
uninstall_via_npm "${AGENT_PACKAGE:-openclaw}"

# Desinstalar dependencias extra
if [ -n "${OPENCLAW_EXTRA_DEPS:-}" ]; then
    log_info "Limpiando dependencias extra..."
    for dep in $OPENCLAW_EXTRA_DEPS; do
        npm uninstall -g "$dep" 2>/dev/null || true
    done
fi

mark_removed "$AGENT_NAME"
log_ok "Agente '${AGENT_NAME}' desinstalado."
exit 0
