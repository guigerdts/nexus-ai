#!/usr/bin/env bash
# modules/fabric/install.sh
# Fabric: AI-powered CLI for common tasks
# Go-based. Instalar via curl (ARM64 binary) o go install.
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
_NEXUS_INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$_NEXUS_INSTALL_DIR/lib/nexus-install.sh"

_fabric_dir="$NEXUS_ROOT/bin"
_fabric_bin="$_fabric_dir/fabric"

mkdir -p "$_fabric_dir"

# ═══════════════════════════════════════════════════
#  Opcion 1: go install (si golang esta disponible)
# ═══════════════════════════════════════════════════
if command -v go &>/dev/null; then
    log_info "Instalando fabric via go install..."
    if go install github.com/danielmiessler/fabric@latest 2>/dev/null; then
        cp "$(go env GOPATH)/bin/fabric" "$_fabric_bin" 2>/dev/null || true
        log_ok "fabric instalado via go"
    else
        log_warn "go install fallo, intentando descarga directa..."
    fi
fi

# ═══════════════════════════════════════════════════
#  Opcion 2: curl binary desde GitHub Releases
# ═══════════════════════════════════════════════════
if [ ! -f "$_fabric_bin" ]; then
    log_info "Descargando fabric binary ARM64 desde GitHub Releases..."
    _fabric_url="https://github.com/danielmiessler/fabric/releases/latest/download/fabric-linux-arm64"
    if curl -fsSL "$_fabric_url" -o "$_fabric_bin"; then
        chmod +x "$_fabric_bin"
        log_ok "fabric binary descargado a $_fabric_bin"
    else
        log_warn "Descarga directa fallo. El release puede no existir o tener otro nombre."
    fi
fi

# ═══════════════════════════════════════════════════
#  Verificar instalacion
# ═══════════════════════════════════════════════════
if [ -f "$_fabric_bin" ]; then
    version="$("$_fabric_bin" --version 2>/dev/null || echo "0.0.0")"
    mark_installed "fabric" "$version"
    log_ok "fabric instalado correctamente ($version)"
    log_info "Ejecuta: fabric --help"
else
    log_error "fabric no se pudo instalar automaticamente."
    log_info "Instalacion manual:"
    log_info "  Con Go: go install github.com/danielmiessler/fabric@latest"
    log_info "  Con curl: curl -fsSL https://raw.githubusercontent.com/danielmiessler/fabric/main/install.sh | bash"
    exit 1
fi

unset _NEXUS_INSTALL_DIR _fabric_dir _fabric_bin _fabric_url
