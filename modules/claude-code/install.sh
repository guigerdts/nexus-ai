#!/usr/bin/env bash
# modules/claude-code/install.sh
# Instala Claude Code CLI desde GitHub releases
# Termux nativo: glibc + C helper (mismo patron que agy)
# proot-Ubuntu: bootstrap oficial dentro de proot
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── Constantes ─────────────────────────────────────
CLAUDE_DATA_DIR="${HOME}/.local/share/nexus-ai/claude"
CLAUDE_TAG=""    # set por _claude_latest_version

# ── _claude_latest_version: tag desde GitHub API ───
_claude_latest_version() {
    local _api_url="https://api.github.com/repos/anthropics/claude-code/releases/latest"
    CLAUDE_TAG="$(curl -fsSL "$_api_url" | grep tag_name | sed -E 's/.*"([^"]+)".*/\1/')"
    if [ -z "$CLAUDE_TAG" ]; then
        log_error "No se pudo obtener la ultima version desde GitHub"
        return 1
    fi
    log_info "Ultima version disponible: ${CLAUDE_TAG}"
}

# ── _claude_download: descargar y extraer binario ──
_claude_download() {
    local _arch
    case "$(uname -m)" in
        x86_64|amd64)  _arch="x64"  ;;
        aarch64|arm64) _arch="arm64" ;;
        *) log_error "Arquitectura no soportada: $(uname -m)"; return 1 ;;
    esac

    _dl_url="https://github.com/anthropics/claude-code/releases/download/${CLAUDE_TAG}/claude-linux-${_arch}.tar.gz"

    mkdir -p "$CLAUDE_DATA_DIR"
    log_info "Descargando claude ${CLAUDE_TAG} (linux-${_arch})..."
    curl -fsSL -o "${CLAUDE_DATA_DIR}/claude.tar.gz" "$_dl_url" || {
        log_error "Fallo descarga desde GitHub"
        return 1
    }

    log_info "Extrayendo..."
    tar -xzf "${CLAUDE_DATA_DIR}/claude.tar.gz" -C "$CLAUDE_DATA_DIR" || {
        log_error "Fallo extraccion"
        rm -f "${CLAUDE_DATA_DIR}/claude.tar.gz"
        return 1
    }
    rm -f "${CLAUDE_DATA_DIR}/claude.tar.gz"

    if [ ! -f "${CLAUDE_DATA_DIR}/claude" ]; then
        log_error "No se encontro binario claude en el tarball"
        ls -la "$CLAUDE_DATA_DIR"
        return 1
    fi

    chmod +x "${CLAUDE_DATA_DIR}/claude"
    log_ok "Binario descargado: ${CLAUDE_DATA_DIR}/claude"
}

# ════════════════════════════════════════════════════
#  INSTALACION PRINCIPAL
# ════════════════════════════════════════════════════

check_dependency "curl" "curl --version" || exit 1

# ── Obtener ultima version ─────────────────────────
_claude_latest_version || exit 1

# ── Branch segun entorno ───────────────────────────
if [ "${NEXUS_ENV:-}" = "termux" ]; then
    # ════════════════════════════════════════════════════
    #  OPCION 1 — Termux nativo con glibc + C helper
    # ════════════════════════════════════════════════════

    log_info "OPCION 1 — Instalacion nativa Termux con glibc..."

    # PASO 1: Instalar dependencias
    log_info "PASO 1/3 — Instalando dependencias (glibc + herramientas)..."
    pkg install -y glibc-repo 2>/dev/null || true
    pkg install -y glibc clang curl -y 2>/dev/null || {
        log_warn "Fallo al instalar dependencias via pkg"
        log_info "Saltando a OPCION 2 (proot-Ubuntu)..."
        # falla a OPCION 2 abajo
    }

    if command -v clang &>/dev/null && [ -f "${PREFIX:-/data/data/com.termux/files/usr}/glibc/lib/ld-linux-aarch64.so.1" ]; then
        # ── Dependencias OK, continuar con instalacion nativa ──

        # PASO 2: Descargar binario
        _claude_download || {
            log_warn "Fallo descarga del binario"
            log_info "Saltando a OPCION 2 (proot-Ubuntu)..."
            OPCION2_FALLBACK=1
        }

        if [ -z "${OPCION2_FALLBACK:-}" ] && [ -f "${CLAUDE_DATA_DIR}/claude" ]; then
            # PASO 3: Compilar helper C
            log_info "PASO 3/3 — Compilando helper C con clang..."
            _prefix="${PREFIX:-/data/data/com.termux/files/usr}"
            _loader="${_prefix}/glibc/lib/ld-linux-aarch64.so.1"
            _lib_path="${_prefix}/glibc/lib"
            _cert_path="${_prefix}/etc/tls/cert.pem"
            _real_bin="${CLAUDE_DATA_DIR}/claude"

            cat > "${TMPDIR:-/tmp}/claude_helper.c" << C_CODE
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
        "${_real_bin}";
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

            clang -O2 -o "${_prefix}/bin/claude" "${TMPDIR:-/tmp}/claude_helper.c" || {
                log_error "Fallo compilacion del helper C"
                rm -f "${TMPDIR:-/tmp}/claude_helper.c"
                log_info "Saltando a OPCION 2 (proot-Ubuntu)..."
                OPCION2_FALLBACK=1
            }

            if [ -z "${OPCION2_FALLBACK:-}" ]; then
                chmod +x "${_prefix}/bin/claude"
                rm -f "${TMPDIR:-/tmp}/claude_helper.c"
                log_ok "Helper C compilado: ${_prefix}/bin/claude"
            fi
        fi
    else
        log_warn "Dependencias glibc no disponibles en Termux"
        log_info "Saltando a OPCION 2 (proot-Ubuntu)..."
        OPCION2_FALLBACK=1
    fi

    # ── OPCION 2 — Fallback a proot-Ubuntu ─────────
    if [ -n "${OPCION2_FALLBACK:-}" ]; then
        log_info "OPCION 2 — Instalando via proot-Ubuntu..."

        if command -v proot-distro &>/dev/null; then
            log_info "Ejecutando bootstrap oficial dentro de proot-Ubuntu..."
            proot-distro login ubuntu -- /bin/bash -c \
                "curl -fsSL https://claude.ai/install.sh | bash" || {
                log_error "Fallo instalacion via proot-Ubuntu"
                exit 1
            }

            # Crear wrapper en Termux
            _prefix="${PREFIX:-/data/data/com.termux/files/usr}"
            cat > "${_prefix}/bin/claude" << 'WRAPPER'
#!/data/data/com.termux/files/usr/bin/bash
proot-distro login ubuntu -- /root/.local/bin/claude "$@"
WRAPPER
            chmod +x "${_prefix}/bin/claude"
            log_ok "Wrapper proot creado: ${_prefix}/bin/claude"
        else
            log_error "proot-distro no disponible. No se puede instalar claude-code."
            exit 1
        fi
    fi

elif [ "${NEXUS_ENV:-}" = "proot-ubuntu" ]; then
    # ════════════════════════════════════════════════════
    #  PROOT-UBUNTU — bootstrap oficial directo
    # ════════════════════════════════════════════════════
    log_info "Entorno proot-Ubuntu — ejecutando bootstrap oficial..."
    curl -fsSL https://claude.ai/install.sh | bash || {
        log_error "Fallo bootstrap oficial de claude-code"
        exit 1
    }
else
    # ════════════════════════════════════════════════════
    #  LINUX — bootstrap oficial directo
    # ════════════════════════════════════════════════════
    log_info "Entorno Linux — ejecutando bootstrap oficial..."
    curl -fsSL https://claude.ai/install.sh | bash || {
        log_error "Fallo bootstrap oficial de claude-code"
        exit 1
    }
fi

# ── Verificacion final ──────────────────────────────
if command -v claude &>/dev/null; then
    _v="$(claude --version 2>/dev/null || true)"
    mark_installed "claude-code" "${_v:-${CLAUDE_TAG}}"
    log_ok "claude-code instalado correctamente (${_v:-v${CLAUDE_TAG}})"
elif [ -f "${PREFIX:-/data/data/com.termux/files/usr}/bin/claude" ]; then
    _v="$("${PREFIX}/bin/claude" --version 2>/dev/null || true)"
    mark_installed "claude-code" "${_v:-${CLAUDE_TAG}}"
    log_ok "claude-code instalado (${_v:-v${CLAUDE_TAG}})"
else
    log_error "claude-code no encontrado en PATH. Revisa la instalacion manual."
    exit 1
fi

unset CLAUDE_TAG CLAUDE_DATA_DIR OPCION2_FALLBACK
unset _arch _dl_url _prefix _loader _lib_path _cert_path _real_bin _v
