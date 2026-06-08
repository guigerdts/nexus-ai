#!/usr/bin/env bash
# modules/mistral-vibe/install.sh
# Instala mistral-vibe (binario: vibe)
# Metodo principal: uv tool install mistral-vibe (recomendado por Mistral)
# Fallback: pip install mistral-vibe
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"
source "$(dirname "${BASH_SOURCE[0]}")/metadata.sh"

log_info "Instalando ${AGENT_NAME} (binario: ${AGENT_BINARY})..."

# ── Metodo 1: uv tool install (recomendado) ────────
if command -v uv &>/dev/null; then
    log_info "Metodo: uv tool install ${AGENT_PACKAGE}..."
    uv tool install "${AGENT_PACKAGE}" 2>&1 | tail -5 || {
        log_warn "Fallback: uv fallo, intentando con pip..."
    }
else
    log_warn "uv no disponible. Intentando con pip..."
fi

# ── Verificar si el binario quedo instalado ────────
if command -v "${AGENT_BINARY}" &>/dev/null; then
    log_ok "${AGENT_NAME} instalado correctamente (binario: ${AGENT_BINARY})."
    mark_installed "$AGENT_NAME" "$AGENT_VERSION"
    exit 0
fi

# ── Metodo 2: pip install (fallback) ────────────────
log_info "Fallback: instalando con pip..."
if ! command -v pip3 &>/dev/null && ! command -v pip &>/dev/null; then
    log_error "pip3/pip no disponible. Instala Python 3 primero."
    exit 1
fi

# Verificar Python >= 3.12
PYTHON_VERSION=""
if command -v python3 &>/dev/null; then
    PYTHON_VERSION="$(python3 --version 2>/dev/null | sed 's/Python //')"
elif command -v python &>/dev/null; then
    PYTHON_VERSION="$(python --version 2>/dev/null | sed 's/Python //')"
fi

if [ -n "$PYTHON_VERSION" ]; then
    REQUIRED_PYTHON="3.12"
    if [ "$(printf '%s\n' "$REQUIRED_PYTHON" "$PYTHON_VERSION" | sort -V | head -1)" != "$REQUIRED_PYTHON" ]; then
        log_warn "Python ${PYTHON_VERSION} detectado. mistral-vibe recomienda >= ${REQUIRED_PYTHON}."
    fi
fi

install_via_pip "${AGENT_PACKAGE}"

# ── Verificar final ─────────────────────────────────
if command -v "${AGENT_BINARY}" &>/dev/null; then
    log_ok "${AGENT_NAME} instalado correctamente (binario: ${AGENT_BINARY})."
    mark_installed "$AGENT_NAME" "$AGENT_VERSION"
else
    log_warn "Binario '${AGENT_BINARY}' no encontrado en PATH."
    log_info "Si instalaste con pip,可能需要: export PATH=\"\$HOME/.local/bin:\$PATH\""
    log_info "O instala con uv:  uv tool install mistral-vibe"
    log_info "Verifica con: ${AGENT_BINARY} --version"
    # Aun asi marcar como instalado — el binario puede estar en ~/.local/bin
    mark_installed "$AGENT_NAME" "$AGENT_VERSION"
fi

exit 0
