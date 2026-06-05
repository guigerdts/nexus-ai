#!/usr/bin/env bash
# modules/qwen-code/install.sh
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

cat <<'STUB_EOF'
╔══════════════════════════════════════════════════╗
║  qwen-code — CLI de codigo asistido por Qwen AI  ║
║                                                  ║
║  Instalacion manual:                             ║
║  1. Visita: https://github.com/QwenLM/qwen-code  ║
║  2. Descarga el binario/clona el repositorio     ║
║  3. Sigue las instrucciones del README           ║
║  4. Asegurate de que quede en el PATH            ║
║                                                  ║
║  nxai status                                    ║
╚══════════════════════════════════════════════════╝
STUB_EOF

log_warn "qwen-code requiere instalacion manual — segui las instrucciones arriba"
exit 0
