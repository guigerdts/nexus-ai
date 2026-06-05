#!/usr/bin/env bash
# modules/starship/install.sh
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── Instalar starship via script oficial ───────────
log_info "Instalando starship via script oficial..."
if curl -sS https://starship.rs/install.sh | sh -s -- -y; then
    if command -v starship &>/dev/null; then
        version="$(starship --version 2>/dev/null | head -1 || echo "latest")"
        mark_installed "starship" "$version"
        log_ok "starship instalado correctamente ($version)"
    else
        log_error "starship se instalo pero no se encuentra en PATH"
        exit 1
    fi
else
    log_error "Fallo la instalacion de starship"
    log_info "Intenta manualmente: curl -sS https://starship.rs/install.sh | sh"
    exit 1
fi
