#!/usr/bin/env bash
# modules/claude-code/install.sh
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── claude-code: instalacion manual (pesada) ───────
cat <<'EOF'
╔══════════════════════════════════════════════════════════════╗
║  claude-code — Claude Code CLI de Anthropic                  ║
║                                                              ║
║  ⚠️  INSTALACION PESADA — puede requerir ~2GB en Termux     ║
║                                                              ║
║  La instalacion automatizada no esta disponible.             ║
║                                                              ║
║  1. Instala Node.js (v18+):                                  ║
║       pkg install nodejs  (Termux)                           ║
║       apt install nodejs   (proot-Ubuntu)                    ║
║                                                              ║
║  2. Instala globalmente:                                     ║
║       npm install -g @anthropic-ai/claude-code               ║
║                                                              ║
║  ⚠️  En Termux nativo, la instalacion puede consumir        ║
║     mucha RAM y espacio. Se recomienda proot-Ubuntu.         ║
║                                                              ║
║  Una vez instalado, ejecuta:  nxai status                   ║
╚══════════════════════════════════════════════════════════════╝
EOF

log_warn "claude-code requiere instalacion manual (pesada)"
exit 0
