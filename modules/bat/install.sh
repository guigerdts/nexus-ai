#!/usr/bin/env bash
# modules/bat/install.sh
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── Instalar bat via apt/pkg ───────────────────────
_install_rc=0
install_via_apt "bat" || _install_rc=$?

# ── Verificar instalacion ──────────────────────────
if command -v bat &>/dev/null; then
    version="$(bat --version 2>/dev/null | head -1 || echo "0.0.0")"
    if [ "$_install_rc" -ne 0 ]; then
        log_warn "El comando apt/pkg fallo pero bat ya estaba instalado ($version)"
    fi
    mark_installed "bat" "$version"
    log_ok "bat instalado correctamente ($version)"
else
    log_error "bat no se encuentra en PATH despues de la instalacion."
    log_info "Intenta: pkg install bat"
    exit 1
fi
unset _install_rc
