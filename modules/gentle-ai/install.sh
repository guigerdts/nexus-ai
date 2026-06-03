#!/usr/bin/env bash
# modules/gentle-ai/install.sh
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── gentle-ai: instalacion manual ──────────────────
cat <<'EOF'
╔══════════════════════════════════════════════════════════════╗
║  gentle-ai — CLI de codigo abierto para desarrollo asistido ║
║                                                              ║
║  La instalacion es manual por ahora.                         ║
║                                                              ║
║  1. Clona el repositorio:                                    ║
║       git clone https://github.com/gentle-ai/gentle          ║
║                                                              ║
║  2. Sigue las instrucciones en el README del proyecto        ║
║                                                              ║
║  3. Asegurate de que 'gentle' quede en tu PATH               ║
║                                                              ║
║  Una vez instalado, ejecuta:  nxai status                   ║
╚══════════════════════════════════════════════════════════════╝
EOF

log_warn "gentle-ai requiere instalacion manual"
exit 0
