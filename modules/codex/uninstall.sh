#!/usr/bin/env bash
# modules/codex/uninstall.sh
# Desinstala Codex CLI — maneja ambos paquetes (fork Termux y oficial)
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

log_info "Desinstalando codex..."

# Desinstalar ambos paquetes por si acaso
for _pkg in "@mmmbuto/codex-cli-termux" "@openai/codex"; do
    if npm list -g "$_pkg" &>/dev/null 2>&1; then
        uninstall_via_npm "$_pkg"
    fi
done

# Limpiar binario residual
if command -v codex &>/dev/null; then
    rm -f "$(command -v codex)" 2>/dev/null || true
fi

mark_removed "codex"
log_ok "codex desinstalado."
exit 0
