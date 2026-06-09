#!/usr/bin/env bash
# modules/openclaw/test.sh
# Verifica si openclaw esta instalado
set -euo pipefail

BINARY="${AGENT_BINARY:-openclaw}"

if command -v "$BINARY" &>/dev/null; then
    echo "PASS: openclaw encontrado en PATH ($(command -v "$BINARY"))"
    timeout 3 "$BINARY" --version 2>/dev/null | head -3 || true
    exit 0
else
    echo "FAIL: openclaw no encontrado en PATH"
    echo "INFO: Ejecuta: nxai install openclaw"
    exit 1
fi
