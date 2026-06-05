#!/usr/bin/env bash
# modules/codex/install.sh
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── Verificar dependencias ─────────────────────────
check_dependency "Node.js" "node --version" || exit 1
check_dependency "npm" "npm --version" || exit 1

# ── Instalar codex via npm ─────────────────────────
_install_rc=0
install_via_npm "@openai/codex" || _install_rc=$?

# ── Verificar instalacion ──────────────────────────
if command -v codex &>/dev/null; then
    version="$(codex --version 2>/dev/null | awk '{print $NF}' || echo "0.0.0")"
    if [ "$_install_rc" -ne 0 ]; then
        log_warn "El comando npm fallo pero codex ya estaba instalado ($version)"
    fi
    mark_installed "codex" "$version"
    log_ok "codex instalado correctamente ($version)"
else
    log_error "codex no se encuentra en PATH despues de la instalacion."
    log_info "Intenta: npm install -g @openai/codex"
    exit 1
fi
unset _install_rc
