#!/usr/bin/env bash
# modules/php/install.sh
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── Instalar php via apt/pkg ───────────────────────
_install_rc=0
install_via_apt "php" || _install_rc=$?

# ── Verificar instalacion ──────────────────────────
if command -v php &>/dev/null; then
    version="$(php --version 2>/dev/null | head -1 || echo "0.0.0")"
    if [ "$_install_rc" -ne 0 ]; then
        log_warn "El comando apt/pkg fallo pero php ya estaba instalado ($version)"
    fi
    mark_installed "php" "$version"
    log_ok "php instalado correctamente ($version)"
else
    log_error "php no se encuentra en PATH despues de la instalacion."
    log_info "Intenta: pkg install php"
    exit 1
fi
unset _install_rc
