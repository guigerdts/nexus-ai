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
# @latest + --force asegura que se instale el binary nativo
# ARM64 (@openai/codex-linux-arm64) que es optionalDependency.
# Sin --force, npm puede saltarlo si ya hay una instalacion
# parcial o si el resolver no lo baja correctamente.
_npm_cmd="npm"
if [ "${NEXUS_TERMUX_ACCESSIBLE:-false}" = "true" ] && [ -n "${TERMUX_NPM:-}" ]; then
    _npm_cmd="$TERMUX_NPM"
fi
log_info "Instalando @openai/codex@latest..."
$_npm_cmd install -g "@openai/codex@latest" --force 2>/dev/null || _install_rc=$?
unset _npm_cmd

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
