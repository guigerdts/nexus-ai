#!/usr/bin/env bash
# modules/openclaude/install.sh
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── openclaude: instalacion manual ─────────────────
cat <<'EOF'
╔══════════════════════════════════════════════════════════════╗
║  openclaude — CLI de IA para programacion                     ║
║                                                              ║
║  La instalacion es manual por ahora.                         ║
║                                                              ║
║  1. Visita https://github.com/openclaude-ai/cli              ║
║                                                              ║
║  2. Descarga el binario para tu plataforma                   ║
║                                                              ║
║  3. Colocalo en el PATH con el nombre 'openclaude'           ║
║                                                              ║
║  Una vez instalado, ejecuta:  nxai status                    ║
╚══════════════════════════════════════════════════════════════╝
EOF

log_warn "openclaude requiere instalacion manual"
exit 0
