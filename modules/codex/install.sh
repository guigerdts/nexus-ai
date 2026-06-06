#!/usr/bin/env bash
# modules/codex/install.sh
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── Codex CLI: stub para ARM64 ─────────────────────
# Codex CLI no tiene soporte oficial para ARM64. El paquete npm
# @openai/codex-linux-arm64 no existe en el registry, por lo que
# la instalacion falla con 404 en arquitecturas ARM.

cat <<'STUB_EOF'
╔══════════════════════════════════════════════════════════════╗
║  Codex CLI — OpenAI                                           ║
║                                                              ║
║  Codex CLI NO tiene soporte oficial para ARM64 / Termux.      ║
║  El paquete @openai/codex-linux-arm64 no existe en npm.      ║
║                                                              ║
║  Alternativas disponibles en NEXUS AI:                       ║
║                                                              ║
║    opencode:     nxai install opencode (multi-modelo)        ║
║    gemini-cli:   nxai install gemini-cli                     ║
║    claude-code:  nxai install claude-code                    ║
║                                                              ║
║  nxai status                                                ║
╚══════════════════════════════════════════════════════════════╝
STUB_EOF

log_warn "Codex CLI no esta disponible en ARM64 — elegi una alternativa de las listadas arriba"
exit 0
