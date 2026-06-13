#!/usr/bin/env bash
# NEXUS AI — lib/nexus-proot.sh
# Proot-distro lifecycle wrappers: detect, list, install, run, create wrappers
# Version: 0.8.2
#
# Dependencias: proot-distro (pkg install proot-distro)
#              config/env.sh para deteccion de entorno

set -euo pipefail

# ── _nexus_proot_check: verifica que proot-distro este disponible ──
_nexus_proot_check() {
    if ! command -v proot-distro &>/dev/null; then
        log_error "proot-distro no instalado. Ejecuta: pkg install proot-distro"
        return 1
    fi
    return 0
}

# ── nexus_proot_detect: detecta si estamos en un host proot ──
# Returns: 0 si es host proot (puede crear distros), 1 si no
nexus_proot_detect() {
    # Re-exportar deteccion de env.sh si ya existe
    # NEXUS_ENV deberia estar seteado por config/env.sh

    if [ -n "${NEXUS_ENV:-}" ]; then
        case "$NEXUS_ENV" in
            termux)
                # En Termux nativo podemos ejecutar proot-distro
                return 0
                ;;
            proot-ubuntu)
                # Dentro de proot no podemos crear distros
                return 1
                ;;
            *)
                # Linux nativo — no aplica proot
                return 1
                ;;
        esac
    fi

    # Fallback: deteccion directa
    # Verificar si estamos en Termux (directorio data/data accesible)
    if [ -d "/data/data/com.termux" ] 2>/dev/null; then
        return 0
    fi

    return 1
}

# ── nexus_proot_list: lista distros instaladas ──
nexus_proot_list() {
    _nexus_proot_check || return 1

    if ! proot-distro list 2>/dev/null | tail -n +2; then
        log_info "No hay distros instaladas"
        return 0
    fi
}

# ── nexus_proot_ensure: asegura que una distro este instalada ──
# Uso: nexus_proot_ensure <distro>
# Si la distro no existe, la instala
nexus_proot_ensure() {
    local _distro="${1:-ubuntu}"

    _nexus_proot_check || return 1
    nexus_proot_detect || {
        log_error "No se pueden crear distros dentro de proot"
        return 1
    }

    # Check if already installed
    if proot-distro list 2>/dev/null | grep -qi "^$_distro\b"; then
        log_info "Distro '$_distro' ya instalada"
        return 0
    fi

    log_info "Instalando distro '$_distro' (esto puede tomar varios minutos)..."
    if proot-distro install "$_distro" 2>&1; then
        log_success "Distro '$_distro' instalada correctamente"
        return 0
    else
        log_error "Fallo la instalacion de '$_distro'"
        return 1
    fi
}

# ── nexus_proot_run: ejecuta comando dentro de proot ──
# Uso: nexus_proot_run <distro> <comando>
nexus_proot_run() {
    local _distro="${1:-ubuntu}"
    local _cmd="${2:-}"

    if [ -z "$_cmd" ]; then
        log_error "nexus_proot_run: uso: nexus_proot_run <distro> <comando>"
        return 1
    fi

    _nexus_proot_check || return 1
    nexus_proot_ensure "$_distro" || return 1

    proot-distro login "$_distro" -- /bin/bash -c "$_cmd"
}

# ── nexus_proot_wrapper: crea wrapper bash para binario en proot ──
# Uso: nexus_proot_wrapper <distro> <binary_path> <command_name>
nexus_proot_wrapper() {
    local _distro="${1:-ubuntu}"
    local _bin="${2:-}"
    local _name="${3:-}"

    if [ -z "$_bin" ] || [ -z "$_name" ]; then
        log_error "nexus_proot_wrapper: uso: nexus_proot_wrapper <distro> <path> <name>"
        return 1
    fi

    local _prefix="${PREFIX:-/data/data/com.termux/files/usr}"
    local _wrapper="$_prefix/bin/$_name"

    cat > "$_wrapper" << WRAPPER
#!/data/data/com.termux/files/usr/bin/bash
# Wrapper generado por nexus_proot_wrapper
# Ejecuta $_bin dentro de proot $_distro
exec proot-distro login "$_distro" -- $_bin "\$@"
WRAPPER
    chmod +x "$_wrapper"
    log_success "Wrapper creado: $_wrapper"
    return 0
}
