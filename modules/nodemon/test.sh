#!/usr/bin/env bash
# modules/nodemon/test.sh
set -euo pipefail
if command -v nodemon &>/dev/null; then
    echo "PASS: nodemon ($(nodemon --version 2>/dev/null || echo '??'))"
    exit 0
else
    echo "FAIL: nodemon no encontrado en PATH"
    exit 1
fi
