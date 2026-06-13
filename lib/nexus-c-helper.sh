#!/usr/bin/env bash
# NEXUS AI — lib/nexus-c-helper.sh
# GLIBC loader wrapper compilation for Termux bionic environment
# Version: 0.8.2
#
# Compila un pequeño programa C que ejecuta binarios ELF (GLIBC) via
# ld-linux, necesario porque Termux usa Bionic libc en vez de GLIBC.
#
# Dependencias: clang, $PREFIX/glibc/lib/ld-linux-*.so.1

set -euo pipefail

# ── Config ────────────────────────────────────────
_NEXUS_C_ARCH="$(uname -m 2>/dev/null || echo "aarch64")"
case "$_NEXUS_C_ARCH" in
    aarch64|arm64)
        _NEXUS_C_LOADER="ld-linux-aarch64.so.1"
        ;;
    x86_64|amd64)
        _NEXUS_C_LOADER="ld-linux-x86-64.so.2"
        ;;
    *)
        _NEXUS_C_LOADER="ld-linux-aarch64.so.1"
        ;;
esac

# ── nexus_c_check_deps: verifica herramientas necesarias ──
# Uso: nexus_c_check_deps
# Returns: 0 si todo ok, 1 si falta algo
nexus_c_check_deps() {
    local _missing=0

    if ! command -v clang &>/dev/null; then
        log_error "clang no instalado. Ejecuta: pkg install clang"
        _missing=1
    fi

    local _prefix="${PREFIX:-/data/data/com.termux/files/usr}"
    local _loader="$_prefix/glibc/lib/$_NEXUS_C_LOADER"
    if [ ! -f "$_loader" ] && [ ! -f "/lib/$_NEXUS_C_LOADER" ]; then
        log_warn "Loader GLIBC no encontrado: $_NEXUS_C_LOADER"
        log_warn "Puede que necesites instalar paquetes glibc o usar proot"
        _missing=1
    fi

    return $_missing
}

# ── nexus_c_build: compila helper C para binario GLIBC ──
# Uso: nexus_c_build <binary_path> <output_name> [extra_env...]
# binary_path: ruta al binario ELF real
# output_name: nombre del wrapper (ej: claude)
# extra_env: vars adicionales como "SSL_CERT_FILE=/custom/path"
nexus_c_build() {
    local _real_bin="${1:-}"
    local _output_name="${2:-}"
    shift 2 2>/dev/null || true
    local _extra_env=("$@")

    if [ -z "$_real_bin" ] || [ -z "$_output_name" ]; then
        echo "[ERROR] nexus_c_build: uso: nexus_c_build <binary_path> <output_name> [extra_env...]" >&2
        return 1
    fi

    nexus_c_check_deps || return 1

    local _prefix="${PREFIX:-/data/data/com.termux/files/usr}"
    local _loader_path="$_prefix/glibc/lib/$_NEXUS_C_LOADER"
    local _lib_path="$_prefix/glibc/lib"
    local _cert_path="$_prefix/etc/tls/cert.pem"
    local _output_bin="$_prefix/bin/$_output_name"

    # Build extra env vars string for C code
    local _extra_env_c=""
    for _e in "${_extra_env[@]}"; do
        _extra_env_c="${_extra_env_c}    putenv(\"${_e}\");\\n"
    done

    # Generate C source
    local _tmp_c
    _tmp_c="$(mktemp /tmp/nexus_c_helper_XXXXXX.c)"

    cat > "$_tmp_c" << 'C_CODE'
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

int main(int argc, char *argv[], char *envp[]) {
    /* Build argv for ld-linux loader */
    char *loader = "@LOADER_PATH@";
    char *lib_path = "@LIB_PATH@";
    char *real_bin = "@REAL_BIN@";
    
    /* Allocate argv: loader, --library-path, lib_path, --inhibit-rpath, ORIGIN, real_bin, original args..., NULL */
    int new_argc = 6 + argc;
    char **new_argv = malloc((new_argc + 1) * sizeof(char *));
    if (!new_argv) {
        fprintf(stderr, "nexus-c-helper: malloc failed\n");
        return 1;
    }
    
    new_argv[0] = loader;
    new_argv[1] = "--library-path";
    new_argv[2] = lib_path;
    new_argv[3] = "--inhibit-rpath";
    new_argv[4] = "ORIGIN";
    new_argv[5] = real_bin;
    for (int i = 1; i < argc; i++) {
        new_argv[5 + i] = argv[i];
    }
    new_argv[new_argc] = NULL;

    /* Set environment */
    unsetenv("LD_PRELOAD");
    unsetenv("LD_LIBRARY_PATH");
    setenv("GODEBUG", "netdns=cgo", 1);
    setenv("SSL_CERT_FILE", "@CERT_PATH@", 1);
@EXTRA_ENV@
    execve(loader, new_argv, envp);
    
    fprintf(stderr, "nexus-c-helper: execve failed\n");
    free(new_argv);
    return 1;
}
C_CODE

    # Replace placeholders with real values
    sed -i \
        -e "s|@LOADER_PATH@|$_loader_path|g" \
        -e "s|@LIB_PATH@|$_lib_path|g" \
        -e "s|@REAL_BIN@|$_real_bin|g" \
        -e "s|@CERT_PATH@|$_cert_path|g" \
        -e "s|@EXTRA_ENV@|$_extra_env_c|g" \
        "$_tmp_c"

    # Compile
    if ! clang -O2 -o "$_output_bin" "$_tmp_c" 2>/dev/null; then
        echo "[ERROR] nexus_c_build: fallo la compilacion para $_output_name" >&2
        rm -f "$_tmp_c" 2>/dev/null || true
        return 1
    fi

    rm -f "$_tmp_c" 2>/dev/null || true
    echo "[OK] Helper compilado: $_output_bin"
    return 0
}

# ── nexus_c_wrapper: crea wrapper bash sin compilar C ──
# Uso: nexus_c_wrapper <command_name> <command_line>
nexus_c_wrapper() {
    local _name="${1:-}"
    local _cmd="${2:-}"

    if [ -z "$_name" ] || [ -z "$_cmd" ]; then
        echo "[ERROR] nexus_c_wrapper: uso: nexus_c_wrapper <name> <command>" >&2
        return 1
    fi

    local _prefix="${PREFIX:-/data/data/com.termux/files/usr}"
    local _wrapper="$_prefix/bin/$_name"

    cat > "$_wrapper" << WRAPPER
#!/data/data/com.termux/files/usr/bin/bash
# Wrapper generado por nexus_c_wrapper
# Ejecuta: $_cmd
exec $_cmd "\$@"
WRAPPER
    chmod +x "$_wrapper"
    echo "[OK] Wrapper creado: $_wrapper"
    return 0
}
