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
    _ollama_url="https://github.com/ollama/ollama/releases/latest/download/ollama-linux-${_ollama_arch}.tgz"
    _ollama_tmp="$(mktemp -d)"
    log_info "Descargando ollama para Termux desde GitHub releases..."
    if curl -fsSL "$_ollama_url" -o "$_ollama_tmp/ollama.tgz"; then
        tar -xzf "$_ollama_tmp/ollama.tgz" -C "$_ollama_tmp"
        # El tarball contiene el binary en la raiz
        if [ -f "$_ollama_tmp/ollama" ]; then
            mv "$_ollama_tmp/ollama" "$PREFIX/bin/ollama"
            chmod +x "$PREFIX/bin/ollama"
            rm -rf "$_ollama_tmp"
            log_ok "ollama instalado en $PREFIX/bin/ollama"
        else
            log_error "Binary no encontrado en el tarball"
            rm -rf "$_ollama_tmp"
            exit 1
        fi
    else
        log_error "Fallo la descarga de ollama desde $_ollama_url"
        rm -rf "$_ollama_tmp"
        exit 1
    fi
else
    # proot-Ubuntu / Linux nativo: script oficial
    log_info "Instalando ollama via script oficial..."
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
unset _ollama_arch _ollama_url _ollama_tmp
