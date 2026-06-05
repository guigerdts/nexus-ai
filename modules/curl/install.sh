#!/usr/bin/env bash
# modules/curl/install.sh
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── Instalar curl via apt/pkg ──────────────────────
_install_rc=0
install_via_apt "curl" || _install_rc=$?

# ── Verificar instalacion ──────────────────────────
if command -v curl &>/dev/null; then
    version="$(curl --version 2>/dev/null | head -1 || echo "0.0.0")"
    if [ "$_install_rc" -ne 0 ]; then
        log_warn "El comando apt/pkg fallo pero curl ya estaba instalado ($version)"
    fi
    mark_installed "curl" "$version"
    log_ok "curl instalado correctamente ($version)"
else
    log_error "curl no se encuentra en PATH despues de la instalacion."
    log_info "Intenta: pkg install curl"
    exit 1
fi
unset _install_rc
