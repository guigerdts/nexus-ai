#!/usr/bin/env bash
# modules/mimo-code/test.sh
# Verifica que mimo-code esta instalado y responde
command -v mimo && mimo --version >/dev/null 2>&1
exit $?
