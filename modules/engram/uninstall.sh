#!/usr/bin/env bash
# modules/engram/uninstall.sh
# Desinstala engram: elimina binario y repositorio clonado
set -euo pipefail

# Source functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/nexus-install.sh" 2>/dev/null || {
    echo "[ERROR] nexus-install.sh no encontrado"
    exit 1
}
source "$SCRIPT_DIR/metadata.sh" 2>/dev/null || true

log_info "Desinstalando ${AGENT_NAME:-engram}..."

# Eliminar binario
BINARY_PATH="${PREFIX:-/usr/local}/bin/${AGENT_BINARY:-engram}"
if [ -f "$BINARY_PATH" ]; then
    rm -f "$BINARY_PATH"
    log_info "Binario eliminado: ${BINARY_PATH}"
fi

# Eliminar repositorio clonado
REPO_DIR="${AGENT_REPO_DIR:-}"
if [ -z "$REPO_DIR" ]; then
    REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)/engram"
fi
if [ -d "$REPO_DIR" ]; then
    rm -rf "$REPO_DIR"
    log_info "Repositorio eliminado: ${REPO_DIR}"
fi

# Buscar tambien en ~/.local/share/nexus-ai/engram
ALT_REPO="${HOME}/.local/share/nexus-ai/engram"
if [ -d "$ALT_REPO" ]; then
    rm -rf "$ALT_REPO"
    log_info "Repositorio alternativo eliminado: ${ALT_REPO}"
fi

mark_removed "$AGENT_NAME"
log_ok "Agente '${AGENT_NAME}' desinstalado."
exit 0
