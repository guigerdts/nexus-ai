#!/usr/bin/env bash
# modules/zsh/test.sh
set -euo pipefail
if command -v zsh &>/dev/null; then
    echo "PASS: zsh ($(zsh --version 2>/dev/null | head -1))"
    exit 0
else
    echo "FAIL: zsh no encontrado en PATH"
    exit 1
fi
