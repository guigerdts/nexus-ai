#!/usr/bin/env bash
# modules/banner/install.sh
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

cat <<'STUB_EOF'
╔══════════════════════════════════════════════════╗
║  Banner — NEXUS AI ASCII header                   ║
║                                                   ║
║  El banner ya esta incluido en el framework.      ║
║  Se muestra automaticamente al ejecutar nxai.     ║
║                                                   ║
║  No requiere instalacion adicional.               ║
╚══════════════════════════════════════════════════╝
STUB_EOF

log_ok "banner ya incluido en NEXUS AI — no requiere instalacion"
exit 0
