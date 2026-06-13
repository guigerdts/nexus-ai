#!/usr/bin/env bash
# modules/opencode/uninstall.sh
# Desinstala OpenCode — limpia binario descargado y helper C
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

log_info "Desinstalando opencode..."

# 1. Helper C en PREFIX/bin/opencode (Termux nativo)
if [ -n "${PREFIX:-}" ] && [ -f "${PREFIX}/bin/opencode" ]; then
    rm -f "${PREFIX}/bin/opencode"
    log_info "Eliminado: ${PREFIX}/bin/opencode"
fi

# 2. Binario en /usr/local/bin/opencode (Linux / proot)
if [ -f /usr/local/bin/opencode ]; then
    rm -f /usr/local/bin/opencode
    log_info "Eliminado: /usr/local/bin/opencode"
fi

# 3. Data dir con binario descargado
OPENCODE_DATA_DIR="${HOME}/.local/share/nexus-ai/opencode"
if [ -d "$OPENCODE_DATA_DIR" ]; then
    rm -rf "$OPENCODE_DATA_DIR"
    log_info "Eliminado: ${OPENCODE_DATA_DIR}"
fi

# 4. Limpiar cualquier binario residual en PATH
if command -v opencode &>/dev/null; then
    rm -f "$(command -v opencode)" 2>/dev/null || true
fi

mark_removed "opencode"
log_ok "opencode desinstalado."
exit 0
