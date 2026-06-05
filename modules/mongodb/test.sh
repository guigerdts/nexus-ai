#!/usr/bin/env bash
# modules/mongodb/test.sh
set -euo pipefail
BINARY="mongod"
if [ -z "$BINARY" ] || command -v "$BINARY" &>/dev/null; then
    echo "PASS: mongodb (stub — verificacion manual)"
    exit 0
else
    echo "FAIL: mongodb no encontrado en PATH"
    echo "INFO: mongodb requiere instalacion manual"
    exit 1
fi
