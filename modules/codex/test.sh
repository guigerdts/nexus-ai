#!/usr/bin/env bash
# modules/codex/test.sh
# Codex CLI stub — no disponible en ARM64
if [ "${NEXUS_ARCH:-}" = "arm64" ]; then
    echo "INFO: Codex CLI no soportado en ARM64 — test omitido"
    exit 0
fi
command -v codex &>/dev/null || exit 1
