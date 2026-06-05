#!/usr/bin/env bash
# modules/clang/test.sh
set -euo pipefail
if command -v clang &>/dev/null; then
    echo "PASS: clang ($(clang --version 2>/dev/null | head -1))"
    exit 0
else
    echo "FAIL: clang no encontrado en PATH"
    exit 1
fi
