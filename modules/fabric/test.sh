#!/usr/bin/env bash
# modules/fabric/test.sh
# Verifica que fabric esta instalado y responde
command -v fabric && fabric --version >/dev/null 2>&1
exit $?
