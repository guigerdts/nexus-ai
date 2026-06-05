#!/usr/bin/env bash
# modules/wget/test.sh
set -euo pipefail
if command -v wget &>/dev/null; then
    echo "PASS: wget ($(wget --version 2>/dev/null | head -1))"
    exit 0
else
    echo "FAIL: wget no encontrado en PATH"
    exit 1
fi
