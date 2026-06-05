#!/usr/bin/env bash
# modules/oh-my-zsh/test.sh
set -euo pipefail
if [ -d "${HOME}/.oh-my-zsh" ]; then
    echo "PASS: oh-my-zsh instalado en ${HOME}/.oh-my-zsh"
    exit 0
else
    echo "FAIL: oh-my-zsh no encontrado en ${HOME}/.oh-my-zsh"
    exit 1
fi
