#!/usr/bin/env bash
# NEXUS AI — shell/motd.sh
# Mensaje de bienvenida con arte ASCII, información del sistema y tip aleatorio
# Version: 0.1.0
#
# Se ejecuta al abrir una terminal. Responsive: compacto si <60 columnas.

# ── Source config/env.sh (si existe) ──────────────
_motd_src="${BASH_SOURCE[0]}"
_motd_dir="$(cd "$(dirname "$_motd_src")" && pwd 2>/dev/null)"
if [ -f "$_motd_dir/../config/env.sh" ]; then
    # shellcheck source=../config/env.sh
    source "$_motd_dir/../config/env.sh"
fi
unset _motd_src _motd_dir

# ── Valores por defecto (si env.sh no existe) ─────
NEXUS_VERSION="${NEXUS_VERSION:-0.8.0}"
COLOR_GRAY='\033[1;30m'

# ── Forzar banner completo (usado por install.sh) ──
# NEXUS_MOTD_MODE=full salta la detección de ancho y
# siempre muestra el ASCII art grande.
NEXUS_MOTD_MODE="${NEXUS_MOTD_MODE:-auto}"

# ── Arte ASCII bloque (figlet -f big) ──
# Usa solo caracteres ASCII estándar para compatibilidad con
# Termux/proot ARM64 donde los bloques Unicode no renderizan bien.
ascii_art_block() {
    echo -e "${NEXUS_COLOR_PRIMARY}"
    echo ' _   _ ________   ___    _  _____            _____ '
    echo '| \ | |  ____\ \ / / |  | |/ ____|     /\   |_   _|'
    echo '|  \| | |__   \ V /| |  | | (___      /  \    | |  '
    echo '| . ` | |__   > < | |  | |\___ \    / /\ \   | |  '
    echo '| |\  | |____ / . \| |__| |____) |  / ____ \ _| |_ '
    echo '|_| \_|______/_/ \_\\____/|_____/  /_/    \_\_____|'
    echo ""
    echo -e "${COLOR_GRAY}Framework de Entorno para AI Agents${NEXUS_COLOR_RESET}"
}

# ── Compacto una línea (<60 cols) ─────────────────
ascii_art_compact() {
    echo -e "${NEXUS_COLOR_PRIMARY}### NEXUS AI v${NEXUS_VERSION}${NEXUS_COLOR_RESET}"
}

# ── Separador decorativo ──────────────────────────
separator() {
    echo -e "${NEXUS_COLOR_PRIMARY}========================================${NEXUS_COLOR_RESET}"
}

# ── Contar agentes instalados ────────────────────
count_agents() {
    local agents_dir="${NEXUS_AGENTS_DIR:-${NEXUS_ROOT}/modules}"
    if [ -d "$agents_dir" ]; then
        # Usar find en vez de ls + glob para evitar exit code ≠ 0
        # con set -euo pipefail cuando el directorio está vacío
        find "$agents_dir" -mindepth 1 -maxdepth 1 -type d -not -name '.*' 2>/dev/null | wc -l
    else
        echo "0"
    fi
}

# ── Tips en español (array) ───────────────────────
TIPS=(
    "Usa 'nxai help' para ver los comandos disponibles."

    "Ejecuta 'nxai install --all' para instalar todos los agentes."

    "Ejecuta 'nxai status' para ver el estado del sistema."

    "Usa 'nxai list' para listar todos los agentes disponibles."

    "Prueba un agente con 'nxai agent test <nombre>'."

    "Anade un agente personalizado con 'nxai agent add <nombre> <url>'."

    "Explora los modulos con 'nxai guide' para ver todas las categorias."

    "Revisa 'nxai remove <agente>' para desinstalar un agente."
    "Puedes personalizar tu prompt en shell/starship.toml."
    "Ejecuta 'install.sh --help' para ver todas las opciones."
    "Los plugins de Zsh estan en shell/plugins/."
    "Usa 'source ~/.zshrc' para recargar la configuracion."
    "NEXUS AI funciona en Termux nativo y proot-Ubuntu."
)

# ── Tip aleatorio ─────────────────────────────────
random_tip() {
    local idx=$(( RANDOM % ${#TIPS[@]} ))
    echo -e "${NEXUS_COLOR_PRIMARY}>>>${NEXUS_COLOR_RESET} ${TIPS[$idx]}"
}

# ═══════════════════════════════════════════════════
#  MAIN
# ═══════════════════════════════════════════════════

# Detectar ancho de terminal
if [ "${NEXUS_MOTD_MODE:-auto}" = "full" ]; then
    cols=80
elif [ -t 1 ]; then
    cols=$(tput cols 2>/dev/null) || cols=$(stty size 2>/dev/null | cut -d' ' -f2) || cols=80
else
    cols=80
fi

# ── Cabecera ──────────────────────────────────────
separator

if [ "$cols" -lt 60 ]; then
    ascii_art_compact
else
    ascii_art_block
fi

# ── Info dinámica ─────────────────────────────────
agent_count=$(count_agents)
fecha=$(date "+%Y-%m-%d %H:%M")

echo -e "${NEXUS_COLOR_PRIMARY}Versión ${NEXUS_VERSION}${NEXUS_COLOR_RESET} | ${agent_count} agente(s) instalados | ${fecha}"
echo ""

# ── Tip aleatorio ─────────────────────────────────
random_tip

separator

# ── Footer ────────────────────────────────────────
echo -e "${COLOR_GRAY}by GUIGERDTS${NEXUS_COLOR_RESET}"
echo ""
