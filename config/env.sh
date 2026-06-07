#!/usr/bin/env bash
# NEXUS AI — config/env.sh
# Variables de entorno y detección del entorno de ejecución
# Version: 0.1.0

# ============================================
# Detectar directorio del script actual
# Compatible con Bash y Zsh
# ============================================
# ── Detectar script fuente ──────────────────────────
# Compatible con Bash y Zsh. Resuelve symlinks vía readlink -f.
if [ -n "${BASH_SOURCE[0]:-}" ]; then
    _nexus_script_src="${BASH_SOURCE[0]}"
    # Intentar readlink -f para resolver symlinks
    if command -v readlink &>/dev/null && _nexus_resolved="$(readlink -f "$_nexus_script_src" 2>/dev/null)"; then
        _nexus_script_dir="$(cd "$(dirname "$_nexus_resolved")" && pwd)"
        unset _nexus_resolved
    else
        # Fallback: no readlink -f disponible (Termux, entornos mínimos)
        _nexus_script_dir="$(cd "$(dirname "$_nexus_script_src")" && pwd)"
    fi
    unset _nexus_script_src
elif [ -n "${ZSH_VERSION:-}" ]; then
    # Zsh: (%):-%x da el nombre del archivo fuente
    # :A lo resuelve a ruta canónica (equivalente a readlink -f)
    _nexus_script_dir="${${(%):-%x}:A:h}"
else
    # Fallback genérico
    _nexus_script_dir="$(cd "$(dirname "$0")" && pwd)"
fi

# NEXUS_ROOT: directorio raíz del proyecto (padre de config/)
export NEXUS_ROOT="$(cd "$_nexus_script_dir/.." 2>/dev/null && pwd || echo "$_nexus_script_dir/..")"
unset _nexus_script_dir

# ============================================
# Versión e idioma
# ============================================
export NEXUS_VERSION="0.8.0"
export NEXUS_LANG="es"

# ============================================
# Detección de Rich (Python TUI)
# ============================================
_python_site=$(python3 -c "import site; print(site.getsitepackages()[0])" 2>/dev/null || true)
[ -n "$_python_site" ] && export PYTHONPATH="$_python_site:${PYTHONPATH:-}"
unset _python_site

if python3 -c "import rich" 2>/dev/null; then
    export NEXUS_RICH_AVAILABLE="true"
else
    export NEXUS_RICH_AVAILABLE="false"
fi

# ============================================
# Detección de Gum (Charm.sh)
# ============================================
export NEXUS_GUM_AVAILABLE=$(command -v gum &>/dev/null && echo true || echo false)

# ============================================
# Detección de entorno
# ============================================
if [ -n "${PREFIX:-}" ]; then
    # Termux establece $PREFIX
    export NEXUS_ENV="termux"
elif [ -n "${PROOT:-}" ]; then
    # proot-distro establece $PROOT dentro del guest
    export NEXUS_ENV="proot-ubuntu"
elif grep -q "proot" /proc/self/mountinfo 2>/dev/null; then
    # proot-distro: /proc/self/mountinfo contiene marcadores proot
    export NEXUS_ENV="proot-ubuntu"
elif [ -d "/data/data/com.termux/files/usr/var/lib/proot-distro" ] 2>/dev/null; then
    # Directorio de datos de proot-distro visible via bind mounts
    export NEXUS_ENV="proot-ubuntu"
else
    # Entorno Linux genérico (con advertencia)
    export NEXUS_ENV="linux"
fi

# ============================================
# Detección de Termux accesible (bind-mounts)
# ============================================
# Cuando NEXUS_ENV=proot-ubuntu y TERMUX_BIN existe y es ejecutable,
# significa que Termux está accesible via bind-mounts. En este modo
# híbrido (también llamado "hybrid mode") se pueden usar pkg y pip
# de Termux dentro de proot, evitando compilación desde source.
export NEXUS_TERMUX_ACCESSIBLE="false"
if [ "${NEXUS_ENV:-}" = "proot-ubuntu" ] && [ -x "/data/data/com.termux/files/usr/bin" ]; then
    export NEXUS_TERMUX_ACCESSIBLE="true"
    export TERMUX_BIN="/data/data/com.termux/files/usr/bin"
    export TERMUX_PREFIX="/data/data/com.termux/files/usr"
    export TERMUX_PKG="/data/data/com.termux/files/usr/bin/pkg"
    export TERMUX_PIP="/data/data/com.termux/files/usr/bin/pip3"
    export TERMUX_NPM="/data/data/com.termux/files/usr/bin/npm"

    # Prepend Termux bin dirs to PATH (idempotent via case guard)
    if [ -d "$TERMUX_BIN" ]; then
        case ":$PATH:" in
            *":$TERMUX_BIN:"*) ;;
            *) export PATH="$TERMUX_BIN:$PATH" ;;
        esac
    fi
    if [ -d "$TERMUX_PREFIX/local/bin" ]; then
        case ":$PATH:" in
            *":$TERMUX_PREFIX/local/bin:"*) ;;
            *) export PATH="$TERMUX_PREFIX/local/bin:$PATH" ;;
        esac
    fi
fi

# ============================================
# ~/.local/bin — binarios de usuario (uv, fabric, etc.)
# ============================================
if [ -d "$HOME/.local/bin" ]; then
    case ":$PATH:" in
        *":$HOME/.local/bin:"*) ;;
        *) export PATH="$HOME/.local/bin:$PATH" ;;
    esac
fi

# ============================================
# Detección de arquitectura
# ============================================
case "$(uname -m)" in
    aarch64|arm64)      export NEXUS_ARCH="arm64"  ;;
    x86_64|amd64)       export NEXUS_ARCH="x86_64" ;;
    *)                  export NEXUS_ARCH="desconocida" ;;
esac

# ============================================
# Directorios derivados
# ============================================
export NEXUS_AGENTS_DIR="$NEXUS_ROOT/modules"
export NEXUS_MODULES_DIR="$NEXUS_ROOT/modules"
export NEXUS_REGISTRY="$NEXUS_ROOT/config/agents.registry.sh"
export NEXUS_LOG_FILE="$NEXUS_ROOT/logs/nexus.log"

# ============================================
# Colores ANSI unificados
# ============================================
export NEXUS_COLOR_CYAN='\033[0;36m'
export NEXUS_COLOR_YELLOW='\033[0;33m'
export NEXUS_COLOR_RED='\033[0;31m'
export NEXUS_COLOR_GREEN='\033[0;32m'
export NEXUS_COLOR_GRAY='\033[0;37m'
export NEXUS_COLOR_RESET='\033[0m'
# Backward compat alias
export NEXUS_COLOR_PRIMARY="${NEXUS_COLOR_CYAN}"


