#!/usr/bin/env bash
# modules/sqlite/install.sh
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── Instalar sqlite via apt/pkg ────────────────────
_install_rc=0
install_via_apt "sqlite" || _install_rc=$?

# ── Verificar instalacion ──────────────────────────
if command -v sqlite3 &>/dev/null; then
    version="$(sqlite3 --version 2>/dev/null | head -1 || echo "0.0.0")"
    if [ "$_install_rc" -ne 0 ]; then
        log_warn "El comando apt/pkg fallo pero sqlite ya estaba instalado ($version)"
    fi
    mark_installed "sqlite" "$version"
    log_ok "sqlite instalado correctamente ($version)"
else
    log_error "sqlite no se encuentra en PATH despues de la instalacion."
    log_info "Intenta: pkg install sqlite"
    exit 1
fi
unset _install_rc
