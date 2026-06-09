#!/usr/bin/env bash
# modules/powerlevel10k/test.sh
# Verifica si powerlevel10k esta instalado (es tema zsh, no binario)
set -euo pipefail

NEXUS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
NAME="powerlevel10k"

if [ -d "$NEXUS_ROOT/shell/plugins/$NAME" ]; then
    echo "PASS: $NAME encontrado en shell/plugins/"
    exit 0
elif [ -d "${HOME}/.oh-my-zsh/custom/themes/$NAME" ]; then
    echo "PASS: $NAME encontrado en oh-my-zsh/themes"
    exit 0
elif [ -d "${HOME}/.oh-my-zsh/custom/plugins/$NAME" ]; then
    echo "PASS: $NAME encontrado en oh-my-zsh/plugins"
    exit 0
else
    echo "FAIL: $NAME no encontrado en shell/plugins/ ni oh-my-zsh"
    exit 1
fi
