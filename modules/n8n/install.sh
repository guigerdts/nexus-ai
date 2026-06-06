#!/usr/bin/env bash
# modules/n8n/install.sh
# n8n es pesado para instalar via npm en ARM64.
# Stub con instrucciones manuales.
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

cat <<'STUB_EOF'
╔══════════════════════════════════════════════════╗
║  n8n — Workflow automation                        ║
║                                                   ║
║  n8n requiere mucha RAM (>2GB) para compilar.     ║
║                                                   ║
║  Instalacion manual:                              ║
║   npm install -g n8n                              ║
║   (puede tardar 10-15 min en ARM64)               ║
║                                                   ║
║  Alternativa con Docker:                          ║
║   docker run -it --rm \                           ║
║     -p 5678:5678 \                                ║
║     n8nio/n8n                                     ║
║                                                   ║
║  Web: https://n8n.io                              ║
╚══════════════════════════════════════════════════╝
STUB_EOF

log_ok "n8n — segui las instrucciones manuales arriba"
exit 0
