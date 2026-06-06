#!/usr/bin/env bash
# modules/sgpt/install.sh
# SGPT (shell-gpt): ChatGPT in terminal
# Dual-environment: Termux (pkg + pip) / proot-Ubuntu (pip)
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
_NEXUS_INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$_NEXUS_INSTALL_DIR/lib/nexus-install.sh"

# ── Detectar entorno (auto-contenido) ──────────────
if [ -n "${PREFIX:-}" ]; then
    NEXUS_ENV="termux"
elif command -v pkg &>/dev/null && [ -d "/data/data/com.termux" ] 2>/dev/null; then
    NEXUS_ENV="termux"
elif [ "${NEXUS_TERMUX_ACCESSIBLE:-false}" = "true" ]; then
    : # hybrid mode: Termux bind-mounts accessible, keep parent env (proot-ubuntu)
elif [ -n "${NEXUS_ENV:-}" ]; then
    : # ya definido por el parent shell (source)
else
    NEXUS_ENV="linux"
fi
export NEXUS_ENV

# ── Verificar dependencias ─────────────────────────
check_dependency "Python 3" "python3 --version" || exit 1
check_dependency "pip3" "pip3 --version" || {
    log_info "Intentando instalar pip3..."
    install_via_apt "python3-pip"
}

# ═══════════════════════════════════════════════════
#  Instalar sgpt via pip (ARM64-safe)
# ═══════════════════════════════════════════════════
# Estrategia: openai>=2.0.0 es necesario para sgpt.
# jiter (dep de openai) tiene wheels manylinux aarch64
# que funcionan en proot-Ubuntu. En Termux se compila
# desde fuente y requiere Rust (pkg install rust).
_install_rc=0

# Detectar pip correcto (Termux vs system)
_pip_cmd="pip3"
if [ "${NEXUS_TERMUX_ACCESSIBLE:-false}" = "true" ] && [ -n "${TERMUX_PIP:-}" ]; then
    _pip_cmd="$TERMUX_PIP"
fi

log_info "Instalando shell-gpt sin dependencias..."
$_pip_cmd install --no-deps --no-build-isolation shell-gpt 2>/dev/null || true

log_info "Instalando dependencias puras Python..."
$_pip_cmd install --no-build-isolation distro rich typer prompt-toolkit 2>/dev/null || true

log_info "Instalando openai>=2.0.0..."
if ! $_pip_cmd install "openai>=2.0.0" 2>/dev/null; then
    # openai>=2.0.0 requiere jiter (Rust/maturin).
    # En Termux los wheels manylinux no son compatibles,
    # necesita compilar desde fuente con Rust.
    if [ "$NEXUS_ENV" = "termux" ]; then
        log_info "openai>=2.0.0 requiere Rust para compilar jiter en Termux..."
        pkg install -y rust 2>/dev/null || true
        $_pip_cmd install "openai>=2.0.0" 2>/dev/null || _install_rc=$?
    else
        log_info "pip directo fallo. Reintentando con --user..."
        $_pip_cmd install --user "openai>=2.0.0" 2>/dev/null || \
        $_pip_cmd install --break-system-packages "openai>=2.0.0" 2>/dev/null || _install_rc=$?
    fi
fi

# ═══════════════════════════════════════════════════
#  Fallback: uv pip install
# ═══════════════════════════════════════════════════
if [ "$_install_rc" -ne 0 ]; then
    log_info "pip fallo. Intentando con uv como fallback..."
    if ! command -v uv &>/dev/null; then
        log_info "Instalando uv via pip..."
        pip3 install uv 2>/dev/null || pip3 install --user uv 2>/dev/null || true
    fi
    if command -v uv &>/dev/null; then
        log_info "Instalando shell-gpt via uv..."
        uv pip install shell-gpt --no-build && _install_rc=0 || log_warn "uv tampoco pudo instalar sgpt"
    else
        log_warn "uv no esta disponible. No se pudo instalar sgpt."
    fi
fi

# ═══════════════════════════════════════════════════
#  Suprimir setup interactivo de API key
# ═══════════════════════════════════════════════════
# sgpt pide API key al ejecutarse por primera vez.
# Creamos un config minimo para que no se cuelgue.
_sgpt_config_dir="$HOME/.config/shell_gpt"
if [ ! -f "$_sgpt_config_dir/.sgptrc" ]; then
    mkdir -p "$_sgpt_config_dir"
    cat > "$_sgpt_config_dir/.sgptrc" <<- SGPTRC
	OPENAI_API_KEY=your-api-key-here
	SGPTRC
    log_info "Config creado: $_sgpt_config_dir/.sgptrc (edita con tu API key)"
fi
unset _sgpt_config_dir

# ═══════════════════════════════════════════════════
#  Verificar instalacion
# ═══════════════════════════════════════════════════
if command -v sgpt &>/dev/null; then
    version="$(sgpt --version 2>/dev/null || echo "0.0.0")"
    if [ "$_install_rc" -ne 0 ]; then
        log_warn "El comando pip fallo pero sgpt ya estaba instalado ($version)"
    fi
    mark_installed "sgpt" "$version"
    log_ok "sgpt instalado correctamente ($version)"
else
    log_error "sgpt no se encuentra en PATH despues de la instalacion."
    log_info "Intenta: pip3 install --user shell-gpt"
    log_info "En Termux o hybrid: TERMUX_PKG/pkg install ... y pip3 install --user shell-gpt"
    log_info "O con uv: pip3 install uv && uv pip install shell-gpt"
    exit 1
fi

# ── Cleanup ─────────────────────────────────────────
unset _install_rc _NEXUS_INSTALL_DIR
