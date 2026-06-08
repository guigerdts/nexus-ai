#!/usr/bin/env bash
# modules/gentle-ai/test.sh
# Verifica si gentle-ai esta instalado
set -euo pipefail

BINARY="${AGENT_BINARY:-gentle-ai}"

if command -v "$BINARY" &>/dev/null; then
    echo "PASS: gentle-ai encontrado en PATH ($(command -v "$BINARY"))"
    "$BINARY" --help 2>/dev/null | head -5 || true
    exit 0
else
    echo "FAIL: gentle-ai no encontrado en PATH"
    echo "INFO: Ejecuta: nxai install gentle-ai"
    exit 1
fi
