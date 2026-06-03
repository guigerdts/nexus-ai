#!/usr/bin/env bash
# modules/gentle-ai/test.sh
# Verifica si gentle-ai esta instalado (no bloquea si no lo esta)
command -v gentle || echo "[INFO] gentle-ai no instalado (manual)" && exit 0
