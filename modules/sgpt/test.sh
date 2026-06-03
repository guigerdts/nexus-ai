#!/usr/bin/env bash
# modules/sgpt/test.sh
# Verifica que sgpt esta instalado y responde
command -v sgpt && sgpt --version >/dev/null 2>&1
exit $?
