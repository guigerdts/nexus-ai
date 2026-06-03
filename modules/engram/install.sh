#!/usr/bin/env bash
# modules/engram/install.sh
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── Verificar si engram ya esta en PATH ────────────
if command -v engram &>/dev/null; then
    local version
    version="$(engram --version 2>/dev/null || echo "0.0.0")"
    mark_installed "engram" "$version"
    log_ok "engram ya esta instalado ($version)"
    exit 0
fi

# ── Instalacion manual ─────────────────────────────
cat <<'EOF'
╔══════════════════════════════════════════════════════════════╗
║  engram — Memoria persistente para sesiones de IA           ║
║                                                              ║
║  engram no se encuentra en el PATH.                          ║
║                                                              ║
║  Para instalar engram CLI:                                   ║
║                                                              ║
║  1. Visita https://opencode.ai para instrucciones            ║
║                                                              ║
║  2. O busca engram CLI en:                                   ║
║       https://github.com/opencode-ai/engram                  ║
║                                                              ║
║  3. Una vez instalado, asegurate de que este en el PATH      ║
║                                                              ║
║  Una vez instalado, ejecuta:  nxai status                   ║
╚══════════════════════════════════════════════════════════════╝
EOF

log_warn "engram requiere instalacion manual"
exit 0
