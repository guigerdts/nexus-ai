#!/usr/bin/env bash
# modules/git/install.sh
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── Instalar git via apt/pkg ───────────────────────
_install_rc=0
install_via_apt "git" || _install_rc=$?

# ── Verificar instalacion ──────────────────────────
if command -v git &>/dev/null; then
    version="$(git --version 2>/dev/null | head -1 || echo "0.0.0")"
    if [ "$_install_rc" -ne 0 ]; then
        log_warn "El comando apt/pkg fallo pero git ya estaba instalado ($version)"
    fi
    mark_installed "git" "$version"
    log_ok "git instalado correctamente ($version)"
else
    log_error "git no se encuentra en PATH despues de la instalacion."
    log_info "Intenta: pkg install git"
    exit 1
fi
unset _install_rc
