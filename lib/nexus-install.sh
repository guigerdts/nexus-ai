#!/usr/bin/env bash
# NEXUS AI — lib/nexus-install.sh
# Biblioteca compartida de instalacion para agentes
# Version: 0.1.0
#
# Funciones:
#   check_dependency(nombre, cmd)  — verifica que un comando existe
#   install_via_pip(paquete)       — pip3 install --user
#   install_via_npm(paquete)       — npm install -g
#   install_via_curl(url)          — curl | bash
#   install_via_apt(paquete)       — apt/pkg install
#   install_via_cargo(paquete)     — cargo install
#   mark_installed(agente, version) — registra en logs/agents.log
#   mark_removed(agente)            — registra en logs/agents.log
#   update_installed_manifest(agente, accion) — agrega/elimina de logs/installed.txt

# ── Source env.sh y log helpers ────────────────────
# Garantiza que las variables NEXUS_COLOR_* esten definidas
# antes de que nexux-log.sh las use (evita unbound variable
# con set -u cuando un install.sh sourcea directamente
# nexux-install.sh sin pasar por nexus.sh).
_NEXUS_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$_NEXUS_LIB_DIR/../config/env.sh" ]; then
    source "$_NEXUS_LIB_DIR/../config/env.sh"
fi
if [ -f "$_NEXUS_LIB_DIR/nexus-log.sh" ]; then
    source "$_NEXUS_LIB_DIR/nexus-log.sh"
fi
unset _NEXUS_LIB_DIR

# ── check_dependency: verifica que un binario existe ─
# Uso: check_dependency "Python 3" "python3 --version"
# Retorna 0 si existe, 1 si no (sin abortar)
check_dependency() {
    local name="$1"
    local cmd="$2"

    if command -v "${cmd%% *}" &>/dev/null; then
        log_ok "Dependencia satisfecha: $name"
        return 0
    else
        log_warn "Dependencia faltante: $name"
        log_info "Instala $name con: pkg install $name (Termux) o apt install $name"
        return 1
    fi
}

# ── install_via_pip: pip3 install ──────────────────
install_via_pip() {
    local package="$1"
    local pip_cmd=""

    # Cuando NEXUS_TERMUX_ACCESSIBLE=true, preferir pip de Termux
    if [ "${NEXUS_TERMUX_ACCESSIBLE:-false}" = "true" ]; then
        pip_cmd="${TERMUX_PIP:-pip3}"
        log_info "Instalando $package via pip (Termux: $pip_cmd)..."
    elif command -v pip3 &>/dev/null; then
        pip_cmd="pip3"
    elif command -v pip &>/dev/null; then
        pip_cmd="pip"
    else
        log_error "pip3/pip no disponible. Instala python3-pip primero."
        return 1
    fi

    log_info "Instalando $package via pip..."

    # Intento 1: --user + --no-build-isolation
    # --no-build-isolation evita pip-build-env con setuptools
    # del sistema incompatible con Python 3.12+
    if $pip_cmd install --user --no-build-isolation "$package"; then
        return 0
    fi

    # Intento 2: --break-system-packages + --no-build-isolation
    # --no-build-isolation evita pip-build-env con setuptools
    # del sistema incompatible con Python 3.12+
    log_info "Fallo --user, reintentando con --break-system-packages..."
    if $pip_cmd install --break-system-packages --no-build-isolation "$package"; then
        return 0
    fi

    # Intento 3: pipx (fallback universal, recomienda PEP 668)
    if command -v pipx &>/dev/null; then
        log_info "Fallo pip, intentando via pipx..."
        pipx install "$package"
        return $?
    fi

    log_error "No se pudo instalar $package via pip ni pipx."
    log_info "Instala manualmente: pip3 install --user $package"
    return 1
}

# ── install_via_npm: npm install -g ────────────────
# Cuando NEXUS_TERMUX_ACCESSIBLE=true, usa TERMUX_NPM
# (npm de Termux) para que el paquete quede disponible
# en el entorno Termux real, no en proot.
install_via_npm() {
    local package="$1"
    local npm_cmd="npm"

    if [ "${NEXUS_TERMUX_ACCESSIBLE:-false}" = "true" ] && [ -n "${TERMUX_NPM:-}" ]; then
        npm_cmd="$TERMUX_NPM"
        log_info "Instalando $package via npm (Termux: $npm_cmd)..."
    else
        log_info "Instalando $package via npm..."
    fi

    if command -v "${npm_cmd}" &>/dev/null; then
        $npm_cmd install -g "$package"
    else
        log_error "npm no disponible. Instala Node.js primero."
        return 1
    fi
}

# ── install_via_curl: curl | bash ──────────────────
install_via_curl() {
    local url="$1"

    log_info "Instalando desde $url..."
    if command -v curl &>/dev/null; then
        bash <(curl -fsSL "$url")
    else
        log_error "curl no disponible."
        return 1
    fi
}

# ── install_via_apt: apt / pkg install ─────────────
# Detecta Termux (NEXUS_ENV=termux) y usa pkg en ese caso.
# Si se ejecuta como root, usa apt siempre porque pkg
# (Termux) rechaza root.
install_via_apt() {
    local package="$1"

    if [ "$(id -u)" -eq 0 ]; then
        log_info "Instalando $package via apt (root — pkg no disponible como root)..."
        if command -v apt &>/dev/null; then
            apt install -y "$package"
        else
            log_error "apt no disponible."
            return 1
        fi
    elif [ "${NEXUS_TERMUX_ACCESSIBLE:-false}" = "true" ]; then
        log_info "Instalando $package via pkg (Termux bind-mount)..."
        "${TERMUX_PKG:-pkg}" install -y "$package"
    elif [ "${NEXUS_ENV:-}" = "termux" ]; then
        log_info "Instalando $package via pkg (Termux)..."
        pkg install -y "$package"
    else
        log_info "Instalando $package via apt..."
        if command -v apt &>/dev/null; then
            apt install -y "$package"
        else
            log_error "apt no disponible."
            return 1
        fi
    fi
}

# ── install_via_cargo: cargo install ───────────────
install_via_cargo() {
    local package="$1"

    log_info "Instalando $package via cargo..."
    if command -v cargo &>/dev/null; then
        cargo install "$package"
    else
        log_error "cargo no disponible. Instala Rust primero."
        return 1
    fi
}

# ── uninstall_via_pip: pip3 uninstall ──────────────
uninstall_via_pip() {
    local package="$1"

    log_info "Desinstalando $package via pip..."
    if command -v pip3 &>/dev/null; then
        pip3 uninstall -y "$package" 2>/dev/null || true
    elif command -v pip &>/dev/null; then
        pip uninstall -y "$package" 2>/dev/null || true
    else
        log_error "pip3/pip no disponible."
        return 1
    fi
}

# ── uninstall_via_npm: npm uninstall -g ────────────
# Cuando NEXUS_TERMUX_ACCESSIBLE=true, usa TERMUX_NPM
# (npm de Termux) para que el uninstall encuentre el
# paquete en el entorno Termux real, no en proot.
uninstall_via_npm() {
    local package="$1"
    local npm_cmd="npm"

    if [ "${NEXUS_TERMUX_ACCESSIBLE:-false}" = "true" ] && [ -n "${TERMUX_NPM:-}" ]; then
        npm_cmd="$TERMUX_NPM"
        log_info "Desinstalando $package via npm (Termux: $npm_cmd)..."
    else
        log_info "Desinstalando $package via npm..."
    fi

    if command -v "${npm_cmd}" &>/dev/null; then
        $npm_cmd uninstall -g "$package" 2>/dev/null || true
    else
        log_error "npm no disponible."
        return 1
    fi
}

# ── uninstall_via_apt: apt/pkg remove ──────────────
# Detecta Termux (NEXUS_TERMUX_ACCESSIBLE o NEXUS_ENV=termux)
# y usa pkg uninstall en ese caso, apt remove en caso contrario.
# Si se ejecuta como root, usa apt siempre porque pkg
# (Termux) rechaza root.
uninstall_via_apt() {
    local package="$1"

    if [ "$(id -u)" -eq 0 ]; then
        log_info "Desinstalando $package via apt (root — pkg no disponible como root)..."
        if command -v apt &>/dev/null; then
            apt remove -y "$package" 2>/dev/null || true
        else
            log_error "apt no disponible."
            return 1
        fi
    elif [ "${NEXUS_TERMUX_ACCESSIBLE:-false}" = "true" ]; then
        log_info "Desinstalando $package via pkg (Termux bind-mount)..."
        "${TERMUX_PKG:-pkg}" uninstall -y "$package" 2>/dev/null || true
    elif [ "${NEXUS_ENV:-}" = "termux" ]; then
        log_info "Desinstalando $package via pkg (Termux)..."
        pkg uninstall -y "$package" 2>/dev/null || true
    else
        log_info "Desinstalando $package via apt..."
        if command -v apt &>/dev/null; then
            apt remove -y "$package" 2>/dev/null || true
        else
            log_error "apt no disponible."
            return 1
        fi
    fi
}

# ── update_installed_manifest: agrega/elimina de instaled.txt ─
# Uso: update_installed_manifest "agent-name" "install|remove"
# Manifest en $NEXUS_ROOT/logs/installed.txt — un nombre por linea
# Idempotente: install no duplica, remove no falla si no existe
update_installed_manifest() {
    local agent="$1"
    local action="$2"
    local manifest="${NEXUS_ROOT}/logs/installed.txt"

    mkdir -p "$(dirname "$manifest")"

    case "$action" in
        install)
            grep -Fx "$agent" "$manifest" 2>/dev/null || echo "$agent" >> "$manifest"
            ;;
        remove)
            sed -i "/^${agent}$/d" "$manifest" 2>/dev/null || true
            ;;
    esac
}

# ── mark_installed: registra instalacion ───────────
# Formato: 2026-06-03 10:00:00 | INSTALLED | aider | 0.73.1
# Idempotente: actualiza la entrada existente si ya existe
mark_installed() {
    local agent="$1"
    local version="${2:-desconocida}"
    local log_file="${NEXUS_ROOT:-/root/nexus-ai}/logs/agents.log"
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"

    mkdir -p "$(dirname "$log_file")"

    # Idempotente: si existe entrada previa, reemplazarla
    if [ -f "$log_file" ] && grep -q "| ${agent} |" "$log_file" 2>/dev/null; then
        grep -v "| ${agent} |" "$log_file" > "${log_file}.tmp" 2>/dev/null || true
        mv -f "${log_file}.tmp" "$log_file" 2>/dev/null || true
    fi

    echo "${timestamp} | INSTALLED | ${agent} | ${version}" >> "$log_file"
    log_ok "Instalacion registrada: $agent $version"

    # Sincronizar manifest de instalacion
    update_installed_manifest "$agent" "install"
}

# ── mark_removed: registra eliminacion ─────────────
# Formato: 2026-06-03 10:00:00 | REMOVED | aider
mark_removed() {
    local agent="$1"
    local log_file="${NEXUS_ROOT:-/root/nexus-ai}/logs/agents.log"
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"

    mkdir -p "$(dirname "$log_file")"
    echo "${timestamp} | REMOVED | ${agent}" >> "$log_file"

    log_ok "Eliminacion registrada: $agent"

    # Sincronizar manifest de instalacion
    update_installed_manifest "$agent" "remove"
}
