#!/usr/bin/env bash
# modules/zsh/install.sh
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── Instalar zsh via apt/pkg ───────────────────────
_install_rc=0
install_via_apt "zsh" || _install_rc=$?

# ── Verificar instalacion ──────────────────────────
if command -v zsh &>/dev/null; then
    version="$(zsh --version 2>/dev/null | head -1 || echo "0.0.0")"
    if [ "$_install_rc" -ne 0 ]; then
        log_warn "El comando apt/pkg fallo pero zsh ya estaba instalado ($version)"
    fi
    mark_installed "zsh" "$version"
    log_ok "zsh instalado correctamente ($version)"
else
    log_error "zsh no se encuentra en PATH despues de la instalacion."
    log_info "Intenta: pkg install zsh"
    exit 1
fi
unset _install_rc
