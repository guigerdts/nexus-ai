#!/usr/bin/env bash
# modules/lazygit/test.sh
set -euo pipefail
if command -v lazygit &>/dev/null; then
    echo "PASS: lazygit ($(lazygit --version 2>/dev/null | head -1))"
    exit 0
else
    echo "FAIL: lazygit no encontrado en PATH"
    exit 1
fi
