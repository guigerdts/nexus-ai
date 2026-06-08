#!/usr/bin/env bash
# modules/codegraph/test.sh
# Verifica si codegraph esta instalado
set -euo pipefail

BINARY="${AGENT_BINARY:-codegraph}"

if command -v "$BINARY" &>/dev/null; then
    echo "PASS: codegraph encontrado en PATH ($(command -v "$BINARY"))"
    "$BINARY" --version 2>/dev/null | head -3 || true
    exit 0
else
    echo "FAIL: codegraph no encontrado en PATH"
    echo "INFO: Ejecuta: nxai install codegraph"
    exit 1
fi
