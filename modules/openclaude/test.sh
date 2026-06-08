#!/usr/bin/env bash
# modules/openclaude/test.sh
# Verifica si openclaude esta instalado
set -euo pipefail

BINARY="${AGENT_BINARY:-openclaude}"

if command -v "$BINARY" &>/dev/null; then
    echo "PASS: openclaude encontrado en PATH ($(command -v "$BINARY"))"
    "$BINARY" --version 2>/dev/null | head -3 || true
    exit 0
else
    echo "FAIL: openclaude no encontrado en PATH"
    echo "INFO: Ejecuta: nxai install openclaude"
    exit 1
fi
