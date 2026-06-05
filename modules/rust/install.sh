#!/usr/bin/env bash
# modules/rust/install.sh
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── Instalar rust via apt/pkg ──────────────────────
_install_rc=0
install_via_apt "rust" || _install_rc=$?

# ── Verificar instalacion ──────────────────────────
if command -v rustc &>/dev/null; then
    version="$(rustc --version 2>/dev/null | head -1 || echo "0.0.0")"
    if [ "$_install_rc" -ne 0 ]; then
        log_warn "El comando apt/pkg fallo pero rust ya estaba instalado ($version)"
    fi
    mark_installed "rust" "$version"
    log_ok "rust instalado correctamente ($version)"
else
    log_error "rust no se encuentra en PATH despues de la instalacion."
    log_info "Intenta: pkg install rust"
    exit 1
fi
unset _install_rc
