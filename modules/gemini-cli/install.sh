#!/usr/bin/env bash
# modules/gemini-cli/install.sh
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ╔══════════════════════════════════════════════════════════════╗
# ║  ⚠  gemini-cli SUNSET — 18 junio 2026                     ║
# ║                                                              ║
# ║  Google ha discontinuado gemini-cli.                         ║
# ║  El reemplazo oficial es Antigravity CLI (agy):              ║
# ║    nxai install ai --agy                                     ║
# ║                                                              ║
# ║  Mas info: https://antigravity.google/product/antigravity-cli ║
# ╚══════════════════════════════════════════════════════════════╝

# ── Check sunset date ──────────────────────────────
# Sunset: 18 June 2026. If today >= that date, block install.
_CURRENT_EPOCH=$(date +%s)
_SUNSET_EPOCH=$(date -d "2026-06-18" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "2026-06-18" +%s 2>/dev/null || echo "0")

if [ "$_CURRENT_EPOCH" -ge "$_SUNSET_EPOCH" ] 2>/dev/null; then
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║  ✘  gemini-cli fue discontinuado el 18 junio 2026          ║"
    echo "║                                                              ║"
    echo "║  Google Gemini CLI ya no procesa solicitudes.               ║"
    echo "║                                                              ║"
    echo "║  Reemplazo oficial — Antigravity CLI (agy):                 ║"
    echo "║    nxai install ai --agy                                    ║"
    echo "║                                                              ║"
    echo "║  https://antigravity.google/product/antigravity-cli         ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    exit 1
fi

# ── Pre-sunset: warn but still allow install ────────
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  ⚠  gemini-cli SUNSET — 18 junio 2026                     ║"
echo "║                                                              ║"
echo "║  Google discontinuara gemini-cli el 18 de junio de 2026.    ║"
echo "║  Migra a Antigravity CLI (agy) antes de esa fecha:          ║"
echo "║    nxai install ai --agy                                     ║"
echo "║                                                              ║"
echo "║  https://antigravity.google/product/antigravity-cli         ║"
echo "╚══════════════════════════════════════════════════════════════╝"
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
