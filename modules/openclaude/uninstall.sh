#!/usr/bin/env bash
# modules/openclaude/uninstall.sh
# Desinstala Openclaude
set -euo pipefail

# Source functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/nexus-install.sh" 2>/dev/null || {
    echo "[ERROR] nexus-install.sh no encontrado"
    exit 1
}
source "$SCRIPT_DIR/metadata.sh" 2>/dev/null || true

log_info "Desinstalando ${AGENT_NAME:-openclaude}..."

uninstall_via_npm "${AGENT_PACKAGE:-@gitlawb/openclaude}"

mark_removed "$AGENT_NAME"
log_ok "Agente '${AGENT_NAME}' desinstalado."
exit 0
