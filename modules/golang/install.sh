#!/usr/bin/env bash
# modules/golang/install.sh
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── Instalar golang via apt/pkg ────────────────────
_install_rc=0
install_via_apt "golang" || _install_rc=$?

# ── Verificar instalacion ──────────────────────────
if command -v go &>/dev/null; then
    version="$(go version 2>/dev/null | head -1 || echo "0.0.0")"
    if [ "$_install_rc" -ne 0 ]; then
        log_warn "El comando apt/pkg fallo pero golang ya estaba instalado ($version)"
    fi
    mark_installed "golang" "$version"
    log_ok "golang instalado correctamente ($version)"
else
    log_error "golang no se encuentra en PATH despues de la instalacion."
    log_info "Intenta: pkg install golang"
    exit 1
fi
unset _install_rc
