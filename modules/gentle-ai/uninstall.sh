#!/usr/bin/env bash
# modules/gentle-ai/uninstall.sh
# Desinstala gentle-ai: elimina binario y repositorio clonado
set -euo pipefail

# Source functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/nexus-install.sh" 2>/dev/null || {
    echo "[ERROR] nexus-install.sh no encontrado"
    exit 1
}
source "$SCRIPT_DIR/metadata.sh" 2>/dev/null || true

log_info "Desinstalando ${AGENT_NAME:-gentle-ai}..."

# Eliminar binario
BINARY_PATH="${PREFIX:-/usr/local}/bin/${AGENT_BINARY:-gentle-ai}"
if [ -f "$BINARY_PATH" ]; then
    rm -f "$BINARY_PATH"
    log_info "Binario eliminado: ${BINARY_PATH}"
fi

# Eliminar repositorio clonado
REPO_DIR="${AGENT_REPO_DIR:-}"
if [ -z "$REPO_DIR" ]; then
    REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)/gentle-ai"
fi
if [ -d "$REPO_DIR" ]; then
    rm -rf "$REPO_DIR"
    log_info "Repositorio eliminado: ${REPO_DIR}"
fi

# Buscar tambien en ~/.local/share/nexus-ai/gentle-ai
ALT_REPO="${HOME}/.local/share/nexus-ai/gentle-ai"
if [ -d "$ALT_REPO" ]; then
    rm -rf "$ALT_REPO"
    log_info "Repositorio alternativo eliminado: ${ALT_REPO}"
fi

mark_removed "$AGENT_NAME"
log_ok "Agente '${AGENT_NAME}' desinstalado."
exit 0
