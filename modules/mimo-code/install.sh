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
MIMO_ARCH=""
MIMO_TAG=""

# ── _mimo_detect_arch: detecta arquitectura ────────
_mimo_detect_arch() {
    case "$(uname -m)" in
        x86_64|amd64)  MIMO_ARCH="x64"  ;;
        aarch64|arm64) MIMO_ARCH="arm64" ;;
        *) echo "[ERROR] Arquitectura no soportada: $(uname -m)" >&2; return 1 ;;
    esac
    echo "[INFO] Arquitectura detectada: $(uname -m) -> ${MIMO_ARCH}" >&2
}

# ── _mimo_latest_version: tag desde GitHub API ──────
_mimo_latest_version() {
    local _api_url="https://api.github.com/repos/XiaomiMiMo/MiMo-Code/releases/latest"
    MIMO_TAG="$(curl -fsSL "$_api_url" | grep tag_name | sed -E 's/.*"([^"]+)".*/\1/')"
    if [ -z "$MIMO_TAG" ]; then
        echo "[ERROR] No se pudo obtener la ultima version desde GitHub" >&2
        return 1
    fi
    echo "[INFO] Ultima version disponible: ${MIMO_TAG}" >&2
}

# ── _mimo_download: descargar y extraer binario ────
_mimo_download() {
    _dl_url="https://github.com/XiaomiMiMo/MiMo-Code/releases/download/${MIMO_TAG}/mimocode-linux-${MIMO_ARCH}.tar.gz"

    mkdir -p "$MIMO_DATA_DIR"
    echo "[INFO] Descargando mimo ${MIMO_TAG} (linux-${MIMO_ARCH})..." >&2
    curl -fsSL -o "${MIMO_DATA_DIR}/mimo.tar.gz" "$_dl_url" || {
        echo "[ERROR] Fallo descarga desde GitHub" >&2
        return 1
    }

    echo "[INFO] Extrayendo..." >&2
    tar -xzf "${MIMO_DATA_DIR}/mimo.tar.gz" -C "$MIMO_DATA_DIR" || {
        echo "[ERROR] Fallo extraccion" >&2
        rm -f "${MIMO_DATA_DIR}/mimo.tar.gz"
        return 1
    }
    rm -f "${MIMO_DATA_DIR}/mimo.tar.gz"

    if [ ! -f "${MIMO_DATA_DIR}/mimo" ]; then
        echo "[ERROR] No se encontro binario mimo en el tarball" >&2
        ls -la "$MIMO_DATA_DIR" >&2
        return 1
    fi

    chmod +x "${MIMO_DATA_DIR}/mimo"
    echo "[OK] Binario descargado: ${MIMO_DATA_DIR}/mimo" >&2
}

# ════════════════════════════════════════════════════
#  INSTALACION PRINCIPAL
# ════════════════════════════════════════════════════

# Write all output to stderr so gum spin doesn't hide it
exec 3>&1 1>&2

echo "[INFO] Iniciando instalacion de mimo-code..." >&2
echo "[INFO] NEXUS_ENV=${NEXUS_ENV:-unset}" >&2
echo "[INFO] PREFIX=${PREFIX:-unset}" >&2

check_dependency "curl" "curl --version" || exit 1

# ── Detectar arquitectura ─────────────────────────
_mimo_detect_arch || exit 1

# ── Obtener ultima version ─────────────────────────
_mimo_latest_version || exit 1

# ── Branch segun entorno ───────────────────────────
if [ "${NEXUS_ENV:-}" = "termux" ]; then
    # ════════════════════════════════════════════════════
    #  TERMUX NATIVO — glibc + C helper
    # ════════════════════════════════════════════════════

    echo "[INFO] Instalacion nativa Termux con glibc..." >&2

    # PASO 1: Instalar dependencias
    echo "[INFO] PASO 1/3 — Instalando repositorio glibc..." >&2
    pkg install -y glibc-repo 2>&1 || echo "[WARN] glibc-repo ya instalado o no disponible" >&2

    echo "[INFO] PASO 1/3 — Instalando glibc, clang, curl..." >&2
    pkg install -y glibc clang curl 2>&1 || {
        echo "[ERROR] Fallo al instalar dependencias via pkg" >&2
        echo "[INFO] Ejecuta manualmente: pkg install glibc clang curl" >&2
        exit 1
    }

    # Verificar dependencias con mensajes claros
    if ! command -v clang &>/dev/null; then
        echo "[ERROR] clang no encontrado despues de pkg install" >&2
        exit 1
    fi
    echo "[OK] clang disponible" >&2

    # Detectar loader GLIBC dinamicamente
    _loader_name=""
    case "$MIMO_ARCH" in
        arm64) _loader_name="ld-linux-aarch64.so.1" ;;
        x64)   _loader_name="ld-linux-x86-64.so.2" ;;
    esac
    _loader_path="${PREFIX}/glibc/lib/${_loader_name}"

    if [ ! -f "$_loader_path" ]; then
        echo "[ERROR] Loader GLIBC no encontrado: ${_loader_path}" >&2
        echo "[INFO] Contenido de ${PREFIX}/glibc/lib/:" >&2
        ls "${PREFIX}/glibc/lib/" 2>/dev/null || echo "[INFO] (directorio no existe)" >&2
        exit 1
    fi
    echo "[OK] Loader GLIBC encontrado: ${_loader_path}" >&2

    # PASO 2: Descargar binario
    _mimo_download || exit 1

    # PASO 3: Compilar helper C
    echo "[INFO] PASO 3/3 — Compilando helper C..." >&2
    _NEXUS_ROOT="${NEXUS_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
    # shellcheck source=../../lib/nexus-c-helper.sh
    source "${_NEXUS_ROOT}/lib/nexus-c-helper.sh"

    if nexus_c_build "${MIMO_DATA_DIR}/mimo" "mimo"; then
        echo "[OK] Helper C compilado: ${PREFIX}/bin/mimo" >&2
    else
        echo "[ERROR] Fallo compilacion del helper C" >&2
        exit 1
    fi
    unset _NEXUS_ROOT

elif [ "${NEXUS_ENV:-}" = "proot-ubuntu" ]; then
    # ════════════════════════════════════════════════════
    #  PROOT-UBUNTU — descarga directa a /usr/local/bin
    # ════════════════════════════════════════════════════
    echo "[INFO] Entorno proot-Ubuntu — descargando binario..." >&2
    _mimo_download || exit 1
    cp "${MIMO_DATA_DIR}/mimo" /usr/local/bin/mimo
    chmod +x /usr/local/bin/mimo
else
    # ════════════════════════════════════════════════════
    #  LINUX — descarga directa a /usr/local/bin
    # ════════════════════════════════════════════════════
    echo "[INFO] Entorno Linux — descargando binario..." >&2
    _mimo_download || exit 1
    cp "${MIMO_DATA_DIR}/mimo" /usr/local/bin/mimo
    chmod +x /usr/local/bin/mimo
fi

# ── Verificacion final ─────────────────────────────
# Restore stdout for mark_installed/log functions
exec 1>&3 3>&-

if command -v mimo &>/dev/null; then
    _v="$(mimo --version 2>/dev/null || true)"
    mark_installed "mimo-code" "${_v:-${MIMO_TAG}}"
    echo "[OK] mimo-code instalado correctamente (${_v:-v${MIMO_TAG}})" >&2
else
    echo "[ERROR] mimo-code no encontrado en PATH. Revisa la instalacion manual." >&2
    exit 1
fi

unset MIMO_TAG MIMO_DATA_DIR MIMO_ARCH
unset _dl_url _loader_name _loader_path _v
