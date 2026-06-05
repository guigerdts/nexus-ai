#!/usr/bin/env bash
# modules/fzf/test.sh
set -euo pipefail
if command -v fzf &>/dev/null; then
    echo "PASS: fzf ($(fzf --version 2>/dev/null | head -1))"
    exit 0
else
    echo "FAIL: fzf no encontrado en PATH"
    exit 1
fi
