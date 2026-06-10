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
    local _pkg_safe

    # Sanitizar nombre para usar como directorio venv
    _pkg_safe="$(echo "$package" | sed 's/[^a-zA-Z0-9._-]/_/g')"

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

    # PEP 668 handling: fallo de --user (externally-managed-environment)
    log_info "Fallo --user, intentando entorno aislado (PEP 668)..."

    # Opcion A: VIRTUAL_ENV activo → instalar alli sin flags extra
    if [ -n "${VIRTUAL_ENV:-}" ]; then
        log_info "VIRTUAL_ENV detectado en $VIRTUAL_ENV, instalando allí..."
        if $pip_cmd install --no-build-isolation "$package"; then
            log_ok "Instalado en VIRTUAL_ENV: $VIRTUAL_ENV"
            return 0
        fi
        log_info "Fallo instalación en VIRTUAL_ENV, continuando..."
    fi

    # Opcion B: crear venv propio en NEXUS_ROOT/venvs/<package>/
    local _venv_dir="${NEXUS_ROOT}/venvs/${_pkg_safe}"
    if command -v python3 &>/dev/null && python3 -m venv "$_venv_dir" 2>/dev/null; then
        log_info "Creando venv en $_venv_dir..."
        if "$_venv_dir/bin/pip" install --no-build-isolation "$package"; then
            log_warn "Package '$package' instalado en venv aislado: $_venv_dir"
            log_info "Agrega $_venv_dir/bin a tu PATH si necesitas acceso global."
            return 0
        fi
        log_info "Fallo instalación en venv, continuando..."
    fi

    # Ultimo recurso: --break-system-packages con advertencia
    log_info "Fallo PEP 668. Reintentando con --break-system-packages (último recurso)..."
    log_warn "ADVERTENCIA: --break-system-packages anula protecciones PEP 668 del sistema."
    if $pip_cmd install --break-system-packages --no-build-isolation "$package"; then
        log_warn "Package '$package' instalado con --break-system-packages (entorno del sistema no aislado)."
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
# Uso: install_via_npm <package> [binary_name]
# Si se provee binary_name y ya existe en PATH, omite la instalacion.
install_via_npm() {
    local package="$1"
    local binary="${2:-$1}"
    local npm_cmd="npm"

    # Salida temprana si el binario ya existe
    if command -v "$binary" &>/dev/null; then
        log_ok "$binary ya está instalado en $(command -v "$binary"), omitiendo instalación via npm"
        return 0
    fi

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
        curl -fsSL "$url" | bash || return $?
    else
        log_error "curl no disponible."
        return 1
    fi
}

# ── install_via_apt: apt / pkg install ─────────────
# Detecta Termux (NEXUS_ENV=termux) y usa pkg en ese caso.
# Si se ejecuta como root, usa apt siempre porque pkg
# (Termux) rechaza root.
# Uso: install_via_apt <package> [binary_name]
# Si se provee binary_name y ya existe en PATH, omite la instalacion.
install_via_apt() {
    local package="$1"
    local binary="${2:-$1}"

    # Salida temprana si el binario ya existe
    if command -v "$binary" &>/dev/null; then
        log_ok "$binary ya está instalado en $(command -v "$binary"), omitiendo instalación via apt"
        return 0
    fi

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

# ── install_via_binary: instala un binario (con soporte GLIBC en Termux) ──
# Uso: install_via_binary "tool-name" "download-url" "binary-name"
# Para Termux nativo:
#   1. Instala glibc-repo + glibc si NEXUS_ENV=termux
#   2. Descarga el tarball/zip desde URL
#   3. Extrae el binario a $NEXUS_ROOT/bin/
#   4. Crea wrapper script que exporta LD_LIBRARY_PATH si aplica
# Para proot-ubuntu / linux:
#   1. Descarga el tarball/zip
#   2. Extrae a /usr/local/bin/ (o $NEXUS_ROOT/bin/)
install_via_binary() {
    local tool_name="$1"
    local download_url="$2"
    local binary_name="${3:-$tool_name}"
    local target_dir="${NEXUS_ROOT}/bin"

    mkdir -p "$target_dir"

    if [ "${NEXUS_ENV:-}" = "termux" ]; then
        log_info "Entorno Termux detectado — instalando soporte GLIBC..."
        pkg install -y glibc-repo 2>/dev/null || true
        pkg install -y glibc 2>/dev/null || true
    fi

    log_info "Descargando ${tool_name} desde ${download_url}..."
    local tmp_dir
    tmp_dir="$(mktemp -d)"

    if echo "$download_url" | grep -qE '\.tar\.gz$|\.tgz$'; then
        curl -fsSL "$download_url" | tar xzf - -C "$tmp_dir" 2>/dev/null || {
            log_error "Fallo al descargar/extraer ${tool_name}"
            rm -rf "$tmp_dir"
            return 1
        }
    else
        # Asumir binario directo
        curl -fsSL "$download_url" -o "${tmp_dir}/${binary_name}" 2>/dev/null || {
            log_error "Fallo al descargar ${tool_name}"
            rm -rf "$tmp_dir"
            return 1
        }
    fi

    # Encontrar el binario en tmp_dir
    local found_bin
    found_bin="$(find "$tmp_dir" -name "${binary_name}" -type f 2>/dev/null | head -1)"
    if [ -z "$found_bin" ]; then
        found_bin="$(find "$tmp_dir" -type f -executable 2>/dev/null | head -1)"
    fi

    if [ -z "$found_bin" ]; then
        # Si hay un solo archivo no ejecutable, usarlo
        found_bin="$(find "$tmp_dir" -type f 2>/dev/null | head -1)"
    fi

    if [ -z "$found_bin" ]; then
        log_error "No se encontro binario en la descarga de ${tool_name}"
        rm -rf "$tmp_dir"
        return 1
    fi

    # Copiar a target dir
    chmod +x "$found_bin"
    cp "$found_bin" "${target_dir}/${binary_name}"

    # En Termux, crear wrapper GLIBC
    if [ "${NEXUS_ENV:-}" = "termux" ] && [ -f "${PREFIX}/glibc/lib/libgcc_s.so.1" ]; then
        local wrapper="${PREFIX}/bin/${binary_name}"
        log_info "Creando wrapper GLIBC para ${binary_name}..."
        cat > "$wrapper" << 'GLIBC_WRAPPER'
#!/data/data/com.termux/files/usr/bin/bash
export LD_LIBRARY_PATH=__GLIBC_LIB__${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
exec __BINARY__ "$@"
GLIBC_WRAPPER
        # Replace placeholders
        local glibc_lib="${PREFIX}/glibc/lib"
        local real_bin="${target_dir}/${binary_name}"
        sed -i "s|__GLIBC_LIB__|${glibc_lib}|g; s|__BINARY__|${real_bin}|g" "$wrapper"
        chmod +x "$wrapper"
        log_ok "Wrapper GLIBC creado en ${wrapper}"
    fi

    rm -rf "$tmp_dir"
    log_ok "Binario ${tool_name} instalado en ${target_dir}/${binary_name}"
    return 0
}

# ── uninstall_via_pip: pip3 uninstall ──────────────
uninstall_via_pip() {
    local package="$1"
    local _pkg_safe
    local _venv_dir

    _pkg_safe="$(echo "$package" | sed 's/[^a-zA-Z0-9._-]/_/g')"
    _venv_dir="${NEXUS_ROOT}/venvs/${_pkg_safe}"

    # Check venv primero
    if [ -d "$_venv_dir" ] && [ -f "$_venv_dir/bin/pip" ]; then
        log_info "Encontrado venv en $_venv_dir, desinstalando desde allí..."
        "$_venv_dir/bin/pip" uninstall -y "$package" 2>/dev/null || true
        rm -rf "$_venv_dir" 2>/dev/null || true
        log_ok "Venv $_venv_dir eliminado."
        return 0
    fi

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

# ── uninstall_via_binary: elimina binario y wrapper ──
# Uso: uninstall_via_binary "tool-name" "binary-name"
uninstall_via_binary() {
    local tool_name="$1"
    local binary_name="${2:-$tool_name}"
    local target_dir="${NEXUS_ROOT}/bin"
    local wrapper="${PREFIX:-/usr/local}/bin/${binary_name}"

    log_info "Desinstalando ${tool_name}..."

    # Eliminar binario
    rm -f "${target_dir}/${binary_name}" 2>/dev/null || true

    # Eliminar wrapper (Termux GLIBC)
    rm -f "$wrapper" 2>/dev/null || true

    log_ok "Binario ${tool_name} eliminado"
    return 0
}

# ── update_installed_manifest: agrega/elimina de installed.txt ─
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
            grep -vxF "$agent" "$manifest" > "${manifest}.tmp" 2>/dev/null || true
            mv "${manifest}.tmp" "$manifest" 2>/dev/null || true
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

# ── category_manifest_list: lista agentes instalados ─────────
# Lee installed.txt (formato plano, un nombre por linea)
# No incluye informacion de categoria — eso vive en metadata.sh
category_manifest_list() {
    local manifest="${NEXUS_ROOT}/logs/installed.txt"
    if [ -f "$manifest" ]; then
        cat "$manifest"
    fi
}

# ── category_manifest_has: verifica si un agente esta instalado ─
# Retorna 0 si el agente existe en installed.txt
category_manifest_has() {
    local agent="$1"
    local manifest="${NEXUS_ROOT}/logs/installed.txt"
    [ -f "$manifest" ] && grep -Fx "$agent" "$manifest" &>/dev/null
}

# ── agent_get_category: lee AGENT_CATEGORY de metadata.sh ────
# Lee del metadata.sh del modulo, NO de installed.txt
agent_get_category() {
    local name="$1"
    local meta="${NEXUS_ROOT}/modules/${name}/metadata.sh"
    if [ -f "$meta" ]; then
        sed -n 's/^export AGENT_CATEGORY="\(.*\)"/\1/p' "$meta"
    fi
}

# ── batch_install_category: instala todos los agentes de una categoria ──
# Uso: batch_install_category "ai"
# Instala cada agente en CATEGORIES["ai"] que tenga install.sh
batch_install_category() {
    local category="$1"
    local agents="${CATEGORIES[$category]:-}"

    if [ -z "$agents" ]; then
        log_error "Categoria '${category}' no encontrada."
        return 1
    fi

    log_info "Instalando todos los agentes de la categoria '${category}'..."

    local count=0
    for _agent in $agents; do
        local _dir="${NEXUS_MODULES_DIR}/${_agent}"
        if [ -d "$_dir" ] && [ -f "$_dir/install.sh" ]; then
            log_info "Instalando ${_agent}..."
            (source "$_dir/install.sh") && count=$((count + 1))
        else
            log_info "${_agent}: pendiente (stub)"
        fi
    done
    unset _agent _dir

    log_ok "Instalados ${count} agentes de la categoria '${category}'."
}
