#!/usr/bin/env bash
# modules/openclaude/test.sh
# Verifica si openclaude esta instalado (no bloquea si no lo esta)
command -v openclaude || echo "[INFO] openclaude no instalado (manual)" && exit 0
