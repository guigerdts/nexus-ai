#!/usr/bin/env bash
# modules/openclaw/install.sh
# Instala openclaw + dependencias extra via npm
# Requiere Node.js >= 22.19.0
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

# ── Verificar Node.js >= 22.19.0 ───────────────────
NODE_VERSION=""
if command -v node &>/dev/null; then
    NODE_VERSION="$(node --version 2>/dev/null | sed 's/^v//')"
fi

REQUIRED_NODE="22.19.0"

if [ -z "$NODE_VERSION" ]; then
    log_error "Node.js no encontrado. openclaw requiere Node >= ${REQUIRED_NODE}."
    log_info "Instala Node 22+ con: pkg install nodejs (Termux) o nvm install 22"
    exit 1
fi

if [ "$(printf '%s\n' "$REQUIRED_NODE" "$NODE_VERSION" | sort -V | head -1)" != "$REQUIRED_NODE" ]; then
    log_warn "Node.js ${NODE_VERSION} detectado. openclaw requiere >= ${REQUIRED_NODE}."
    if [ "${NEXUS_TERMUX_ACCESSIBLE:-false}" = "true" ] || [ "${NEXUS_ENV:-}" = "termux" ]; then
        log_info "Actualiza Node en Termux: pkg install nodejs (obtienes Node 22+)"
    else
        log_info "Actualiza Node con: nvm install 22"
    fi
    log_info "Intentando instalar con --ignore-engines (puede fallar en runtime)..."
    INSTALL_FLAGS="--ignore-engines"
else
    INSTALL_FLAGS=""
fi

# Instalar paquete principal
if [ -n "$INSTALL_FLAGS" ]; then
    npm install -g $INSTALL_FLAGS "${AGENT_PACKAGE}@latest"
else
    npm install -g "${AGENT_PACKAGE}@latest"
fi

# Instalar dependencias extra para integraciones
if [ -n "${OPENCLAW_EXTRA_DEPS:-}" ]; then
    log_info "Instalando dependencias extra..."
    for dep in $OPENCLAW_EXTRA_DEPS; do
        if [ -n "$INSTALL_FLAGS" ]; then
            npm install -g $INSTALL_FLAGS "$dep" 2>/dev/null || log_warn "No se pudo instalar $dep (opcional)"
        else
            npm install -g "$dep" 2>/dev/null || log_warn "No se pudo instalar $dep (opcional)"
        fi
    done
fi

if command -v "${AGENT_BINARY}" &>/dev/null; then
    log_ok "${AGENT_NAME} instalado correctamente."
    mark_installed "$AGENT_NAME" "$AGENT_VERSION"

    if [ -n "$NODE_VERSION" ] && [ "$(printf '%s\n' "$REQUIRED_NODE" "$NODE_VERSION" | sort -V | head -1)" != "$REQUIRED_NODE" ]; then
        log_warn "Actualiza Node a >= ${REQUIRED_NODE} para que openclaw funcione correctamente."
    fi
else
    log_error "No se encontro el binario ${AGENT_BINARY} luego de la instalacion."
    exit 1
fi

exit 0
