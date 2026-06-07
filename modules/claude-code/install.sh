#!/usr/bin/env bash
# modules/claude-code/install.sh
# Instala @anthropic-ai/claude-code via npm (paquete oficial Anthropic)
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── claude-code: instalacion via npm ───────────────
log_info "Instalando claude-code (${AGENT_PACKAGE:-@anthropic-ai/claude-code})..."

if [ "${NEXUS_ENV:-}" = "termux" ]; then
    log_warn "claude-code requiere ~2GB en Termux nativo. Recomendado: proot-Ubuntu."
    log_info "Continua con la instalacion en Termux..."
fi

check_dependency "npm" "npm --version" || exit 1

install_via_npm "${AGENT_PACKAGE:-@anthropic-ai/claude-code}" || {
    log_error "Fallo instalacion via npm"
    exit 1
}

# Registrar en installed.txt
_v="$(claude --version 2>/dev/null || true)"
mark_installed "claude-code" "${_v:-}"
log_ok "claude-code instalado correctamente (${_v:-latest})"
