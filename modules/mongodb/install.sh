#!/usr/bin/env bash
# modules/mongodb/install.sh
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

cat <<'STUB_EOF'
╔══════════════════════════════════════════════════╗
║  mongodb — Base de datos NoSQL documental        ║
║                                                  ║
║  Instalacion manual:                             ║
║  1. Visita: https://www.mongodb.com/docs/manual/installation/ ║
║  2. Descarga el binario/clona el repositorio     ║
║  3. Sigue las instrucciones del README           ║
║  4. Asegurate de que quede en el PATH            ║
║                                                  ║
║  nxai status                                    ║
╚══════════════════════════════════════════════════╝
STUB_EOF

log_warn "mongodb requiere instalacion manual — segui las instrucciones arriba"
exit 0
