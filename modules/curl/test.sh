#!/usr/bin/env bash
# modules/curl/test.sh
set -euo pipefail
if command -v curl &>/dev/null; then
    echo "PASS: curl ($(curl --version 2>/dev/null | head -1))"
    exit 0
else
    echo "FAIL: curl no encontrado en PATH"
    exit 1
fi
