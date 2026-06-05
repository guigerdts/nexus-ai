#!/usr/bin/env bash
# modules/ollama/install.sh
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── Verificar dependencias ─────────────────────────
check_dependency "curl" "curl --version" || exit 1

# ── Instalar ollama via script oficial ─────────────
log_info "Instalando ollama via script oficial..."
if curl -fsSL https://ollama.com/install.sh | sh; then
    if command -v ollama &>/dev/null; then
        version="$(ollama --version 2>/dev/null || echo "latest")"
        mark_installed "ollama" "$version"
        log_ok "ollama instalado correctamente ($version)"
    else
        log_error "ollama se instalo pero no se encuentra en PATH"
        exit 1
    fi
else
    log_error "Fallo la instalacion de ollama"
    log_info "Intenta manualmente: curl -fsSL https://ollama.com/install.sh | sh"
    exit 1
fi
