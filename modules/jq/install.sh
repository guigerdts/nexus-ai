#!/usr/bin/env bash
# modules/jq/install.sh
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── Instalar jq via apt/pkg ────────────────────────
_install_rc=0
install_via_apt "jq" || _install_rc=$?

# ── Verificar instalacion ──────────────────────────
if command -v jq &>/dev/null; then
    version="$(jq --version 2>/dev/null | head -1 || echo "0.0.0")"
    if [ "$_install_rc" -ne 0 ]; then
        log_warn "El comando apt/pkg fallo pero jq ya estaba instalado ($version)"
    fi
    mark_installed "jq" "$version"
    log_ok "jq instalado correctamente ($version)"
else
    log_error "jq no se encuentra en PATH despues de la instalacion."
    log_info "Intenta: pkg install jq"
    exit 1
fi
unset _install_rc
