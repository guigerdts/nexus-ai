#!/usr/bin/env bash
# modules/pm2/test.sh
set -euo pipefail
if command -v pm2 &>/dev/null; then
    echo "PASS: pm2 ($(pm2 --version 2>/dev/null || echo '??'))"
    exit 0
else
    echo "FAIL: pm2 no encontrado en PATH"
    exit 1
fi
