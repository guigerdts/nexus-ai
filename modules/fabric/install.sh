#!/usr/bin/env bash
# modules/fabric/install.sh
# Fabric: AI-powered CLI for common tasks
# Go-based. Instalar via el script oficial de fabric.
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
_NEXUS_INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$_NEXUS_INSTALL_DIR/lib/nexus-install.sh"

_fabric_installer_url="https://raw.githubusercontent.com/danielmiessler/fabric/main/install.sh"

# ═══════════════════════════════════════════════════
#  Opcion 1: Instalador oficial de fabric
# ═══════════════════════════════════════════════════
log_info "Descargando e instalando fabric via instalador oficial..."
if curl -fsSL "$_fabric_installer_url" | bash; then
    log_ok "Instalador oficial de fabric ejecutado correctamente."
else
    log_warn "Instalador oficial fallo. Intentando via go install..."
    # ═══════════════════════════════════════════════════
    #  Opcion 2: go install fallback
    # ═══════════════════════════════════════════════════
    if command -v go &>/dev/null; then
        if go install github.com/danielmiessler/fabric@latest; then
            log_ok "fabric instalado via go install"
        else
            log_error "go install tambien fallo."
            log_info "Instalacion manual:"
            log_info "  curl -fsSL https://raw.githubusercontent.com/danielmiessler/fabric/main/install.sh | bash"
            log_info "  O: go install github.com/danielmiessler/fabric@latest"
            exit 1
        fi
    else
        log_error "No se pudo instalar fabric (instalador oficial + go install fallaron)."
        log_info "Instalacion manual:"
        log_info "  curl -fsSL https://raw.githubusercontent.com/danielmiessler/fabric/main/install.sh | bash"
        log_info "  O: go install github.com/danielmiessler/fabric@latest"
        exit 1
    fi
fi

# ═══════════════════════════════════════════════════
#  Verificar instalacion
# ═══════════════════════════════════════════════════
# El instalador oficial deja fabric en ~/.local/bin o ~/go/bin
if command -v fabric &>/dev/null; then
    version="$(fabric --version 2>/dev/null || echo "0.0.0")"
    mark_installed "fabric" "$version"
    log_ok "fabric instalado correctamente ($version)"
    log_info "Ejecuta: fabric --help"
else
    log_warn "fabric no esta en PATH. Buscando en directorios comunes..."
    for _dir in "$HOME/.local/bin" "$HOME/go/bin" "/usr/local/bin"; do
        if [ -f "$_dir/fabric" ]; then
            version="$("$_dir/fabric" --version 2>/dev/null || echo "0.0.0")"
            mark_installed "fabric" "$version"
            log_ok "fabric encontrado en $_dir ($version)"
            log_info "Agrega $_dir a tu PATH si no lo esta."
            break
        fi
    done
    if ! command -v fabric &>/dev/null && [ ! -f "$HOME/.local/bin/fabric" ] && [ ! -f "$HOME/go/bin/fabric" ]; then
        log_error "fabric no se encuentra en PATH ni en directorios comunes."
        log_info "Verifica la instalacion manualmente."
        exit 1
    fi
fi

unset _NEXUS_INSTALL_DIR _fabric_installer_url
