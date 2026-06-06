#!/usr/bin/env bash
# modules/ollama/install.sh
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── Verificar dependencias ─────────────────────────
check_dependency "curl" "curl --version" || exit 1

# ── Instalar ollama ────────────────────────────────
# Estrategia: en Termux nativo usa pkg install (Bionic libc).
# En proot-Ubuntu/Linux usa el script oficial (glibc).
# El binario de GitHub releases es glibc y no funciona en
# Termux nativo (Android Bionic libc).
if [ "$NEXUS_ENV" = "termux" ]; then
    # Termux nativo: usa pkg (Termux tiene ollama en sus repos)
    # El binario de GitHub releases requiere glibc y no funciona
    # en Termux (usa Bionic libc de Android).
    log_info "Instalando ollama via pkg (Termux repo)..."
    if pkg install -y ollama 2>/dev/null; then
        : # ok
    else
        log_error "No se pudo instalar ollama via pkg."
        log_info "Verifica: pkg search ollama"
        log_info "O instalalo manualmente: pkg install ollama"
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
