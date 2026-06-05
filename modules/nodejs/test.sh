#!/usr/bin/env bash
# modules/nodejs/test.sh
set -euo pipefail
if command -v node &>/dev/null; then
    echo "PASS: nodejs ($(node --version 2>/dev/null | head -1))"
    exit 0
else
    echo "FAIL: nodejs no encontrado en PATH"
    exit 1
fi
