#!/usr/bin/env bash
# modules/python/install.sh
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── Instalar python via apt/pkg ────────────────────
_install_rc=0
install_via_apt "python" || _install_rc=$?

# ── Verificar instalacion ──────────────────────────
if command -v python3 &>/dev/null; then
    version="$(python3 --version 2>/dev/null | head -1 || echo "0.0.0")"
    if [ "$_install_rc" -ne 0 ]; then
        log_warn "El comando apt/pkg fallo pero python ya estaba instalado ($version)"
    fi
    mark_installed "python" "$version"
    log_ok "python instalado correctamente ($version)"
else
    log_error "python no se encuentra en PATH despues de la instalacion."
    log_info "Intenta: pkg install python"
    exit 1
fi
unset _install_rc
