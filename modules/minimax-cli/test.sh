#!/usr/bin/env bash
# modules/minimax-cli/test.sh
set -euo pipefail
BINARY="minimax"
if [ -z "$BINARY" ] || command -v "$BINARY" &>/dev/null; then
    echo "PASS: minimax-cli (stub — verificacion manual)"
    exit 0
else
    echo "FAIL: minimax-cli no encontrado en PATH"
    echo "INFO: minimax-cli requiere instalacion manual"
    exit 1
fi
