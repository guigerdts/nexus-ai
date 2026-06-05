#!/usr/bin/env bash
# modules/nodemon/install.sh
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── Verificar dependencias ─────────────────────────
check_dependency "Node.js" "node --version" || exit 1
check_dependency "npm" "npm --version" || exit 1

# ── Instalar nodemon via npm ───────────────────────
_install_rc=0
install_via_npm "nodemon" || _install_rc=$?

# ── Verificar instalacion ──────────────────────────
if command -v nodemon &>/dev/null; then
    version="$(nodemon --version 2>/dev/null || echo "0.0.0")"
    if [ "$_install_rc" -ne 0 ]; then
        log_warn "El comando npm fallo pero nodemon ya estaba instalado ($version)"
    fi
    mark_installed "nodemon" "$version"
    log_ok "nodemon instalado correctamente ($version)"
else
    log_error "nodemon no se encuentra en PATH despues de la instalacion."
    log_info "Intenta: npm install -g nodemon"
    exit 1
fi
unset _install_rc
