#!/usr/bin/env bash
# modules/postgresql/install.sh
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── Instalar postgresql via apt/pkg ────────────────
_install_rc=0
install_via_apt "postgresql" || _install_rc=$?

# ── Verificar instalacion ──────────────────────────
if command -v psql &>/dev/null; then
    version="$(psql --version 2>/dev/null | head -1 || echo "0.0.0")"
    if [ "$_install_rc" -ne 0 ]; then
        log_warn "El comando apt/pkg fallo pero postgresql ya estaba instalado ($version)"
    fi
    mark_installed "postgresql" "$version"
    log_ok "postgresql instalado correctamente ($version)"
else
    log_error "postgresql no se encuentra en PATH despues de la instalacion."
    log_info "Intenta: pkg install postgresql"
    exit 1
fi
unset _install_rc
