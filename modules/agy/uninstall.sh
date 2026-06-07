#!/usr/bin/env bash
# modules/agy/uninstall.sh
# Desinstala Antigravity CLI (agy)
# Termux: helper C en PREFIX/bin/agy + binario VA39 + data dir
# proot/Linux: binario en NEXUS_ROOT/bin/agy

# Source functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/nexus-install.sh" 2>/dev/null || {
    echo "[ERROR] nexus-install.sh no encontrado"
    exit 1
}
source "$SCRIPT_DIR/metadata.sh" 2>/dev/null || true

log_info "Desinstalando ${AGENT_NAME:-agy}..."

_prefix="${PREFIX:-/data/data/com.termux/files/usr}"
_agy_data="${HOME}/.local/share/nexus-ai/antigravity-cli"

# Remover helper C (Termux) o binario directo (proot/linux)
for _path in "${_prefix}/bin/agy" "${NEXUS_ROOT}/bin/agy"; do
    if [ -f "$_path" ]; then
        rm -f "$_path" 2>/dev/null || true
        log_info "Eliminado: $_path"
    fi
done

# Remover directorio de datos (binario upstream, VA39, tarball, etc.)
if [ -d "$_agy_data" ]; then
    rm -rf "$_agy_data" 2>/dev/null || true
    log_info "Eliminado: $_agy_data"
fi

# Remover wrapper GLIBC legacy si existe (de instalaciones anteriores)
_wrapper="${_prefix}/bin/agy_wrapper"
[ -f "$_wrapper" ] && rm -f "$_wrapper" 2>/dev/null || true

mark_removed "$AGENT_NAME"
log_ok "Antigravity CLI desinstalado completamente."
exit 0
