#!/usr/bin/env bash
# modules/mistral-vibe/test.sh
# Verifica si mistral-vibe (vibe) esta instalado
set -euo pipefail

BINARY="${AGENT_BINARY:-vibe}"

if command -v "$BINARY" &>/dev/null; then
    echo "PASS: mistral-vibe encontrado en PATH ($(command -v "$BINARY"))"
    "$BINARY" --version 2>/dev/null | head -3 || true
    exit 0
else
    echo "FAIL: mistral-vibe no encontrado en PATH"
    echo "INFO: Ejecuta: nxai install mistral-vibe"
    echo "INFO: Si ya instalaste, verifica: export PATH=\"\$HOME/.local/bin:\$PATH\""
    exit 1
fi
