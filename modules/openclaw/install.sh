#!/usr/bin/env bash
# modules/openclaw/install.sh
# Instala openclaw + dependencias extra via npm
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"
source "$(dirname "${BASH_SOURCE[0]}")/metadata.sh"

log_info "Instalando ${AGENT_NAME} desde npm..."

if ! command -v npm &>/dev/null; then
    log_error "npm no disponible. Instala Node.js primero."
    exit 1
fi

# Instalar paquete principal
npm install -g "${AGENT_PACKAGE}@latest"

# Instalar dependencias extra para integraciones
if [ -n "${OPENCLAW_EXTRA_DEPS:-}" ]; then
    log_info "Instalando dependencias extra..."
    for dep in $OPENCLAW_EXTRA_DEPS; do
        npm install -g "$dep" 2>/dev/null || log_warn "No se pudo instalar $dep (opcional)"
    done
fi

if command -v "${AGENT_BINARY}" &>/dev/null; then
    log_ok "${AGENT_NAME} instalado correctamente."
    mark_installed "$AGENT_NAME" "$AGENT_VERSION"
else
    log_error "No se encontro el binario ${AGENT_BINARY} luego de la instalacion."
    exit 1
fi

exit 0
