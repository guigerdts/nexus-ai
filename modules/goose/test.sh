#!/usr/bin/env bash
# modules/goose/test.sh
# Verifica que goose esta instalado y responde
command -v goose && goose --version >/dev/null 2>&1
exit $?
