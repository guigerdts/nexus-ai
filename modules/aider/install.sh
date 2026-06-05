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
#  Pre-instalar numpy (esquiva compilacion desde source)
# ═══════════════════════════════════════════════════
# Python 3.12+ removio pkgutil.ImpImporter, necesario
# para compilar numpy desde source. En cada entorno se
# instala el paquete del sistema: python-numpy (Termux)
# o python3-numpy (proot-Ubuntu/Debian).
if [ "$NEXUS_ENV" = "termux" ]; then
    log_info "Termux detectado: instalando numpy pre-compilado via pkg..."
    if pkg install -y python-numpy 2>/dev/null; then
        log_ok "numpy instalado via pkg"
    else
        log_warn "No se pudo instalar python-numpy via pkg"
        log_warn "aider puede fallar si numpy no compila desde source en Python 3.12+"
    fi
elif [ "$NEXUS_ENV" = "proot-ubuntu" ] || [ "$NEXUS_ENV" = "linux" ]; then
    log_info "Instalando python3-numpy via apt..."
    if apt install -y python3-numpy 2>/dev/null; then
        log_ok "numpy instalado via apt"
    else
        log_warn "No se pudo instalar python3-numpy via apt"
        log_warn "aider puede fallar si numpy necesita compilar desde source"
    fi
fi

# ═══════════════════════════════════════════════════
#  Upgrade pip/setuptools (Python 3.12+ compat)
# ═══════════════════════════════════════════════════
# Debian/proot-Ubuntu puede tener setuptools viejo que usa
# pkgutil.ImpImporter, removido en Python 3.12+.
# Forzar upgrade antes de instalar aider para evitar:
#   AttributeError: module 'pkgutil' has no attribute 'ImpImporter'
log_info "Actualizando pip, setuptools y wheel..."
pip3 install --upgrade pip setuptools wheel --break-system-packages 2>/dev/null || \
    pip3 install --upgrade pip setuptools wheel --user 2>/dev/null || \
    log_warn "No se pudo actualizar pip/setuptools, continuando..."

# ═══════════════════════════════════════════════════
#  Instalar aider via pip (con --no-build-isolation)
# ═══════════════════════════════════════════════════
# --no-build-isolation evita que pip cree un build env
# aislado usando setuptools del sistema, que es
# incompatible con Python 3.12+ (pkgutil.ImpImporter).
_install_rc=0
log_info "Instalando aider-chat via pip..."
# Intento 1: --no-build-isolation (evita setuptools del sistema)
if ! pip3 install --user --no-build-isolation aider-chat; then
    log_info "Fallo --user, reintentando con --break-system-packages..."
    # Intento 2: --no-build-isolation + PEP 668 bypass
    if ! pip3 install --break-system-packages --no-build-isolation aider-chat; then
        # Intento 3: sin --no-build-isolation (permite pip-build-env limpio)
        # Necesario para paquetes que requieren build deps como setuptools_rust
        # que pip instala en su entorno aislado. Si el upgrade de setuptools
        # funcionó, este intento tambien deberia andar.
        log_info "Fallo --no-build-isolation, reintentando sin el flag..."
        if ! pip3 install --break-system-packages aider-chat; then
            _install_rc=1
        fi
    fi
fi

# ═══════════════════════════════════════════════════
#  Fallback: uv pip install
# ═══════════════════════════════════════════════════
# Si pip falla (numpy compilation u otro error),
# intentar con uv que resuelve mejor dependencias
# con binarios pre-compilados.
if [ "$_install_rc" -ne 0 ]; then
    log_info "pip fallo. Intentando con uv como fallback..."
    if ! command -v uv &>/dev/null; then
        log_info "Instalando uv via curl..."
        if command -v curl &>/dev/null; then
            bash <(curl -fsSL https://astral.sh/uv/install.sh) 2>/dev/null || true
            # uv se instala en ~/.local/bin; refrescar PATH
            export PATH="$HOME/.local/bin:$PATH"
            hash -r
        else
            log_warn "curl no disponible. Intentando via pip..."
            pip3 install uv 2>/dev/null || pip3 install --user uv 2>/dev/null || true
        fi
    fi
    if command -v uv &>/dev/null; then
        log_info "Instalando aider-chat via uv..."
        # ── Intento 1: uv con --no-build ──────────────────────
        # --no-build evita que uv compile numpy desde source:
        # numpy 1.26.4 no tiene wheel ARM64, y compilarlo en un
        # celular con poca RAM causa signal 9 (OOM Killer).
        # numpy pre-compilado del sistema (apt/pkg) debe estar
        # disponible. Si es compatible, uv lo salta automaticamente.
        if uv pip install aider-chat --system --break-system-packages --no-build; then
            _install_rc=0
        else
            # ── Intento 2: uv con --no-deps ────────────────────
            # Si el numpy del sistema no coincide con el pin de
            # aider, uv no puede instalar numpy via --no-build.
            # Solucion: instalar aider sin dependencias y usar
            # numpy del sistema en tiempo de ejecucion.
            log_info "--no-build fallo. Reintentando sin dependencias (usando numpy del sistema)..."
            uv pip install aider-chat --system --break-system-packages --no-deps --no-build && _install_rc=0 || log_warn "uv tampoco pudo instalar aider (intento sin deps)"
        fi
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
    log_info "En proot-Ubuntu/Linux: apt install python3-numpy && pip3 install --user aider-chat"
    log_info "O con uv: apt install python3-numpy && uv pip install aider-chat --no-build"
    exit 1
fi

# ── Cleanup ─────────────────────────────────────────
unset _install_rc _NEXUS_INSTALL_DIR
