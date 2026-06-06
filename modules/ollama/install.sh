#!/usr/bin/env bash
# modules/ollama/install.sh
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── Verificar dependencias ─────────────────────────
check_dependency "curl" "curl --version" || exit 1

# ── Instalar ollama ────────────────────────────────
# Estrategia: en Linux/proot-Ubuntu usar el script oficial.
# En Termux descargar el binary directo de GitHub releases
# porque el script oficial requiere sudo y systemd.
_ollama_arch="$(uname -m)"
case "$_ollama_arch" in
    x86_64)  _ollama_arch="amd64" ;;
    aarch64|arm64) _ollama_arch="arm64" ;;
    *) log_error "Arquitectura no soportada: $_ollama_arch"; exit 1 ;;
esac

if [ "$NEXUS_ENV" = "termux" ]; then
    # Termux: descargar binary directo
    # El asset usa .tar.zst, requiere zstd para extraer
    if ! command -v zstd &>/dev/null; then
        log_info "Instalando zstd (necesario para extraer ollama)..."
        pkg install -y zstd 2>/dev/null || {
            log_error "No se pudo instalar zstd. Instalalo manualmente: pkg install zstd"
            exit 1
        }
    fi

    log_info "Obteniendo ultima version de ollama via GitHub API..."
    _ollama_version="$(curl -s https://api.github.com/repos/ollama/ollama/releases/latest | grep '"tag_name"' | cut -d'"' -f4)"
    if [ -z "$_ollama_version" ]; then
        log_error "No se pudo obtener la ultima version de ollama desde GitHub API"
        exit 1
    fi
    log_info "Version detectada: $_ollama_version"

    _ollama_url="https://github.com/ollama/ollama/releases/download/${_ollama_version}/ollama-linux-${_ollama_arch}.tar.zst"
    _ollama_tmp="$(mktemp -d)"
    log_info "Descargando ollama ${_ollama_version} para ARM64..."
    if curl -fSL "$_ollama_url" -o "$_ollama_tmp/ollama.tar.zst"; then
        tar --zstd -xf "$_ollama_tmp/ollama.tar.zst" -C "$_ollama_tmp"
        if [ -f "$_ollama_tmp/bin/ollama" ]; then
            mv "$_ollama_tmp/bin/ollama" "$PREFIX/bin/ollama"
        elif [ -f "$_ollama_tmp/ollama" ]; then
            mv "$_ollama_tmp/ollama" "$PREFIX/bin/ollama"
        else
            log_error "Binary no encontrado en el archive"
            ls -la "$_ollama_tmp"
            rm -rf "$_ollama_tmp"
            exit 1
        fi
        chmod +x "$PREFIX/bin/ollama"
        rm -rf "$_ollama_tmp"
        log_ok "ollama ${_ollama_version} instalado en $PREFIX/bin/ollama"
    else
        log_error "Fallo la descarga desde $_ollama_url"
        rm -rf "$_ollama_tmp"
        exit 1
    fi
else
    # proot-Ubuntu / Linux nativo: script oficial
    # El script oficial maneja zstd internamente
    log_info "Instalando ollama via script oficial..."
    if ! command -v zstd &>/dev/null; then
        log_info "Instalando zstd (posiblemente necesario)..."
        install_via_apt "zstd" 2>/dev/null || true
    fi
    if curl -fsSL https://ollama.com/install.sh | sh; then
        : # ok
    else
        log_error "Fallo la instalacion de ollama"
        log_info "Intenta manualmente: curl -fsSL https://ollama.com/install.sh | sh"
        exit 1
    fi
fi

# ── Verificar ──────────────────────────────────────
if command -v ollama &>/dev/null; then
    version="$(ollama --version 2>/dev/null | awk '{print $NF}' || echo "latest")"
    mark_installed "ollama" "$version"
    log_ok "ollama instalado correctamente ($version)"
else
    log_error "ollama se instalo pero no se encuentra en PATH"
    log_info "Verifica que el binario este en PATH"
    exit 1
fi
unset _ollama_arch _ollama_version _ollama_url _ollama_tmp
