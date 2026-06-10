#!/usr/bin/env bash
# modules/claude-code/test.sh
# Verifica si claude-code esta instalado (no bloquea si no lo esta)
command -v claude &>/dev/null || { echo "[INFO] claude-code no instalado (manual)"; exit 1; }
