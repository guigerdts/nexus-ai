#!/usr/bin/env bash
# modules/agy/test.sh
set -euo pipefail
if command -v agy &>/dev/null; then
    echo "PASS: agy ($(agy --version 2>/dev/null || echo '??'))"
    exit 0
else
    echo "FAIL: agy no encontrado en PATH"
    exit 1
fi
