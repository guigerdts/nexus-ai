#!/usr/bin/env bash
# modules/eza/install.sh
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── Instalar eza via apt/pkg ───────────────────────
_install_rc=0
install_via_apt "eza" || _install_rc=$?

# ── Verificar instalacion ──────────────────────────
if command -v eza &>/dev/null; then
    version="$(eza --version 2>/dev/null | head -1 || echo "0.0.0")"
    if [ "$_install_rc" -ne 0 ]; then
        log_warn "El comando apt/pkg fallo pero eza ya estaba instalado ($version)"
    fi
    mark_installed "eza" "$version"
    log_ok "eza instalado correctamente ($version)"
else
    log_error "eza no se encuentra en PATH despues de la instalacion."
    log_info "Intenta: pkg install eza"
    exit 1
fi
unset _install_rc
