#!/usr/bin/env bash
# modules/clang/install.sh
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── Instalar clang via apt/pkg ─────────────────────
_install_rc=0
install_via_apt "clang" || _install_rc=$?

# ── Verificar instalacion ──────────────────────────
if command -v clang &>/dev/null; then
    version="$(clang --version 2>/dev/null | head -1 || echo "0.0.0")"
    if [ "$_install_rc" -ne 0 ]; then
        log_warn "El comando apt/pkg fallo pero clang ya estaba instalado ($version)"
    fi
    mark_installed "clang" "$version"
    log_ok "clang instalado correctamente ($version)"
else
    log_error "clang no se encuentra en PATH despues de la instalacion."
    log_info "Intenta: pkg install clang"
    exit 1
fi
unset _install_rc
