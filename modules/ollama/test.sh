#!/usr/bin/env bash
# modules/ollama/test.sh
set -euo pipefail
if command -v ollama &>/dev/null; then
    echo "PASS: ollama ($(ollama --version 2>/dev/null || echo '??'))"
    exit 0
else
    echo "FAIL: ollama no encontrado en PATH"
    exit 1
fi
