#!/usr/bin/env bash
# modules/wget/install.sh
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── Instalar wget via apt/pkg ──────────────────────
_install_rc=0
install_via_apt "wget" || _install_rc=$?

# ── Verificar instalacion ──────────────────────────
if command -v wget &>/dev/null; then
    version="$(wget --version 2>/dev/null | head -1 || echo "0.0.0")"
    if [ "$_install_rc" -ne 0 ]; then
        log_warn "El comando apt/pkg fallo pero wget ya estaba instalado ($version)"
    fi
    mark_installed "wget" "$version"
    log_ok "wget instalado correctamente ($version)"
else
    log_error "wget no se encuentra en PATH despues de la instalacion."
    log_info "Intenta: pkg install wget"
    exit 1
fi
unset _install_rc
