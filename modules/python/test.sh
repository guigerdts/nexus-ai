#!/usr/bin/env bash
# modules/python/test.sh
set -euo pipefail
if command -v python3 &>/dev/null; then
    echo "PASS: python ($(python3 --version 2>/dev/null | head -1))"
    exit 0
else
    echo "FAIL: python no encontrado en PATH"
    exit 1
fi
