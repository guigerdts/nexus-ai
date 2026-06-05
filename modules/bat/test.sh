#!/usr/bin/env bash
# modules/bat/test.sh
set -euo pipefail
if command -v bat &>/dev/null; then
    echo "PASS: bat ($(bat --version 2>/dev/null | head -1))"
    exit 0
else
    echo "FAIL: bat no encontrado en PATH"
    exit 1
fi
