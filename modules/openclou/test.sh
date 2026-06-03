#!/usr/bin/env bash
# modules/openclou/test.sh
# Verifica si openclou esta instalado (no bloquea si no lo esta)
command -v oclou || echo "[INFO] openclou no instalado (manual)" && exit 0
