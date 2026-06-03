#!/usr/bin/env bash
# modules/pi/install.sh
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── Verificar dependencias ─────────────────────────
check_dependency "Python 3" "python3 --version" || exit 1
check_dependency "pip3" "pip3 --version" || {
    log_info "Intentando instalar pip3..."
    install_via_apt "python3-pip"
}

# ── Instalar pi via pip ────────────────────────────
local _install_rc=0
install_via_pip "pi-ai" || _install_rc=$?

# ── Verificar instalacion ──────────────────────────
if command -v pi &>/dev/null; then
    local version
    version="$(pi --version 2>/dev/null || echo "0.0.0")"
    if [ "$_install_rc" -ne 0 ]; then
        log_warn "El comando pip fallo pero pi ya estaba instalado ($version)"
    fi
    mark_installed "pi" "$version"
    log_ok "pi instalado correctamente ($version)"
else
    log_error "pi no se encuentra en PATH despues de la instalacion."
    log_info "Intenta: pip3 install --user pi-ai"
    exit 1
fi
unset _install_rc
