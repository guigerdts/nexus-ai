#!/usr/bin/env bash
# modules/codegraph/test.sh
set -euo pipefail
BINARY="codegraph"
if [ -z "$BINARY" ] || command -v "$BINARY" &>/dev/null; then
    echo "PASS: codegraph (stub — verificacion manual)"
    exit 0
else
    echo "FAIL: codegraph no encontrado en PATH"
    echo "INFO: codegraph requiere instalacion manual"
    exit 1
fi
