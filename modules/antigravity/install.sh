#!/usr/bin/env bash
# modules/antigravity/install.sh
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── antigravity: CLI experimental (instalacion manual) ──
# Este agente no tiene un metodo de instalacion automatizado.
# Se muestran instrucciones para instalacion manual.

cat <<'EOF'
╔══════════════════════════════════════════════════════════════╗
║  antigravity — CLI experimental de IA                       ║
║                                                              ║
║  La instalacion es manual por ahora.                         ║
║                                                              ║
║  1. Clona el repositorio:                                    ║
║       git clone https://github.com/antigravity-ai/antigravity ║
║                                                              ║
║  2. Sigue las instrucciones en el README del proyecto        ║
║                                                              ║
║  3. Asegurate de que el binario quede en tu PATH             ║
║                                                              ║
║  Una vez instalado, ejecuta:  nxai status                   ║
╚══════════════════════════════════════════════════════════════╝
EOF

log_warn "antigravity requiere instalacion manual"
exit 0
