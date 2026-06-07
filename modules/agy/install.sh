#!/usr/bin/env bash
# modules/agy/install.sh
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── detect_antigravity_platform: detect os/arch for antigravity manifest ──
detect_antigravity_platform() {
    local _os _arch

    case "$(uname -s)" in
        Darwin) _os="darwin" ;;
        Linux)  _os="linux"  ;;
        *)      log_error "Sistema operativo no soportado: $(uname -s)"; return 1 ;;
    esac

    case "$(uname -m)" in
        x86_64|amd64)   _arch="amd64" ;;
        aarch64|arm64)  _arch="arm64" ;;
        *)              log_error "Arquitectura no soportada: $(uname -m)"; return 1 ;;
    esac

    # musl detection on Linux
    if [ "$_os" = "linux" ]; then
        if ldd /bin/ls 2>&1 | grep -q musl; then
            echo "linux_${_arch}_musl"
        else
            echo "linux_${_arch}"
        fi
    else
        echo "${_os}_${_arch}"
    fi
}

# ── Verificar dependencias ─────────────────────────
check_dependency "curl" "curl --version" || exit 1

# ── Detectar plataforma y obtener manifest ─────────
_platform="$(detect_antigravity_platform)" || exit 1
_manifest_url="https://antigravity-cli-auto-updater-974169037036.us-central1.run.app/manifests/${_platform}.json"

log_info "Detectada plataforma: ${_platform}"
log_info "Consultando manifest: ${_manifest_url}"

_manifest_json="$(curl -fsSL "$_manifest_url")" || {
    log_error "No se pudo obtener el manifest de antigravity"
    exit 1
}

# Parse version and download URL from JSON (POSIX-safe)
_version="$(echo "$_manifest_json" | sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')"
_download_url="$(echo "$_manifest_json" | sed -n 's/.*"url"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')"

if [ -z "$_download_url" ]; then
    log_error "No se encontro URL de descarga en el manifest"
    exit 1
fi

log_info "Version disponible: ${_version:-latest}"

# ── Instalar via binary con soporte GLIBC ──────────
# install_via_binary maneja:
#   - descarga del tarball
#   - extraccion del binario
#   - creacion de wrapper GLIBC en Termux
install_via_binary "agy" "$_download_url" "agy" || {
    log_error "Fallo la instalacion de agy"
    exit 1
}

# ── Verificar instalacion ──────────────────────────
# En Termux, el binario esta en $NEXUS_ROOT/bin/agy o en PREFIX/bin/agy (wrapper)
if command -v agy &>/dev/null; then
    _v="$(agy --version 2>/dev/null || true)"
    mark_installed "agy" "$_v"
    log_ok "agy instalado correctamente (${_v:-version ${_version}})"
else
    # Maybe installed to NEXUS_ROOT/bin but not in PATH yet
    if [ -f "${NEXUS_ROOT}/bin/agy" ]; then
        _v="$("${NEXUS_ROOT}/bin/agy" --version 2>/dev/null || true)"
        mark_installed "agy" "$_v"
        log_ok "agy instalado en ${NEXUS_ROOT}/bin/agy (${_v:-version ${_version}})"
        log_info "Agrega ${NEXUS_ROOT}/bin a tu PATH si no esta."
    else
        log_error "agy no se encuentra en PATH ni en ${NEXUS_ROOT}/bin/agy"
        exit 1
    fi
fi

unset _platform _manifest_url _manifest_json _version _download_url _v
