#!/usr/bin/env bash
# modules/neovim/install.sh
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── Instalar neovim via apt/pkg ────────────────────
_install_rc=0
install_via_apt "neovim" || _install_rc=$?

# ── Verificar instalacion ──────────────────────────
if command -v nvim &>/dev/null; then
    version="$(nvim --version 2>/dev/null | head -2 | tail -1 || echo "0.0.0")"
    if [ "$_install_rc" -ne 0 ]; then
        log_warn "El comando apt/pkg fallo pero neovim ya estaba instalado ($version)"
    fi
    mark_installed "neovim" "$version"
    log_ok "neovim instalado correctamente ($version)"
else
    log_error "neovim no se encuentra en PATH despues de la instalacion."
    log_info "Intenta: pkg install neovim"
    exit 1
fi
unset _install_rc
