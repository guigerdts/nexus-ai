#!/usr/bin/env bash
# modules/php/test.sh
set -euo pipefail
if command -v php &>/dev/null; then
    echo "PASS: php ($(php --version 2>/dev/null | head -1))"
    exit 0
else
    echo "FAIL: php no encontrado en PATH"
    exit 1
fi
