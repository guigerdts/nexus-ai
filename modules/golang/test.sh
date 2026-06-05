#!/usr/bin/env bash
# modules/golang/test.sh
set -euo pipefail
if command -v go &>/dev/null; then
    echo "PASS: golang ($(go version 2>/dev/null | head -1))"
    exit 0
else
    echo "FAIL: golang no encontrado en PATH"
    exit 1
fi
