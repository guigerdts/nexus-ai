#!/usr/bin/env bash
# modules/mistral-vibe/uninstall.sh
# Desinstala Mistral-vibe (soporta uv tool y pip)
set -euo pipefail

# Source functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/nexus-install.sh" 2>/dev/null || {
    echo "[ERROR] nexus-install.sh no encontrado"
    exit 1
}
source "$SCRIPT_DIR/metadata.sh" 2>/dev/null || true

log_info "Desinstalando ${AGENT_NAME:-mistral-vibe}..."

# Intentar uv tool uninstall primero (metodo preferido)
if command -v uv &>/dev/null; then
    log_info "Intentando desinstalar con uv tool..."
    uv tool uninstall "${AGENT_PACKAGE:-mistral-vibe}" 2>/dev/null || true
fi

# Fallback: pip uninstall
uninstall_via_pip "${AGENT_PACKAGE:-mistral-vibe}"

mark_removed "$AGENT_NAME"
log_ok "Agente '${AGENT_NAME}' desinstalado."
exit 0
