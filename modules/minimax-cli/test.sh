#!/usr/bin/env bash
# modules/minimax-cli/test.sh
# Verifica si minimax-cli (mmx) esta instalado
set -euo pipefail

BINARY="${AGENT_BINARY:-mmx}"

if command -v "$BINARY" &>/dev/null; then
    echo "PASS: minimax-cli encontrado en PATH ($(command -v "$BINARY"))"
    "$BINARY" --version 2>/dev/null | head -3 || true
    exit 0
else
    echo "FAIL: minimax-cli no encontrado en PATH"
    echo "INFO: Ejecuta: nxai install minimax-cli"
    exit 1
fi
