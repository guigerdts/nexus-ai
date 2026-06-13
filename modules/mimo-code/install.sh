#!/usr/bin/env bash
# modules/mimo-code/install.sh
# Instala MiMo Code via npm — fork de OpenCode con memoria persistente
# Instalacion alternativa: curl -fsSL https://mimo.xiaomi.com/install | bash
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── Verificar dependencias ─────────────────────────
check_dependency "Node.js" "node --version" || exit 1
check_dependency "npm" "npm --version" || exit 1

# ── Instalar mimo-code via npm ─────────────────────
_install_rc=0
install_via_npm "@mimo-ai/cli" "mimo" || _install_rc=$?

# ── Verificar instalacion ──────────────────────────
if command -v mimo &>/dev/null; then
    version="$(mimo --version 2>/dev/null || echo "0.0.0")"
    if [ "$_install_rc" -ne 0 ]; then
        log_warn "El comando npm fallo pero mimo ya estaba instalado ($version)"
    fi
    mark_installed "mimo-code" "$version"
    log_ok "mimo-code instalado correctamente ($version)"
else
    log_error "mimo no se encuentra en PATH despues de la instalacion."
    log_info "Intenta: npm install -g @mimo-ai/cli"
    log_info "O: curl -fsSL https://mimo.xiaomi.com/install | bash"
    exit 1
fi
unset _install_rc
