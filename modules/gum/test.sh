#!/usr/bin/env bash
# modules/gum/test.sh
set -euo pipefail
if command -v gum &>/dev/null; then
    echo "PASS: gum ($(gum --version 2>/dev/null | head -1))"
    exit 0
else
    echo "FAIL: gum no encontrado en PATH"
    exit 1
fi
