#!/usr/bin/env bash
# modules/nodejs/install.sh
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── Instalar nodejs via apt/pkg ────────────────────
_install_rc=0
install_via_apt "nodejs" || _install_rc=$?

# ── Verificar instalacion ──────────────────────────
if command -v node &>/dev/null; then
    version="$(node --version 2>/dev/null | head -1 || echo "0.0.0")"
    if [ "$_install_rc" -ne 0 ]; then
        log_warn "El comando apt/pkg fallo pero nodejs ya estaba instalado ($version)"
    fi
    mark_installed "nodejs" "$version"
    log_ok "nodejs instalado correctamente ($version)"
else
    log_error "nodejs no se encuentra en PATH despues de la instalacion."
    log_info "Intenta: pkg install nodejs"
    exit 1
fi
unset _install_rc
