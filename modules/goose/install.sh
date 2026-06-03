#!/usr/bin/env bash
# modules/goose/install.sh
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── Verificar dependencias ─────────────────────────
check_dependency "curl" "curl --version" || exit 1

# ── Instalar goose via curl ────────────────────────
local _install_rc=0
install_via_curl "https://github.com/block/goose/install.sh" || _install_rc=$?

# ── Verificar instalacion ──────────────────────────
if command -v goose &>/dev/null; then
    local version
    version="$(goose --version 2>/dev/null || echo "0.0.0")"
    if [ "$_install_rc" -ne 0 ]; then
        log_warn "El script de instalacion fallo pero goose ya estaba instalado ($version)"
    fi
    mark_installed "goose" "$version"
    log_ok "goose instalado correctamente ($version)"
else
    log_error "goose no se encuentra en PATH despues de la instalacion."
    log_info "Visita: https://github.com/block/goose"
    exit 1
fi
unset _install_rc
