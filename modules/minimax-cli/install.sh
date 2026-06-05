#!/usr/bin/env bash
# modules/minimax-cli/install.sh
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

cat <<'STUB_EOF'
╔══════════════════════════════════════════════════╗
║  minimax-cli — CLI para la API de MiniMax AI     ║
║                                                  ║
║  Instalacion manual:                             ║
║  1. Visita: https://github.com/MiniMax-AI/minimax-cli ║
║  2. Descarga el binario/clona el repositorio     ║
║  3. Sigue las instrucciones del README           ║
║  4. Asegurate de que quede en el PATH            ║
║                                                  ║
║  nxai status                                    ║
╚══════════════════════════════════════════════════╝
STUB_EOF

log_warn "minimax-cli requiere instalacion manual — segui las instrucciones arriba"
exit 0
