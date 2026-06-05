#!/usr/bin/env bash
# modules/lazygit/install.sh
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── Instalar lazygit via apt/pkg ───────────────────
_install_rc=0
install_via_apt "lazygit" || _install_rc=$?

# ── Verificar instalacion ──────────────────────────
if command -v lazygit &>/dev/null; then
    version="$(lazygit --version 2>/dev/null | head -1 || echo "0.0.0")"
    if [ "$_install_rc" -ne 0 ]; then
        log_warn "El comando apt/pkg fallo pero lazygit ya estaba instalado ($version)"
    fi
    mark_installed "lazygit" "$version"
    log_ok "lazygit instalado correctamente ($version)"
else
    log_error "lazygit no se encuentra en PATH despues de la instalacion."
    log_info "Intenta: pkg install lazygit"
    exit 1
fi
unset _install_rc
