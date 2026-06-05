#!/usr/bin/env bash
# modules/nvchad/test.sh
set -euo pipefail
if [ -f "${HOME}/.config/nvim/init.lua" ]; then
    echo "PASS: NvChad configurado en ${HOME}/.config/nvim"
    exit 0
else
    echo "FAIL: NvChad no encontrado en ${HOME}/.config/nvim/init.lua"
    exit 1
fi
