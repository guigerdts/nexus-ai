#!/usr/bin/env bash
# modules/openclou/install.sh
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── openclou: instalacion manual ───────────────────
cat <<'EOF'
╔══════════════════════════════════════════════════════════════╗
║  openclou — CLI de IA para programacion                      ║
║                                                              ║
║  La instalacion es manual por ahora.                         ║
║                                                              ║
║  1. Visita https://openclou.ai                               ║
║                                                              ║
║  2. Descarga el binario para tu plataforma                   ║
║                                                              ║
║  3. Colocalo en el PATH con el nombre 'oclou'                ║
║                                                              ║
║  Una vez instalado, ejecuta:  nxai status                   ║
╚══════════════════════════════════════════════════════════════╝
EOF

log_warn "openclou requiere instalacion manual"
exit 0
