#!/usr/bin/env bash
# modules/mimo-code/uninstall.sh
# Desinstala MiMo Code — via npm y limpia datos locales
set -euo pipefail

# Source functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/nexus-install.sh" 2>/dev/null || {
    echo "[ERROR] nexus-install.sh no encontrado"
    exit 1
}
source "$SCRIPT_DIR/metadata.sh" 2>/dev/null || true

log_info "Desinstalando ${AGENT_NAME:-mimo-code}..."

# 1. Desinstalar paquete npm
uninstall_via_npm "${AGENT_PACKAGE:-@mimo-ai/cli}"

# 2. Limpiar datos locales de MiMo Code
if [ -d "${HOME}/.mimocode" ]; then
    rm -rf "${HOME}/.mimocode"
    log_info "Eliminado: ${HOME}/.mimocode"
fi

# 3. Limpiar cualquier binario residual en PATH
if command -v mimo &>/dev/null; then
    rm -f "$(command -v mimo)" 2>/dev/null || true
fi

mark_removed "$AGENT_NAME"
log_ok "Agente '${AGENT_NAME}' desinstalado."
exit 0
