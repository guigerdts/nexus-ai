#!/usr/bin/env bash
# modules/typescript/test.sh
set -euo pipefail
if command -v tsc &>/dev/null; then
    echo "PASS: typescript ($(tsc --version 2>/dev/null || echo '??'))"
    exit 0
else
    echo "FAIL: typescript no encontrado en PATH"
    exit 1
fi
