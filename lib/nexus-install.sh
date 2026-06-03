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

# ── Source log helpers si no estan cargados ────────
if ! command -v log_ok &>/dev/null; then
    # shellcheck source=lib/nexus-log.sh
    _nexus_install_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    if [ -f "$_nexus_install_dir/nexus-log.sh" ]; then
        source "$_nexus_install_dir/nexus-log.sh"
    fi
    unset _nexus_install_dir
fi

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

    log_info "Instalando $package via pip..."
    if command -v pip3 &>/dev/null; then
        pip3 install --user "$package"
    elif command -v pip &>/dev/null; then
        pip install --user "$package"
    else
        log_error "pip3/pip no disponible. Instala python3-pip primero."
        return 1
    fi
}

# ── install_via_npm: npm install -g ────────────────
install_via_npm() {
    local package="$1"

    log_info "Instalando $package via npm..."
    if command -v npm &>/dev/null; then
        npm install -g "$package"
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
# Detecta Termux (NEXUS_ENV=termux) y usa pkg en ese caso
install_via_apt() {
    local package="$1"

    if [ "${NEXUS_ENV:-}" = "termux" ]; then
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
uninstall_via_npm() {
    local package="$1"

    log_info "Desinstalando $package via npm..."
    if command -v npm &>/dev/null; then
        npm uninstall -g "$package" 2>/dev/null || true
    else
        log_error "npm no disponible."
        return 1
    fi
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
}
