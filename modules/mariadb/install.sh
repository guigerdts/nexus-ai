#!/usr/bin/env bash
# modules/mariadb/install.sh
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── Instalar mariadb via apt/pkg ───────────────────
_install_rc=0
install_via_apt "mariadb" || _install_rc=$?

# ── Verificar instalacion ──────────────────────────
if command -v mariadb &>/dev/null; then
    version="$(mariadb --version 2>/dev/null | head -1 || echo "0.0.0")"
    if [ "$_install_rc" -ne 0 ]; then
        log_warn "El comando apt/pkg fallo pero mariadb ya estaba instalado ($version)"
    fi
    mark_installed "mariadb" "$version"
    log_ok "mariadb instalado correctamente ($version)"
else
    log_error "mariadb no se encuentra en PATH despues de la instalacion."
    log_info "Intenta: pkg install mariadb"
    exit 1
fi
unset _install_rc
