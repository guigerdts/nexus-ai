#!/usr/bin/env bash
# modules/pi/install.sh
# Pi.ai — Asistente de IA web, no tiene CLI oficial instalable.
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

cat <<'STUB_EOF'
╔══════════════════════════════════════════════════╗
║  Pi — Asistente de IA desde terminal (Pi.ai)      ║
║                                                   ║
║  Pi.ai es un asistente web. No tiene CLI          ║
║  oficial disponible para instalacion.             ║
║                                                   ║
║  Accede via: https://pi.ai                        ║
║                                                   ║
║  Repositorio: https://github.com/inflection/pi    ║
╚══════════════════════════════════════════════════╝
STUB_EOF

log_ok "pi — accede via web: https://pi.ai"
exit 0
