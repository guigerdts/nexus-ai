#!/usr/bin/env bash
# modules/rust/test.sh
set -euo pipefail
if command -v rustc &>/dev/null; then
    echo "PASS: rust ($(rustc --version 2>/dev/null | head -1))"
    exit 0
else
    echo "FAIL: rust no encontrado en PATH"
    exit 1
fi
