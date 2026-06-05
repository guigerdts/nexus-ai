#!/usr/bin/env bash
# modules/neovim/test.sh
set -euo pipefail
if command -v nvim &>/dev/null; then
    echo "PASS: neovim ($(nvim --version 2>/dev/null | head -2 | tail -1))"
    exit 0
else
    echo "FAIL: neovim no encontrado en PATH"
    exit 1
fi
