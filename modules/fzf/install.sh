#!/usr/bin/env bash
# modules/fzf/install.sh
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── Instalar fzf via apt/pkg ───────────────────────
_install_rc=0
install_via_apt "fzf" || _install_rc=$?

# ── Verificar instalacion ──────────────────────────
if command -v fzf &>/dev/null; then
    version="$(fzf --version 2>/dev/null | head -1 || echo "0.0.0")"
    if [ "$_install_rc" -ne 0 ]; then
        log_warn "El comando apt/pkg fallo pero fzf ya estaba instalado ($version)"
    fi
    mark_installed "fzf" "$version"
    log_ok "fzf instalado correctamente ($version)"
else
    log_error "fzf no se encuentra en PATH despues de la instalacion."
    log_info "Intenta: pkg install fzf"
    exit 1
fi
unset _install_rc
