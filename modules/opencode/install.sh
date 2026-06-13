#!/usr/bin/env bash
# modules/opencode/install.sh
# Instala OpenCode desde GitHub releases (binario estatico, no npm)
# Termux nativo: glibc + C helper (mismo patron que claude-code/mimo-code)
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── Constantes ─────────────────────────────────────
OPENCODE_DATA_DIR="${HOME}/.local/share/nexus-ai/opencode"
OPENCODE_ARCH=""
OPENCODE_TAG=""

# Redirect all output to stderr so gum spin doesn't hide it
exec 3>&1 1>&2

echo "[INFO] Iniciando instalacion de opencode..." >&2

check_dependency "curl" "curl --version" || exit 1

# ── _opencode_detect_arch ──────────────────────────
_opencode_detect_arch() {
    case "$(uname -m)" in
        x86_64|amd64)  OPENCODE_ARCH="x86_64"  ;;
        aarch64|arm64) OPENCODE_ARCH="arm64" ;;
        *) echo "[ERROR] Arquitectura no soportada: $(uname -m)" >&2; return 1 ;;
    esac
    echo "[INFO] Arquitectura detectada: $(uname -m) -> ${OPENCODE_ARCH}" >&2
}

# ── _opencode_latest_version: tag desde GitHub API ─
_opencode_latest_version() {
    local _api_url="https://api.github.com/repos/opencode-ai/opencode/releases/latest"
    OPENCODE_TAG="$(curl -fsSL "$_api_url" | grep tag_name | sed -E 's/.*"([^"]+)".*/\1/')"
    if [ -z "$OPENCODE_TAG" ]; then
        echo "[ERROR] No se pudo obtener la ultima version desde GitHub" >&2
        return 1
    fi
    echo "[INFO] Ultima version disponible: ${OPENCODE_TAG}" >&2
}

# ── _opencode_download: descargar y extraer binario ─
_opencode_download() {
    _dl_url="https://github.com/opencode-ai/opencode/releases/download/${OPENCODE_TAG}/opencode-linux-${OPENCODE_ARCH}.tar.gz"

    mkdir -p "$OPENCODE_DATA_DIR"
    echo "[INFO] Descargando opencode ${OPENCODE_TAG} (linux-${OPENCODE_ARCH})..." >&2
    curl -fsSL -o "${OPENCODE_DATA_DIR}/opencode.tar.gz" "$_dl_url" || {
        echo "[ERROR] Fallo descarga desde GitHub" >&2
        return 1
    }

    echo "[INFO] Extrayendo..." >&2
    tar -xzf "${OPENCODE_DATA_DIR}/opencode.tar.gz" -C "$OPENCODE_DATA_DIR" || {
        echo "[ERROR] Fallo extraccion" >&2
        rm -f "${OPENCODE_DATA_DIR}/opencode.tar.gz"
        return 1
    }
    rm -f "${OPENCODE_DATA_DIR}/opencode.tar.gz"

    if [ ! -f "${OPENCODE_DATA_DIR}/opencode" ]; then
        echo "[ERROR] No se encontro binario opencode en el tarball" >&2
        ls -la "$OPENCODE_DATA_DIR" >&2
        return 1
    fi

    chmod +x "${OPENCODE_DATA_DIR}/opencode"
    echo "[OK] Binario descargado: ${OPENCODE_DATA_DIR}/opencode" >&2
}

# ════════════════════════════════════════════════════
#  INSTALACION PRINCIPAL
# ════════════════════════════════════════════════════

_opencode_detect_arch || exit 1
_opencode_latest_version || exit 1

if [ "${NEXUS_ENV:-}" = "termux" ]; then
    # ════════════════════════════════════════════════════
    #  TERMUX NATIVO — glibc + C helper
    # ════════════════════════════════════════════════════

    echo "[INFO] Instalacion nativa Termux con glibc..." >&2

    echo "[INFO] PASO 1/3 — Instalando repositorio glibc..." >&2
    pkg install -y glibc-repo 2>&1 || echo "[WARN] glibc-repo ya instalado o no disponible" >&2

    echo "[INFO] PASO 1/3 — Instalando glibc, clang, curl..." >&2
    pkg install -y glibc clang curl 2>&1 || {
        echo "[ERROR] Fallo al instalar dependencias via pkg" >&2
        echo "[INFO] Ejecuta manualmente: pkg install glibc clang curl" >&2
        exit 1
    }

    if ! command -v clang &>/dev/null; then
        echo "[ERROR] clang no encontrado despues de pkg install" >&2
        exit 1
    fi
    echo "[OK] clang disponible" >&2

    # Detectar loader GLIBC
    _loader_name=""
    case "$OPENCODE_ARCH" in
        arm64) _loader_name="ld-linux-aarch64.so.1" ;;
        x86_64) _loader_name="ld-linux-x86-64.so.2" ;;
    esac
    _loader_path="${PREFIX}/glibc/lib/${_loader_name}"

    if [ ! -f "$_loader_path" ]; then
        echo "[ERROR] Loader GLIBC no encontrado: ${_loader_path}" >&2
        ls "${PREFIX}/glibc/lib/" 2>/dev/null || echo "[INFO] (directorio no existe)" >&2
        exit 1
    fi
    echo "[OK] Loader GLIBC encontrado: ${_loader_path}" >&2

    # PASO 2: Descargar binario
    _opencode_download || exit 1

    # PASO 3: Compilar helper C
    echo "[INFO] PASO 3/3 — Compilando helper C..." >&2
    _NEXUS_ROOT="${NEXUS_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
    # shellcheck source=../../lib/nexus-c-helper.sh
    source "${_NEXUS_ROOT}/lib/nexus-c-helper.sh"

    if nexus_c_build "${OPENCODE_DATA_DIR}/opencode" "opencode"; then
        echo "[OK] Helper C compilado: ${PREFIX}/bin/opencode" >&2
    else
        echo "[ERROR] Fallo compilacion del helper C" >&2
        exit 1
    fi
    unset _NEXUS_ROOT

elif [ "${NEXUS_ENV:-}" = "proot-ubuntu" ]; then
    echo "[INFO] Entorno proot-Ubuntu — descargando binario..." >&2
    _opencode_download || exit 1
    cp "${OPENCODE_DATA_DIR}/opencode" /usr/local/bin/opencode
    chmod +x /usr/local/bin/opencode
else
    echo "[INFO] Entorno Linux — descargando binario..." >&2
    _opencode_download || exit 1
    cp "${OPENCODE_DATA_DIR}/opencode" /usr/local/bin/opencode
    chmod +x /usr/local/bin/opencode
fi

# ── Verificacion final ─────────────────────────────
exec 1>&3 3>&-

if command -v opencode &>/dev/null; then
    _v="$(opencode --version 2>/dev/null || true)"
    mark_installed "opencode" "${_v:-${OPENCODE_TAG}}"
    echo "[OK] opencode instalado correctamente (${_v:-v${OPENCODE_TAG}})" >&2
else
    echo "[ERROR] opencode no encontrado en PATH. Revisa la instalacion manual." >&2
    exit 1
fi

unset OPENCODE_TAG OPENCODE_DATA_DIR OPENCODE_ARCH
unset _dl_url _loader_name _loader_path _v
