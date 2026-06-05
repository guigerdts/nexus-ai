#!/usr/bin/env bash
# modules/nerd-fonts/install.sh
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

cat <<'STUB_EOF'
╔══════════════════════════════════════════════════╗
║  nerd-fonts — Fuentes Nerd Fonts para terminal   ║
║                                                  ║
║  Instalacion manual:                             ║
║  1. Visita: https://www.nerdfonts.com/           ║
║  2. Descarga el binario/clona el repositorio     ║
║  3. Sigue las instrucciones del README           ║
║  4. Asegurate de que quede en el PATH            ║
║                                                  ║
║  nxai status                                    ║
╚══════════════════════════════════════════════════╝
STUB_EOF

log_warn "nerd-fonts requiere instalacion manual — segui las instrucciones arriba"
exit 0
