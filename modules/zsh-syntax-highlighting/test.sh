#!/usr/bin/env bash
# modules/zsh-syntax-highlighting/test.sh
# Verifica si el plugin zsh-syntax-highlighting esta instalado (es directorio, no binario)
set -euo pipefail

NEXUS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
NAME="zsh-syntax-highlighting"

if [ -d "$NEXUS_ROOT/shell/plugins/$NAME" ]; then
    echo "PASS: $NAME encontrado en shell/plugins/"
    exit 0
elif [ -d "${HOME}/.oh-my-zsh/custom/plugins/$NAME" ]; then
    echo "PASS: $NAME encontrado en oh-my-zsh/plugins"
    exit 0
else
    echo "FAIL: $NAME no encontrado en shell/plugins/ ni oh-my-zsh/plugins"
    exit 1
fi
