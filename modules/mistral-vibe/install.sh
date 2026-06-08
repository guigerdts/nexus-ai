#!/usr/bin/env bash
# modules/mistral-vibe/install.sh
# Instala mistral-vibe via pip (Python package, binary: vibe)
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"
source "$(dirname "${BASH_SOURCE[0]}")/metadata.sh"

log_info "Instalando ${AGENT_NAME} (${AGENT_PACKAGE}) via pip..."

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

if command -v "${AGENT_BINARY}" &>/dev/null; then
    log_ok "${AGENT_NAME} instalado correctamente (binario: ${AGENT_BINARY})."
    mark_installed "$AGENT_NAME" "$AGENT_VERSION"
else
    log_warn "Binario '${AGENT_BINARY}' no encontrado en PATH."
    log_info "El paquete se instalo pero puede necesitar: export PATH=\"\$HOME/.local/bin:\$PATH\""
    log_info "Verifica con: ${AGENT_BINARY} --version"
    # Aun asi marcar como instalado
    mark_installed "$AGENT_NAME" "$AGENT_VERSION"
fi

exit 0
