#!/usr/bin/env bash
# modules/perl/install.sh
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── Instalar perl via apt/pkg ──────────────────────
_install_rc=0
install_via_apt "perl" || _install_rc=$?

# ── Verificar instalacion ──────────────────────────
if command -v perl &>/dev/null; then
    version="$(perl --version 2>/dev/null | head -1 || echo "0.0.0")"
    if [ "$_install_rc" -ne 0 ]; then
        log_warn "El comando apt/pkg fallo pero perl ya estaba instalado ($version)"
    fi
    mark_installed "perl" "$version"
    log_ok "perl instalado correctamente ($version)"
else
    log_error "perl no se encuentra en PATH despues de la instalacion."
    log_info "Intenta: pkg install perl"
    exit 1
fi
unset _install_rc
