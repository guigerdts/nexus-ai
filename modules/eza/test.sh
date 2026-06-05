#!/usr/bin/env bash
# modules/eza/test.sh
set -euo pipefail
if command -v eza &>/dev/null; then
    echo "PASS: eza ($(eza --version 2>/dev/null | head -1))"
    exit 0
else
    echo "FAIL: eza no encontrado en PATH"
    exit 1
fi
