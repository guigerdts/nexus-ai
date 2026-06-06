#!/usr/bin/env bash
# modules/agy/install.sh
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── Verificar dependencias ─────────────────────────
check_dependency "curl" "curl --version" || exit 1

# ── Instalar agy via script oficial ────────────────
# Google's official install: curl https://antigravity.google/cli/install.sh | bash
log_info "Instalando agy desde script oficial de Google..."
install_via_curl "https://antigravity.google/cli/install.sh"

# ── Verificar instalacion ──────────────────────────
if command -v agy &>/dev/null; then
    version="$(agy --version 2>/dev/null || echo "latest")"
    mark_installed "agy" "$version"
    log_ok "agy instalado correctamente ($version)"
else
    log_error "agy no se encuentra en PATH despues de la instalacion."
    log_info "Intenta manualmente: curl -fsSL https://antigravity.google/cli/install.sh | bash"
    exit 1
fi
