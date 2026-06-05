#!/usr/bin/env bash
# modules/termux-styling/install.sh
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

cat <<'STUB_EOF'
╔══════════════════════════════════════════════════╗
║  termux-styling — Personalizacion visual Termux  ║
║                                                  ║
║  Instalacion manual:                             ║
║  1. Visita: https://github.com/termux/termux-styling ║
║  2. Descarga el binario/clona el repositorio     ║
║  3. Sigue las instrucciones del README           ║
║  4. Asegurate de que quede en el PATH            ║
║                                                  ║
║  nxai status                                    ║
╚══════════════════════════════════════════════════╝
STUB_EOF

log_warn "termux-styling requiere instalacion manual — segui las instrucciones arriba"
exit 0
