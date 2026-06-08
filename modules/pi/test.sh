#!/usr/bin/env bash
# modules/pi/test.sh
# Verifica que pi esta instalado y responde
set -euo pipefail

BINARY="${AGENT_BINARY:-pi}"

if command -v "$BINARY" &>/dev/null; then
    echo "PASS: pi encontrado en PATH ($(command -v "$BINARY"))"
    "$BINARY" --version 2>/dev/null | head -3 || true
    exit 0
else
    echo "FAIL: pi no encontrado en PATH"
    echo "INFO: Ejecuta: nxai install pi"
    exit 1
fi
