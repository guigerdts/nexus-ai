#!/usr/bin/env bash
# modules/aider/install.sh
# Aider: AI pair programming in terminal
# Dual-environment: Termux (pkg + pip) / proot-Ubuntu (pip)
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
_NEXUS_INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$_NEXUS_INSTALL_DIR/lib/nexus-install.sh"

# ── Detectar entorno (auto-contenido) ──────────────
# Funciona incluso cuando install.sh se ejecuta via `bash` sub-shell
# desde core/nexus.sh (que no hereda NEXUS_ENV).
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
#  TERMUX: numpy pre-compilado via pkg
# ═══════════════════════════════════════════════════
# Python 3.12+ removio pkgutil.ImpImporter, necesario
# para compilar numpy desde source. Termux ofrece
# python-numpy pre-compilado que esquiva este problema.
# En proot-Ubuntu numpy compila normalmente via pip.
if [ "$NEXUS_ENV" = "termux" ]; then
    log_info "Termux detectado: instalando numpy pre-compilado via pkg..."
    if pkg install -y python-numpy 2>/dev/null; then
        log_ok "numpy instalado via pkg"
    else
        log_warn "No se pudo instalar python-numpy via pkg"
        log_warn "aider puede fallar si numpy no compila desde source en Python 3.12+"
    fi
fi

# ═══════════════════════════════════════════════════
#  Instalar aider via pip
# ═══════════════════════════════════════════════════
_install_rc=0
install_via_pip "aider-chat" || _install_rc=$?

# ═══════════════════════════════════════════════════
#  Fallback: uv pip install
# ═══════════════════════════════════════════════════
# Si pip falla (numpy compilation u otro error),
# intentar con uv que resuelve mejor dependencias
# con binarios pre-compilados.
if [ "$_install_rc" -ne 0 ]; then
    log_info "pip fallo. Intentando con uv como fallback..."
    if ! command -v uv &>/dev/null; then
        log_info "Instalando uv via pip..."
        pip3 install uv 2>/dev/null || pip3 install --user uv 2>/dev/null || true
    fi
    if command -v uv &>/dev/null; then
        log_info "Instalando aider-chat via uv..."
        uv pip install aider-chat && _install_rc=0 || log_warn "uv tampoco pudo instalar aider"
    else
        log_warn "uv no esta disponible. No se pudo instalar aider."
    fi
fi

# ═══════════════════════════════════════════════════
#  Verificar instalacion
# ═══════════════════════════════════════════════════
if command -v aider &>/dev/null; then
    version="$(aider --version 2>/dev/null || echo "0.0.0")"
    if [ "$_install_rc" -ne 0 ]; then
        log_warn "El comando pip fallo pero aider ya estaba instalado ($version)"
    fi
    mark_installed "aider" "$version"
    log_ok "aider instalado correctamente ($version)"
else
    log_error "aider no se encuentra en PATH despues de la instalacion."
    log_info "En Termux: pkg install python-numpy && pip3 install --user aider-chat"
    log_info "En proot-Ubuntu/Linux: pip3 install --user aider-chat"
    log_info "O intenta con uv: pip3 install uv && uv pip install aider-chat"
    exit 1
fi

# ── Cleanup ─────────────────────────────────────────
unset _install_rc _NEXUS_INSTALL_DIR
