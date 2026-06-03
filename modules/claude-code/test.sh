#!/usr/bin/env bash
# modules/claude-code/test.sh
# Verifica si claude-code esta instalado (no bloquea si no lo esta)
command -v claude-code || echo "[INFO] claude-code no instalado (manual)" && exit 0
