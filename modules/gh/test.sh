#!/usr/bin/env bash
# modules/gh/test.sh
set -euo pipefail
if command -v gh &>/dev/null; then
    echo "PASS: gh ($(gh --version 2>/dev/null | head -1))"
    exit 0
else
    echo "FAIL: gh no encontrado en PATH"
    exit 1
fi
