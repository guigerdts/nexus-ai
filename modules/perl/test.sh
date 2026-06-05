#!/usr/bin/env bash
# modules/perl/test.sh
set -euo pipefail
if command -v perl &>/dev/null; then
    echo "PASS: perl ($(perl --version 2>/dev/null | head -1))"
    exit 0
else
    echo "FAIL: perl no encontrado en PATH"
    exit 1
fi
