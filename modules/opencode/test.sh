#!/usr/bin/env bash
# modules/opencode/test.sh
# Verifica que opencode esta instalado y responde
command -v opencode && opencode --version >/dev/null 2>&1
exit $?
