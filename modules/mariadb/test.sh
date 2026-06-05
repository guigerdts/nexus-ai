#!/usr/bin/env bash
# modules/mariadb/test.sh
set -euo pipefail
if command -v mariadb &>/dev/null; then
    echo "PASS: mariadb ($(mariadb --version 2>/dev/null | head -1))"
    exit 0
else
    echo "FAIL: mariadb no encontrado en PATH"
    exit 1
fi
