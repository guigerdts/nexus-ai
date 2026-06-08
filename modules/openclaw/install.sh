#!/usr/bin/env bash
# modules/openclaw/install.sh
# Instala openclaw + dependencias extra via npm
# REQUIERE Node.js >= 22.19.0 (el binario lo exige en runtime)
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

# ── Verificar Node.js >= 22.19.0 (OBLIGATORIO) ─────
NODE_VERSION=""
if command -v node &>/dev/null; then
    NODE_VERSION="$(node --version 2>/dev/null | sed 's/^v//')"
fi

REQUIRED_NODE="22.19.0"

if [ -z "$NODE_VERSION" ]; then
    log_error "Node.js no encontrado. openclaw requiere Node >= ${REQUIRED_NODE}."
    log_info "Instala Node 22+ con:"
    log_info "  Termux:  pkg install nodejs"
    log_info "  nvm:     nvm install 22"
    exit 1
fi

if [ "$(printf '%s\n' "$REQUIRED_NODE" "$NODE_VERSION" | sort -V | head -1)" != "$REQUIRED_NODE" ]; then
    log_error "Node.js ${NODE_VERSION} detectado. openclaw requiere Node >= ${REQUIRED_NODE}."
    log_info "Actualiza Node e intenta de nuevo:"
    if [ "${NEXUS_TERMUX_ACCESSIBLE:-false}" = "true" ] || [ "${NEXUS_ENV:-}" = "termux" ]; then
        log_info "  pkg install nodejs      # Obtienes Node 22+ en Termux"
    else
        log_info "  nvm install 22"
        log_info "  nvm use 22"
    fi
    exit 1
fi

log_ok "Node.js ${NODE_VERSION} — requisito cumplido"

# ── Si ya esta instalado, salir temprano ────────────
if command -v "${AGENT_BINARY}" &>/dev/null; then
    log_ok "${AGENT_NAME} ya instalado (binario: ${AGENT_BINARY})."
    mark_installed "$AGENT_NAME" "$AGENT_VERSION"
    exit 0
fi

# ── Limpiar instalacion global previa (npm ENOTEMPTY workaround) ─
# npm reify falla con exit 217 cuando el directorio global del paquete
# existe de una instalacion previa. Limpiar antes de instalar.
NPM_GLOBAL_DIR="$(npm root -g 2>/dev/null)/${AGENT_PACKAGE}"
if [ -d "$NPM_GLOBAL_DIR" ]; then
    log_info "Limpiando instalacion previa en ${NPM_GLOBAL_DIR}..."
    rm -rf "$NPM_GLOBAL_DIR"
fi

# ── Instalar paquete principal ─────────────────────
log_info "Instalando openclaw@latest (esto puede tomar varios minutos)..."
npm install -g "${AGENT_PACKAGE}@latest"

# ── Instalar dependencias extra ────────────────────
if [ -n "${OPENCLAW_EXTRA_DEPS:-}" ]; then
    log_info "Instalando dependencias extra..."
    for dep in $OPENCLAW_EXTRA_DEPS; do
        npm install -g "$dep" 2>/dev/null || log_warn "No se pudo instalar $dep (opcional)"
    done
fi

# ── Verificar ───────────────────────────────────────
if command -v "${AGENT_BINARY}" &>/dev/null; then
    log_ok "${AGENT_NAME} instalado correctamente."
    mark_installed "$AGENT_NAME" "$AGENT_VERSION"
else
    log_error "No se encontro el binario ${AGENT_BINARY} luego de la instalacion."
    exit 1
fi

exit 0
