#!/usr/bin/env bash
# modules/sgpt/test.sh
# Verifica que sgpt esta instalado en PATH
# NOTA: no ejecutar sgpt --version porque pide API key interactiva
command -v sgpt &>/dev/null
exit $?
