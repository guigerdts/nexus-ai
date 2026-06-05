#!/usr/bin/env bash
# modules/git/test.sh
set -euo pipefail
if command -v git &>/dev/null; then
    echo "PASS: git ($(git --version 2>/dev/null | head -1))"
    exit 0
else
    echo "FAIL: git no encontrado en PATH"
    exit 1
fi
