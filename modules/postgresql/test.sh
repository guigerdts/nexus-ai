#!/usr/bin/env bash
# modules/postgresql/test.sh
set -euo pipefail
if command -v psql &>/dev/null; then
    echo "PASS: postgresql ($(psql --version 2>/dev/null | head -1))"
    exit 0
else
    echo "FAIL: postgresql no encontrado en PATH"
    exit 1
fi
