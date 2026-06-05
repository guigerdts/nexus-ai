#!/usr/bin/env bash
# modules/gh/install.sh
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── Instalar gh via apt/pkg ────────────────────────
_install_rc=0
install_via_apt "gh" || _install_rc=$?

# ── Verificar instalacion ──────────────────────────
if command -v gh &>/dev/null; then
    version="$(gh --version 2>/dev/null | head -1 || echo "0.0.0")"
    if [ "$_install_rc" -ne 0 ]; then
        log_warn "El comando apt/pkg fallo pero gh ya estaba instalado ($version)"
    fi
    mark_installed "gh" "$version"
    log_ok "gh instalado correctamente ($version)"
else
    log_error "gh no se encuentra en PATH despues de la instalacion."
    log_info "Intenta: pkg install gh"
    exit 1
fi
unset _install_rc
