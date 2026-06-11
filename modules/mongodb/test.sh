#!/usr/bin/env bash
# modules/mongodb/test.sh
set -euo pipefail
BINARY="mongod"
if command -v "$BINARY" &>/dev/null && timeout 2 "$BINARY" --version &>/dev/null; then
    echo "PASS: mongodb ($("$BINARY" --version 2>&1 | head -1))"
    exit 0
else
    echo "FAIL: mongodb no funciona correctamente"
    echo "INFO: ejecuta 'mongod --version' para ver el error"
    exit 1
fi
