#!/usr/bin/env bash
# modules/qwen-code/test.sh
# Verifica si qwen-code esta instalado
set -euo pipefail

BINARY="${AGENT_BINARY:-qwen}"

if command -v "$BINARY" &>/dev/null; then
    echo "PASS: qwen-code encontrado en PATH ($(command -v "$BINARY"))"
    "$BINARY" --version 2>/dev/null | head -3 || true
    exit 0
else
    echo "FAIL: qwen-code no encontrado en PATH"
    echo "INFO: Ejecuta: nxai install qwen-code"
    exit 1
fi
