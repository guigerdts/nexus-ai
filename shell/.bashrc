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

# ── PATH (idempotente: solo agrega si no esta ya) ──
if [ -n "$NEXUS_ROOT" ] && [ -d "$NEXUS_ROOT/bin" ]; then
    case ":$PATH:" in
        *":$NEXUS_ROOT/bin:"*) ;;
        *) export PATH="$NEXUS_ROOT/bin:$PATH" ;;
    esac
fi

# ═══════════════════════════════════════════════════
#  MOTD
# ═══════════════════════════════════════════════════
if [ -n "$NEXUS_ROOT" ] && [ -f "$NEXUS_ROOT/shell/motd.sh" ]; then
    # shellcheck source=../shell/motd.sh
    source "$NEXUS_ROOT/shell/motd.sh"
fi
# <<< NEXUS AI END <<<
