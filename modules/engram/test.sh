#!/usr/bin/env bash
# modules/engram/test.sh
# Verifica que engram esta instalado y responde
command -v engram && engram --version >/dev/null 2>&1
exit $?
