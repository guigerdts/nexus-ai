#!/usr/bin/env bash
# modules/gemini-cli/test.sh
set -euo pipefail
if command -v gemini &>/dev/null; then
    echo "PASS: gemini-cli ($(gemini --version 2>/dev/null || echo '??'))"
    exit 0
else
    echo "FAIL: gemini-cli no encontrado en PATH"
    exit 1
fi
