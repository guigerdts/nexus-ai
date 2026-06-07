#!/usr/bin/env bash
# modules/claude-code/uninstall.sh
# Desinstala claude-code — limpia helper C, data dir y wrapper proot
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

log_info "Desinstalando claude-code..."

# 1. Helper C en PREFIX/bin/claude (Termux nativo)
if [ -n "${PREFIX:-}" ] && [ -f "${PREFIX}/bin/claude" ]; then
    rm -f "${PREFIX}/bin/claude"
    log_info "Eliminado: ${PREFIX}/bin/claude"
fi

# 2. Wrapper proot en PREFIX/bin/claude (Termux + proot)
if [ -n "${NEXUS_ROOT:-}" ] && [ -f "${NEXUS_ROOT}/bin/claude" ]; then
    rm -f "${NEXUS_ROOT}/bin/claude"
fi

# 3. Data dir con binario descargado
CLAUDE_DATA_DIR="${HOME}/.local/share/nexus-ai/claude"
if [ -d "$CLAUDE_DATA_DIR" ]; then
    rm -rf "$CLAUDE_DATA_DIR"
    log_info "Eliminado: ${CLAUDE_DATA_DIR}"
fi

# 4. Bootstrap oficial de claude (proot/Linux) — $HOME/.claude
if [ -d "${HOME}/.claude" ]; then
    rm -rf "${HOME}/.claude"
    log_info "Eliminado: ${HOME}/.claude"
fi

# 5. Limpiar cualquier binario en PATH
if command -v claude &>/dev/null; then
    rm -f "$(command -v claude)" 2>/dev/null || true
fi

mark_removed "claude-code"
log_ok "claude-code desinstalado."
exit 0
