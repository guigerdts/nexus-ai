# >>> NEXUS AI BEGIN >>>
# ============================================
# NEXUS AI — shell/.bashrc
# Configuración de Bash para el framework NEXUS AI
# Version: 0.1.0
# ============================================

# ── Determinar NEXUS_ROOT ─────────────────────────
# Si env.sh ya está cargado, NEXUS_ROOT ya existe.
if [ -z "${NEXUS_ROOT:-}" ]; then
    # Auto-detección desde la ubicación de este archivo
    _bash_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
    NEXUS_ROOT="$(cd "$_bash_dir/.." 2>/dev/null && pwd || true)"
    unset _bash_dir
fi

# ── Source env.sh ─────────────────────────────────
if [ -n "$NEXUS_ROOT" ] && [ -f "$NEXUS_ROOT/config/env.sh" ]; then
    # shellcheck source=../config/env.sh
    source "$NEXUS_ROOT/config/env.sh"
fi

# ── Cargar config centralizada nexus.env ─────────
# Si el archivo existe, reemplaza los PATH inline.
# Si no existe, confia en env.sh que ya agrego los PATH esenciales.
if [ -f "$NEXUS_ROOT/config/nexus.env" ]; then
    source "$NEXUS_ROOT/config/nexus.env"
fi

# ═══════════════════════════════════════════════════
#  MOTD
# ═══════════════════════════════════════════════════
if [ -n "$NEXUS_ROOT" ] && [ -f "$NEXUS_ROOT/shell/motd.sh" ]; then
    # shellcheck source=../shell/motd.sh
    source "$NEXUS_ROOT/shell/motd.sh"
fi
# <<< NEXUS AI END <<<
