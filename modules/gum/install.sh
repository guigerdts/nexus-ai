#!/usr/bin/env bash
# modules/gum/install.sh
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── Instalar gum via apt/pkg ───────────────────────
_install_rc=0
install_via_apt "gum" || _install_rc=$?

# ── Verificar instalacion ──────────────────────────
if command -v gum &>/dev/null; then
    version="$(gum --version 2>/dev/null | head -1 || echo "0.0.0")"
    if [ "$_install_rc" -ne 0 ]; then
        log_warn "El comando apt/pkg fallo pero gum ya estaba instalado ($version)"
    fi
    mark_installed "gum" "$version"
    log_ok "gum instalado correctamente ($version)"
else
    log_error "gum no se encuentra en PATH despues de la instalacion."
    log_info "Intenta: pkg install gum"
    exit 1
fi
unset _install_rc
