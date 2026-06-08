#!/usr/bin/env bash
# modules/minimax-cli/install.sh
# Instala minimax-cli (mmx-cli) via npm
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"
source "$(dirname "${BASH_SOURCE[0]}")/metadata.sh"

log_info "Instalando ${AGENT_NAME} (${AGENT_PACKAGE}) desde npm..."

if ! command -v npm &>/dev/null; then
    log_error "npm no disponible. Instala Node.js primero."
    exit 1
fi

npm install -g "${AGENT_PACKAGE}"

if command -v "${AGENT_BINARY}" &>/dev/null; then
    log_ok "${AGENT_NAME} instalado correctamente (binario: ${AGENT_BINARY})."
    mark_installed "$AGENT_NAME" "$AGENT_VERSION"
else
    log_error "No se encontro el binario ${AGENT_BINARY} luego de la instalacion."
    exit 1
fi

exit 0
