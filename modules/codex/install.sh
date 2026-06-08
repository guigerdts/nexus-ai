#!/usr/bin/env bash
# modules/codex/install.sh
# Instala Codex CLI
# Termux nativo: fork @mmmbuto/codex-cli-termux (compatible ARM64)
# proot-Ubuntu/Linux: paquete oficial @openai/codex
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

check_dependency "npm" "npm --version" || exit 1

# ── Branch segun entorno ───────────────────────────
if [ "${NEXUS_ENV:-}" = "termux" ]; then
    # Termux nativo — fork compatibile con ARM64
    _pkg="@mmmbuto/codex-cli-termux"
    log_info "Termux detectado — instalando ${_pkg}..."
    log_info "Nota: el fork de codex-cli-termux incluye soporte ARM64."
    install_via_npm "$_pkg" || {
        log_error "Fallo instalacion del fork"
        exit 1
    }
else
    # proot-Ubuntu / Linux — paquete oficial
    _pkg="@openai/codex"
    log_info "Entorno Linux — instalando ${_pkg}..."
    log_info "Nota: En ARM64 el paquete oficial puede fallar."
    log_info "Si falla, proba con: npm install -g @mmmbuto/codex-cli-termux"
    install_via_npm "$_pkg" || {
        log_error "Fallo instalacion del paquete oficial"
        exit 1
    }
fi

# ── Verificacion final ──────────────────────────────
if command -v codex &>/dev/null; then
    _v="$(codex --version 2>/dev/null || true)"
    mark_installed "codex" "${_v:-}"
    log_ok "codex instalado correctamente (${_v:-latest})"
else
    log_error "codex no encontrado en PATH despues de la instalacion"
    exit 1
fi

unset _pkg _v
