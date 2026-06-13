#!/usr/bin/env bash
# modules/mimo-code/uninstall.sh
# Desinstala MiMo Code — limpia binario descargado y helper C
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

log_info "Desinstalando mimo-code..."

# 1. Helper C en PREFIX/bin/mimo (Termux nativo)
if [ -n "${PREFIX:-}" ] && [ -f "${PREFIX}/bin/mimo" ]; then
    rm -f "${PREFIX}/bin/mimo"
    log_info "Eliminado: ${PREFIX}/bin/mimo"
fi

# 2. Binario en /usr/local/bin/mimo (Linux / proot)
if [ -f /usr/local/bin/mimo ]; then
    rm -f /usr/local/bin/mimo
    log_info "Eliminado: /usr/local/bin/mimo"
fi

# 3. Data dir con binario descargado
MIMO_DATA_DIR="${HOME}/.local/share/nexus-ai/mimocode"
if [ -d "$MIMO_DATA_DIR" ]; then
    rm -rf "$MIMO_DATA_DIR"
    log_info "Eliminado: ${MIMO_DATA_DIR}"
fi

# 4. Datos locales de MiMo Code
if [ -d "${HOME}/.mimocode" ]; then
    rm -rf "${HOME}/.mimocode"
    log_info "Eliminado: ${HOME}/.mimocode"
fi

# 5. Limpiar cualquier binario residual en PATH
if command -v mimo &>/dev/null; then
    rm -f "$(command -v mimo)" 2>/dev/null || true
fi

mark_removed "mimo-code"
log_ok "mimo-code desinstalado."
exit 0
