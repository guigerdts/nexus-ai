#!/usr/bin/env bash
# modules/jq/test.sh
set -euo pipefail
if command -v jq &>/dev/null; then
    echo "PASS: jq ($(jq --version 2>/dev/null | head -1))"
    exit 0
else
    echo "FAIL: jq no encontrado en PATH"
    exit 1
fi
