#!/usr/bin/env bash
# modules/mimo-code/install.sh
# Instala MiMo Code desde GitHub releases
# Termux nativo: glibc + C helper (mismo patron que claude-code)
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── Constantes ─────────────────────────────────────
MIMO_DATA_DIR="${HOME}/.local/share/nexus-ai/mimocode"
MIMO_TAG=""    # set por _mimo_latest_version

# ── _mimo_latest_version: tag desde GitHub API ──────
_mimo_latest_version() {
    local _api_url="https://api.github.com/repos/XiaomiMiMo/MiMo-Code/releases/latest"
    MIMO_TAG="$(curl -fsSL "$_api_url" | grep tag_name | sed -E 's/.*"([^"]+)".*/\1/')"
    if [ -z "$MIMO_TAG" ]; then
        log_error "No se pudo obtener la ultima version desde GitHub"
        return 1
    fi
    log_info "Ultima version disponible: ${MIMO_TAG}"
}

# ── _mimo_download: descargar y extraer binario ────
_mimo_download() {
    local _arch
    case "$(uname -m)" in
        x86_64|amd64)  _arch="x64"  ;;
        aarch64|arm64) _arch="arm64" ;;
        *) log_error "Arquitectura no soportada: $(uname -m)"; return 1 ;;
    esac

    _dl_url="https://github.com/XiaomiMiMo/MiMo-Code/releases/download/${MIMO_TAG}/mimocode-linux-${_arch}.tar.gz"

    mkdir -p "$MIMO_DATA_DIR"
    log_info "Descargando mimo ${MIMO_TAG} (linux-${_arch})..."
    curl -fsSL -o "${MIMO_DATA_DIR}/mimo.tar.gz" "$_dl_url" || {
        log_error "Fallo descarga desde GitHub"
        return 1
    }

    log_info "Extrayendo..."
    tar -xzf "${MIMO_DATA_DIR}/mimo.tar.gz" -C "$MIMO_DATA_DIR" || {
        log_error "Fallo extraccion"
        rm -f "${MIMO_DATA_DIR}/mimo.tar.gz"
        return 1
    }
    rm -f "${MIMO_DATA_DIR}/mimo.tar.gz"

    if [ ! -f "${MIMO_DATA_DIR}/mimo" ]; then
        log_error "No se encontro binario mimo en el tarball"
        ls -la "$MIMO_DATA_DIR"
        return 1
    fi

    chmod +x "${MIMO_DATA_DIR}/mimo"
    log_ok "Binario descargado: ${MIMO_DATA_DIR}/mimo"
}

# ════════════════════════════════════════════════════
#  INSTALACION PRINCIPAL
# ════════════════════════════════════════════════════

check_dependency "curl" "curl --version" || exit 1

# ── Obtener ultima version ─────────────────────────
_mimo_latest_version || exit 1

# ── Branch segun entorno ───────────────────────────
if [ "${NEXUS_ENV:-}" = "termux" ]; then
    # ════════════════════════════════════════════════════
    #  TERMUX NATIVO — glibc + C helper
    # ════════════════════════════════════════════════════

    log_info "Instalacion nativa Termux con glibc..."

    # PASO 1: Instalar dependencias
    log_info "PASO 1/3 — Instalando dependencias (glibc + herramientas)..."
    pkg install -y glibc-repo 2>/dev/null || true
    pkg install -y glibc clang curl 2>/dev/null || {
        log_error "Fallo al instalar dependencias via pkg"
        exit 1
    }

    if ! command -v clang &>/dev/null || [ ! -f "${PREFIX}/glibc/lib/ld-linux-aarch64.so.1" ]; then
        log_error "Dependencias glibc incompletas en Termux"
        exit 1
    fi

    # PASO 2: Descargar binario
    _mimo_download || exit 1

    # PASO 3: Compilar helper C
    log_info "PASO 3/3 — Compilando helper C..."
    NEXUS_ROOT="${NEXUS_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
    # shellcheck source=../../lib/nexus-c-helper.sh
    source "${NEXUS_ROOT}/lib/nexus-c-helper.sh"

    if nexus_c_build "${MIMO_DATA_DIR}/mimo" "mimo"; then
        log_ok "Helper C compilado: ${PREFIX}/bin/mimo"
    else
        log_error "Fallo compilacion del helper C"
        exit 1
    fi

elif [ "${NEXUS_ENV:-}" = "proot-ubuntu" ]; then
    # ════════════════════════════════════════════════════
    #  PROOT-UBUNTU — descarga directa a /usr/local/bin
    # ════════════════════════════════════════════════════
    log_info "Entorno proot-Ubuntu — descargando binario..."
    _mimo_download || exit 1
    cp "${MIMO_DATA_DIR}/mimo" /usr/local/bin/mimo
    chmod +x /usr/local/bin/mimo
else
    # ════════════════════════════════════════════════════
    #  LINUX — descarga directa a /usr/local/bin
    # ════════════════════════════════════════════════════
    log_info "Entorno Linux — descargando binario..."
    _mimo_download || exit 1
    cp "${MIMO_DATA_DIR}/mimo" /usr/local/bin/mimo
    chmod +x /usr/local/bin/mimo
fi

# ── Verificacion final ─────────────────────────────
if command -v mimo &>/dev/null; then
    _v="$(mimo --version 2>/dev/null || true)"
    mark_installed "mimo-code" "${_v:-${MIMO_TAG}}"
    log_ok "mimo-code instalado correctamente (${_v:-v${MIMO_TAG}})"
else
    log_error "mimo-code no encontrado en PATH. Revisa la instalacion manual."
    exit 1
fi

unset MIMO_TAG MIMO_DATA_DIR
unset _arch _dl_url _v
