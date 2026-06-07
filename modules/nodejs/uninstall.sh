#!/usr/bin/env bash
# modules/nodejs/uninstall.sh
# Desinstala Nodejs

# Source functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/nexus-install.sh" 2>/dev/null || {
    echo "[ERROR] nexus-install.sh no encontrado"
    exit 1
}
source "$SCRIPT_DIR/metadata.sh" 2>/dev/null || true

log_info "Desinstalando ${AGENT_NAME:-nodejs}..."

# Dispatch by method — map AGENT_METHOD to correct uninstall function
case "${AGENT_METHOD:-}" in
    pip)   uninstall_via_pip "${AGENT_PACKAGE:-$AGENT_NAME}" ;;
    npm)   uninstall_via_npm "${AGENT_PACKAGE:-$AGENT_NAME}" ;;
    pkg)   uninstall_via_apt "${AGENT_PACKAGE:-$AGENT_NAME}" ;;
    apt)   uninstall_via_apt "${AGENT_PACKAGE:-$AGENT_NAME}" ;;
    curl)  uninstall_via_binary "$AGENT_NAME" "$AGENT_BINARY" ;;
    cargo) uninstall_via_binary "$AGENT_NAME" "$AGENT_BINARY" ;;
    binary) uninstall_via_binary "$AGENT_NAME" "$AGENT_BINARY" ;;
    git)   log_info "Agente instalado via git. Elimina el directorio clonado manualmente." ;;
    stub)  log_info "Agente stub — no requiere desinstalacion." ;;
    *)     log_warn "Metodo '${AGENT_METHOD:-}' no tiene desinstalador automatico."
           if [ -n "${AGENT_BINARY:-}" ] && command -v "$AGENT_BINARY" &>/dev/null; then
               rm -f "$(command -v "$AGENT_BINARY")" 2>/dev/null || true
           fi
           ;;
esac

mark_removed "$AGENT_NAME"
log_ok "Agente '${AGENT_NAME}' desinstalado."
exit 0
