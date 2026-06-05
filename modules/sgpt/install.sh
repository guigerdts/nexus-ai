#!/usr/bin/env bash
# modules/sgpt/install.sh
# SGPT (shell-gpt): ChatGPT in terminal
# Dual-environment: Termux (pkg + pip) / proot-Ubuntu (pip)
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
_NEXUS_INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$_NEXUS_INSTALL_DIR/lib/nexus-install.sh"

# ── Detectar entorno (auto-contenido) ──────────────
if [ -n "${PREFIX:-}" ]; then
    NEXUS_ENV="termux"
elif command -v pkg &>/dev/null && [ -d "/data/data/com.termux" ] 2>/dev/null; then
    NEXUS_ENV="termux"
elif [ -n "${NEXUS_ENV:-}" ]; then
    : # ya definido por el parent shell (source)
else
    NEXUS_ENV="linux"
fi
export NEXUS_ENV

# ── Verificar dependencias ─────────────────────────
check_dependency "Python 3" "python3 --version" || exit 1
check_dependency "pip3" "pip3 --version" || {
    log_info "Intentando instalar pip3..."
    install_via_apt "python3-pip"
}

# ═══════════════════════════════════════════════════
#  Instalar sgpt via pip
# ═══════════════════════════════════════════════════
_install_rc=0
install_via_pip "shell-gpt" || _install_rc=$?

# ═══════════════════════════════════════════════════
#  Fallback: uv pip install
# ═══════════════════════════════════════════════════
if [ "$_install_rc" -ne 0 ]; then
    log_info "pip fallo. Intentando con uv como fallback..."
    if ! command -v uv &>/dev/null; then
        log_info "Instalando uv via pip..."
        pip3 install uv 2>/dev/null || pip3 install --user uv 2>/dev/null || true
    fi
    if command -v uv &>/dev/null; then
        log_info "Instalando shell-gpt via uv..."
        uv pip install shell-gpt --no-build && _install_rc=0 || log_warn "uv tampoco pudo instalar sgpt"
    else
        log_warn "uv no esta disponible. No se pudo instalar sgpt."
    fi
fi

# ═══════════════════════════════════════════════════
#  Verificar instalacion
# ═══════════════════════════════════════════════════
if command -v sgpt &>/dev/null; then
    version="$(sgpt --version 2>/dev/null || echo "0.0.0")"
    if [ "$_install_rc" -ne 0 ]; then
        log_warn "El comando pip fallo pero sgpt ya estaba instalado ($version)"
    fi
    mark_installed "sgpt" "$version"
    log_ok "sgpt instalado correctamente ($version)"
else
    log_error "sgpt no se encuentra en PATH despues de la instalacion."
    log_info "Intenta: pip3 install --user shell-gpt"
    log_info "O con uv: pip3 install uv && uv pip install shell-gpt"
    exit 1
fi

# ── Cleanup ─────────────────────────────────────────
unset _install_rc _NEXUS_INSTALL_DIR
