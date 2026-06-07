#!/usr/bin/env bash
# modules/agy/install.sh
# Instala Antigravity CLI (agy) — reemplazo oficial de gemini-cli
# Termux nativo: glibc + VA39 patch + helper C (NO wrapper bash)
# proot-Ubuntu/Linux: binario glibc directo
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── Constantes ─────────────────────────────────────
MANIFEST_BASE="https://antigravity-cli-auto-updater-974169037036.us-central1.run.app"
AGY_DATA_DIR="${HOME}/.local/share/nexus-ai/antigravity-cli"

# ── Variables globales para valores de retorno ─────
AGY_BINARY=""       # path al binario descargado (set por download_agy_binary)
AGY_VERSION=""      # version extraida del manifest

# ── detect_platform: os/arch para manifest ─────────
detect_platform() {
    local _os _arch
    case "$(uname -s)" in
        Darwin) _os="darwin" ;;
        Linux)  _os="linux"  ;;
        *)      log_error "OS no soportado: $(uname -s)"; return 1 ;;
    esac
    case "$(uname -m)" in
        x86_64|amd64)   _arch="amd64" ;;
        aarch64|arm64)  _arch="arm64" ;;
        *)              log_error "Arquitectura no soportada: $(uname -m)"; return 1 ;;
    esac
    # musl detection
    if [ "$_os" = "linux" ] && ldd /bin/ls 2>&1 | grep -q musl; then
        echo "linux_${_arch}_musl"
    else
        echo "linux_${_arch}"
    fi
}

# ── PASO COMUN: descargar binario desde manifest ───
download_agy_binary() {
    local _platform="$1"
    local _manifest_url="${MANIFEST_BASE}/manifests/${_platform}.json"

    log_info "Descargando manifest: ${_manifest_url}"
    local _manifest_json
    _manifest_json="$(curl -fsSL "$_manifest_url")" || {
        log_error "No se pudo obtener manifest para ${_platform}"
        return 1
    }

    AGY_VERSION="$(echo "$_manifest_json" | jq -r '.version // empty')"
    local _download_url
    _download_url="$(echo "$_manifest_json" | jq -r '.url // empty')"

    if [ -z "$_download_url" ]; then
        log_error "URL de descarga vacia en manifest"
        return 1
    fi

    mkdir -p "$AGY_DATA_DIR"
    log_info "Descargando agy v${AGY_VERSION:-?} desde ${_download_url}..."
    curl -fsSL -o "${AGY_DATA_DIR}/agy.tar.gz" "$_download_url" || {
        log_error "Fallo descarga"
        return 1
    }

    log_info "Extrayendo..."
    tar -xzf "${AGY_DATA_DIR}/agy.tar.gz" -C "$AGY_DATA_DIR" || {
        log_error "Fallo extraccion"
        rm -f "${AGY_DATA_DIR}/agy.tar.gz"
        return 1
    }
    rm -f "${AGY_DATA_DIR}/agy.tar.gz"

    # Buscar el binario — puede llamarse agy o antigravity
    AGY_BINARY=""
    for _candidate in agy antigravity; do
        if [ -f "${AGY_DATA_DIR}/${_candidate}" ]; then
            AGY_BINARY="${AGY_DATA_DIR}/${_candidate}"
            chmod +x "$AGY_BINARY"
            break
        fi
    done

    if [ -z "$AGY_BINARY" ]; then
        log_error "No se encontro binario agy/antigravity en el tarball"
        ls -la "$AGY_DATA_DIR"
        return 1
    fi
}

# ════════════════════════════════════════════════════
#  INSTALACION PRINCIPAL
# ════════════════════════════════════════════════════

check_dependency "curl" "curl --version" || exit 1

_platform="$(detect_platform)" || exit 1
log_info "Plataforma detectada: ${_platform}"

# ── Descargar binario (comun a todos los entornos) ─
download_agy_binary "$_platform" || exit 1
AGY_VERSION="${AGY_VERSION:-0.0.0}"

# ── Branch segun entorno ───────────────────────────
if [ "${NEXUS_ENV:-}" = "termux" ]; then
    # ════════════════════════════════════════════════════
    #  TERMUX NATIVO — 4 pasos obligatorios
    # ════════════════════════════════════════════════════

    # PASO 1: Instalar dependencias
    log_info "PASO 1/4 — Instalando dependencias (glibc + herramientas)..."
    pkg install -y glibc-repo 2>/dev/null || true
    pkg install -y glibc clang python jq curl -y 2>/dev/null || {
        log_error "Fallo al instalar dependencias via pkg"
        exit 1
    }

    _prefix="${PREFIX:-/data/data/com.termux/files/usr}"

    # PASO 2: Descargar ya hecho en AGY_BINARY
    log_info "PASO 2/4 — Binario descargado en ${AGY_BINARY}"

    # PASO 3: Aplicar parches VA39 (obligatorio Android aarch64)
    log_info "PASO 3/4 — Aplicando parches VA39 para compatibilidad Android..."
    python3 - "$AGY_BINARY" "${AGY_DATA_DIR}/agy.va39" << 'PY'
import sys, shutil, struct, pathlib
src = pathlib.Path(sys.argv[1])
dst = pathlib.Path(sys.argv[2])
shutil.copyfile(src, dst)
data = bytearray(dst.read_bytes())
def get(off): return struct.unpack_from("<I", data, off)[0]
def put(off, word): struct.pack_into("<I", data, off, word)
lo, hi = 0, len(data)
for off in range(lo, hi, 4):
    w = get(off)
    if (w & 0x7F800000) == 0x53000000:
        immr, imms = (w >> 16) & 0x3F, (w >> 10) & 0x3F
        if immr == 42 and imms == 44:
            put(off, (w & ~((0x3F << 16) | (0x3F << 10))) | (35 << 16) | (37 << 10))
        elif immr == 22 and imms == 21:
            put(off, (w & ~((0x3F << 16) | (0x3F << 10))) | (29 << 16) | (28 << 10))
for off in range(lo, hi - 4, 4):
    if get(off) == 0x92D3800A and get(off + 4) == 0xF2E0000A:
        put(off, 0x9280000A); put(off + 4, 0xD35DFD4A)
for off in range(lo, hi, 4):
    if get(off) == 0xF2E00029: put(off, 0xD3596129)
word_rewrites = {
    0xD2C20009: 0xD2C00409, 0xD2C2000A: 0xD2C0040A, 0xF2C20008: 0xF2DFF408,
    0xF2C20009: 0xF2DFF409, 0xD2C10009: 0xD2C00209, 0xD2C1000A: 0xD2C0020A,
    0xF2C38008: 0xF2DFF708, 0xF2C38009: 0xF2DFF709, 0x92560A6C: 0x925D0A6C,
    0x92560A6A: 0x925D0A6A, 0xD2C3000D: 0xD2C0060D, 0xD2C3000C: 0xD2C0060C,
    0xD2C08008: 0xD2C00108,
}
for off in range(lo, hi, 4):
    w = get(off)
    if w in word_rewrites: put(off, word_rewrites[w])
for off in range(0, len(data) - 12, 4):
    if get(off) == 0xAA1F03E5 and get(off + 4) == 0xAA1F03E6 and get(off + 8) == 0xD28036E0 and (get(off + 12) & 0xFC000000) == 0x94000000:
        put(off + 8, 0xD2800600)
dst.write_bytes(data)
PY
    chmod +x "${AGY_DATA_DIR}/agy.va39"
    log_ok "Parche VA39 aplicado: ${AGY_DATA_DIR}/agy.va39"

    # PASO 4: Compilar helper C (NO wrapper bash)
    log_info "PASO 4/4 — Compilando helper C con clang..."
    _loader="${_prefix}/glibc/lib/ld-linux-aarch64.so.1"
    _lib_path="${_prefix}/glibc/lib"
    _cert_path="${_prefix}/etc/tls/cert.pem"
    _home="${HOME}"

    cat > "/tmp/agy_helper.c" << C_CODE
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <libgen.h>
#include <limits.h>
#include <stdio.h>
int main(int argc, char** argv) {
    unsetenv("LD_PRELOAD");
    unsetenv("LD_LIBRARY_PATH");
    setenv("GODEBUG", "netdns=cgo", 1);
    setenv("SSL_CERT_FILE",
        "${_cert_path}", 1);
    char* loader =
        "${_loader}";
    char real_bin[] =
        "${AGY_DATA_DIR}/agy.va39";
    char lib_path[] =
        "${_lib_path}";
    char** new_argv = malloc((argc + 4) * sizeof(char*));
    if (!new_argv) return 1;
    new_argv[0] = loader;
    new_argv[1] = "--library-path";
    new_argv[2] = lib_path;
    new_argv[3] = real_bin;
    for (int i = 1; i < argc; i++) {
        new_argv[i + 3] = argv[i];
    }
    new_argv[argc + 3] = NULL;
    execv(loader, new_argv);
    perror("execv");
    free(new_argv);
    return 1;
}
C_CODE

    clang -O2 -o "${_prefix}/bin/agy" "/tmp/agy_helper.c" || {
        log_error "Fallo compilacion del helper C"
        rm -f "/tmp/agy_helper.c"
        exit 1
    }
    chmod +x "${_prefix}/bin/agy"
    rm -f "/tmp/agy_helper.c"
    log_ok "Helper C compilado: ${_prefix}/bin/agy"

elif [ "${NEXUS_ENV:-}" = "proot-ubuntu" ]; then
    # ════════════════════════════════════════════════════
    #  PROOT-UBUNTU — binario glibc directo
    # ════════════════════════════════════════════════════
    log_info "Entorno proot-Ubuntu — instalando binario glibc directo..."
    install_via_binary "agy" "file://${AGY_BINARY}" "agy" 2>/dev/null || {
        # Fallback: copia directa
        cp "$AGY_BINARY" "${NEXUS_ROOT}/bin/agy"
        chmod +x "${NEXUS_ROOT}/bin/agy"
    }
else
    # ════════════════════════════════════════════════════
    #  LINUX — binario glibc directo
    # ════════════════════════════════════════════════════
    log_info "Entorno Linux — instalando binario..."
    install_via_binary "agy" "file://${AGY_BINARY}" "agy" 2>/dev/null || {
        cp "$AGY_BINARY" "${NEXUS_ROOT}/bin/agy"
        chmod +x "${NEXUS_ROOT}/bin/agy"
    }
fi

# ── Verificacion final ──────────────────────────────
if command -v agy &>/dev/null; then
    _v="$(agy --version 2>/dev/null || true)"
    mark_installed "agy" "$_v"
    log_ok "agy instalado correctamente (${_v:-v${AGY_VERSION}})"
elif [ -f "${NEXUS_ROOT}/bin/agy" ]; then
    _v="$("${NEXUS_ROOT}/bin/agy" --version 2>/dev/null || true)"
    mark_installed "agy" "$_v"
    log_ok "agy instalado en ${NEXUS_ROOT}/bin/agy (${_v:-v${AGY_VERSION}})"
else
    log_error "agy no encontrado en PATH. Revisa la instalacion manual."
    exit 1
fi

unset _platform _manifest_url _manifest_json _download_url
unset _loader _lib_path _cert_path _home _prefix
unset AGY_BINARY AGY_VERSION
