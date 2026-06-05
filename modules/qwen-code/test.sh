#!/usr/bin/env bash
# modules/qwen-code/test.sh
set -euo pipefail
BINARY="qwen"
if [ -z "$BINARY" ] || command -v "$BINARY" &>/dev/null; then
    echo "PASS: qwen-code (stub — verificacion manual)"
    exit 0
else
    echo "FAIL: qwen-code no encontrado en PATH"
    echo "INFO: qwen-code requiere instalacion manual"
    exit 1
fi
