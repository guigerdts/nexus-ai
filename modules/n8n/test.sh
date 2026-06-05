#!/usr/bin/env bash
# modules/n8n/test.sh
set -euo pipefail
if command -v n8n &>/dev/null; then
    echo "PASS: n8n ($(n8n --version 2>/dev/null || echo '??'))"
    exit 0
else
    echo "FAIL: n8n no encontrado en PATH"
    exit 1
fi
