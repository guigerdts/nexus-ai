#!/usr/bin/env bash
# modules/opencode/install.sh
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── Verificar dependencias ─────────────────────────
check_dependency "Node.js" "node --version" || exit 1
check_dependency "npm" "npm --version" || exit 1

# ── Instalar opencode via npm ──────────────────────
local _install_rc=0
install_via_npm "opencode-ai" || _install_rc=$?

# ── Verificar instalacion ──────────────────────────
if command -v opencode &>/dev/null; then
    local version
    version="$(opencode --version 2>/dev/null || echo "0.0.0")"
    if [ "$_install_rc" -ne 0 ]; then
        log_warn "El comando npm fallo pero opencode ya estaba instalado ($version)"
    fi
    mark_installed "opencode" "$version"
    log_ok "opencode instalado correctamente ($version)"
else
    log_error "opencode no se encuentra en PATH despues de la instalacion."
    log_info "Intenta: npm install -g opencode-ai"
    exit 1
fi
unset _install_rc
