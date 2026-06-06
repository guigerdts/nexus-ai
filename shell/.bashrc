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

# ── Termux bind-mount PATH (hybrid mode) ────────
# Cuando se ejecuta dentro de proot-Ubuntu con bind-mounts
# a Termux, estos directorios contienen binarios utiles
# (pkg, pip3, python3, etc.). Cada entrada tiene guard condicional
# [ -d ] para no contaminar PATH en Linux puro.
if [ -d "/data/data/com.termux/files/usr/bin" ]; then
    case ":$PATH:" in
        *":/data/data/com.termux/files/usr/bin:"*) ;;
        *) export PATH="/data/data/com.termux/files/usr/bin:$PATH" ;;
    esac
fi
if [ -d "/data/data/com.termux/files/usr/local/bin" ]; then
    case ":$PATH:" in
        *":/data/data/com.termux/files/usr/local/bin:"*) ;;
        *) export PATH="/data/data/com.termux/files/usr/local/bin:$PATH" ;;
    esac
fi

# ── ~/.local/bin (uv, fabric, etc.) ────────────────
if [ -d "$HOME/.local/bin" ]; then
    case ":$PATH:" in
        *":$HOME/.local/bin:"*) ;;
        *) export PATH="$HOME/.local/bin:$PATH" ;;
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
