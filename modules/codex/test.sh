#!/usr/bin/env bash
# modules/codex/test.sh
# Verifica que codex esta instalado y responde
command -v codex && codex --version >/dev/null 2>&1
exit $?
