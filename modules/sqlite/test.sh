#!/usr/bin/env bash
# modules/sqlite/test.sh
set -euo pipefail
if command -v sqlite3 &>/dev/null; then
    echo "PASS: sqlite ($(sqlite3 --version 2>/dev/null | head -1))"
    exit 0
else
    echo "FAIL: sqlite no encontrado en PATH"
    exit 1
fi
