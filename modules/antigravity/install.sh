#!/usr/bin/env bash
# modules/antigravity/install.sh
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── antigravity → redirige a agy ──────────────────
# antigravity CLI ha sido reemplazado por agy (CLI oficial de Google).
# Este install.sh instala agy y lo registra como antigravity.
log_info "antigravity ha sido reemplazado por agy (CLI oficial de Google)"
log_info "Instalando agy como reemplazo..."

# Instalar agy via script oficial
install_via_curl "https://antigravity.google/cli/install.sh"

# ── Verificar instalacion ──────────────────────────
if command -v agy &>/dev/null; then
    version="$(agy --version 2>/dev/null || echo "latest")"
    # Se registra como "antigravity" para mantener compatibilidad
    mark_installed "antigravity" "$version"
    log_ok "antigravity → agy instalado correctamente ($version)"
else
    log_error "agy no se encuentra en PATH despues de la instalacion."
    log_info "Intenta manualmente: nxai install agy"
    exit 1
fi
