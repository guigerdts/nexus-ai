#!/usr/bin/env bash
# modules/fabric/install.sh
# Fabric: AI-powered CLI for common tasks
# Go-based. Descarga binary desde GitHub Releases usando API para obtener version.
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
_NEXUS_INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$_NEXUS_INSTALL_DIR/lib/nexus-install.sh"

_fabric_bin_dir="$HOME/.local/bin"
_fabric_bin="$_fabric_bin_dir/fabric"
_fabric_repo="danielmiessler/fabric"
if [ "${NEXUS_ARCH:-arm64}" = "x86_64" ]; then
    _fabric_asset="fabric_Linux_x86_64.tar.gz"
else
    _fabric_asset="fabric_Linux_arm64.tar.gz"
fi

mkdir -p "$_fabric_bin_dir"

# ═══════════════════════════════════════════════════
#  Obtener ultima version via GitHub API
# ═══════════════════════════════════════════════════
log_info "Obteniendo ultima version de fabric desde GitHub API..."
_fabric_version=""
_fabric_version="$(curl -sL "https://api.github.com/repos/$_fabric_repo/releases/latest" | grep tag_name | cut -d'"' -f4)" || true

if [ -z "$_fabric_version" ]; then
    log_warn "No se pudo obtener la version via API. Usando 'latest'."
    _fabric_version="latest"
fi

log_info "Version detectada: $_fabric_version"

# ═══════════════════════════════════════════════════
#  Construir URL y verificar con curl -I
# ═══════════════════════════════════════════════════
_fabric_url="https://github.com/$_fabric_repo/releases/download/$_fabric_version/$_fabric_asset"

log_info "Verificando URL: $_fabric_url"
if curl -sfI "$_fabric_url" >/dev/null 2>&1; then
    log_ok "URL responde. Descargando..."
    _fabric_tmp="$(mktemp -d)"
    if curl -fsSL "$_fabric_url" -o "$_fabric_tmp/$_fabric_asset"; then
        tar -xzf "$_fabric_tmp/$_fabric_asset" -C "$_fabric_tmp"
        if [ -f "$_fabric_tmp/fabric" ]; then
            cp "$_fabric_tmp/fabric" "$_fabric_bin"
            chmod +x "$_fabric_bin"
            log_ok "fabric binary extraido y copiado a $_fabric_bin"
        else
            log_warn "No se encontro binary fabric dentro del tarball."
        fi
    else
        log_warn "Descarga fallo a pesar de que la URL respondio."
    fi
    rm -rf "$_fabric_tmp"
else
    log_warn "URL no accesible: $_fabric_url"
    log_info "Intentando via go install..."
    # ═══════════════════════════════════════════════════
    #  Fallback: go install
    # ═══════════════════════════════════════════════════
    if command -v go &>/dev/null; then
        log_info "Instalando fabric via go install..."
        if go install "github.com/$_fabric_repo@latest"; then
            _go_bin="$(go env GOPATH)/bin/fabric"
            if [ -f "$_go_bin" ]; then
                cp "$_go_bin" "$_fabric_bin"
                log_ok "fabric instalado via go install y copiado a $_fabric_bin"
            fi
        else
            log_warn "go install fallo."
        fi
    else
        log_warn "go no esta disponible."
    fi
fi

# ═══════════════════════════════════════════════════
#  Verificar instalacion
# ═══════════════════════════════════════════════════
if [ -f "$_fabric_bin" ]; then
    version="$("$_fabric_bin" --version 2>/dev/null || echo "$_fabric_version")"
    mark_installed "fabric" "$version"
    log_ok "fabric instalado correctamente ($version)"
    log_info "Ejecuta: fabric --help"

    # Sugerir agregar al PATH si no esta
    case ":$PATH:" in
        *":$_fabric_bin_dir:"*) ;;
        *) log_info "Agrega $_fabric_bin_dir a tu PATH si no esta." ;;
    esac
else
    log_error "fabric no se pudo instalar."
    log_info "Instalacion manual:"
    log_info "  1. Obtener version: curl -s https://api.github.com/repos/$_fabric_repo/releases/latest | grep tag_name | cut -d'\"' -f4"
    log_info "  2. Descargar: curl -L https://github.com/$_fabric_repo/releases/download/{VERSION}/fabric_Linux_arm64.tar.gz"
    log_info "  3. Extraer: tar -xzf fabric_Linux_arm64.tar.gz fabric && chmod +x fabric && mv fabric ~/.local/bin/"
    log_info "  O: go install github.com/$_fabric_repo@latest"
    exit 1
fi

unset _NEXUS_INSTALL_DIR _fabric_bin_dir _fabric_bin _fabric_repo _fabric_asset _fabric_version _fabric_url _fabric_tmp _go_bin
