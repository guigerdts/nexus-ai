#!/usr/bin/env bash
# modules/pi/install.sh
# Instala Pi Coding Agent via npm con --ignore-scripts
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"
source "$(dirname "${BASH_SOURCE[0]}")/metadata.sh"

log_info "Instalando ${AGENT_NAME} desde npm (--ignore-scripts)..."

if ! command -v npm &>/dev/null; then
    log_error "npm no disponible. Instala Node.js primero."
    exit 1
fi

# --ignore-scripts evita errores de compilacion en Termux/entornos limitados
npm install -g --ignore-scripts "${AGENT_PACKAGE}"

if command -v "${AGENT_BINARY}" &>/dev/null; then
    log_ok "${AGENT_NAME} instalado correctamente."
    mark_installed "$AGENT_NAME" "$AGENT_VERSION"
else
    log_error "No se encontro el binario ${AGENT_BINARY} luego de la instalacion."
    exit 1
fi

exit 0
