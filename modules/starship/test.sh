#!/usr/bin/env bash
# modules/starship/test.sh
set -euo pipefail
if command -v starship &>/dev/null; then
    echo "PASS: starship ($(starship --version 2>/dev/null | head -1))"
    exit 0
else
    echo "FAIL: starship no encontrado en PATH"
    exit 1
fi
