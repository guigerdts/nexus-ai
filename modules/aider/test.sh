#!/usr/bin/env bash
# modules/aider/test.sh
# Verifica que aider esta instalado y responde
command -v aider && aider --version >/dev/null 2>&1
exit $?
