#!/usr/bin/env bash
# modules/pi/test.sh
# Verifica que pi esta instalado y responde
command -v pi && pi --version >/dev/null 2>&1
exit $?
