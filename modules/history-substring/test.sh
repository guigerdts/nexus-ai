#!/usr/bin/env bash
# modules/history-substring/test.sh
# Verifica si el plugin history-substring esta instalado (es directorio, no binario)
set -euo pipefail

NEXUS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
NAME="history-substring"

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
