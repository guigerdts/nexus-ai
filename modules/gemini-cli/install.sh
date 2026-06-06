#!/usr/bin/env bash
# modules/gemini-cli/install.sh
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ╔══════════════════════════════════════════════════════════════╗
# ║  ⚠  DEPRECATED — gemini-cli tiene sunset el 18 junio 2026 ║
# ║                                                              ║
# ║  Google esta migrando gemini-cli a su nueva CLI oficial:     ║
# ║    nxai install agy                                          ║
# ║                                                              ║
# ║  agy ofrece el mismo asistente de IA con soporte activo.    ║
# ╚══════════════════════════════════════════════════════════════╝
log_warn "gemini-cli tiene sunset el 18 junio 2026"
log_warn "Instala el reemplazo: nxai install agy"
echo ""

# ── Verificar dependencias ─────────────────────────
check_dependency "Node.js" "node --version" || exit 1
check_dependency "npm" "npm --version" || exit 1

# ── Instalar gemini-cli via npm ────────────────────
_install_rc=0
install_via_npm "@google/gemini-cli" || _install_rc=$?

# ── Verificar instalacion ──────────────────────────
if command -v gemini &>/dev/null; then
    version="$(gemini --version 2>/dev/null || echo "0.0.0")"
    if [ "$_install_rc" -ne 0 ]; then
        log_warn "El comando npm fallo pero gemini-cli ya estaba instalado ($version)"
    fi
    mark_installed "gemini-cli" "$version"
    log_ok "gemini-cli instalado correctamente ($version)"
else
    log_error "gemini-cli no se encuentra en PATH despues de la instalacion."
    log_info "Intenta: npm install -g @google/gemini-cli"
    exit 1
fi
unset _install_rc
