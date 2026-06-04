#!/usr/bin/env bash
# NEXUS AI — lib/nexus-guide.sh
# Guia interactiva por categorias
# Version: 0.6.0

# ── Colores ANSI ──
_CYAN="\033[96m"
_YELLOW="\033[33m"
_GRAY="\033[2m\033[90m"
_RESET="\033[0m"
_SEP="══════════════════════════════"

# ── _print_category: renderiza una categoria ──
# Uso: _print_category "Titulo" herramientas[] tiene_uninstall
_print_category() {
    local _title="$1"
    shift
    local _has_uninstall="$1"
    shift
    local _name _desc _cmd

    # Header cian
    echo ""
    echo -e "${_CYAN}${_SEP}${_RESET}"
    echo -e "${_CYAN}  ${_title}${_RESET}"
    echo -e "${_CYAN}${_SEP}${_RESET}"

    # Columnas
    printf "%-16s %-35s %s\n" "Herramienta" "Descripcion" "Instalar"
    printf "%-16s %-35s %s\n" "----------------" "-----------------------------------" "--------"

    # Herramientas
    while [ $# -gt 0 ]; do
        _name="$1"
        _desc="$2"
        _cmd="$3"
        shift 3

        if [ "$_cmd" = "(stub)" ]; then
            printf "%-16s %-35s ${_GRAY}%s${_RESET}\n" "$_name" "$_desc" "$_cmd"
        else
            printf "%-16s %-35s ${_YELLOW}%s${_RESET}\n" "$_name" "$_desc" "$_cmd"
        fi
    done

    # Desinstalar
    if [ "$_has_uninstall" = "yes" ]; then
        echo -e "${_GRAY}Desinstalar: nxai remove <herramienta>${_RESET}"
    fi
    echo ""
}

# ── show_guide: muestra todas las categorias ──
show_guide() {
    echo ""
    echo -e "${_CYAN}════════════════════════════════════════${_RESET}"
    echo -e "${_CYAN}  Guia NEXUS AI por Categorias${_RESET}"
    echo -e "${_CYAN}════════════════════════════════════════${_RESET}"
    echo ""

    show_guide_category "ai"
    show_guide_category "editor"
    show_guide_category "shell"
    show_guide_category "tools"
    show_guide_category "language"
    show_guide_category "db"
    show_guide_category "ui"
    show_guide_category "automation"
}

# ── show_guide_category: muestra una categoria ──
show_guide_category() {
    local _cat="${1:-}"
    [ -z "$_cat" ] && return 1

    case "$_cat" in
        ai)
            _print_category "IA / Agentes" "yes" \
                "opencode"    "CLI multi-modelo 150K+ stars"     "nxai install opencode" \
                "codex"       "OpenAI Codex CLI"                 "nxai install codex" \
                "claude-code" "Claude Code CLI"                  "nxai install claude-code" \
                "openclou"    "OpenCLO UI agent"                 "nxai install openclou" \
                "antigravity" "Autonomous coding agent"          "nxai install antigravity" \
                "pi"          "Terminal AI assistant"            "nxai install pi" \
                "gentle-ai"   "OpenCode Gentle AI"               "nxai install gentle-ai" \
                "engram"      "Persistent memory agent"          "nxai install engram"
            ;;
        editor)
            _print_category "Editores" "yes" \
                "aider"    "Coding AI Git-nativo"           "nxai install aider" \
                "neovim"   "Editor de texto avanzado"      "(stub)"
            ;;
        shell)
            _print_category "Terminal / Shell" "yes" \
                "sgpt"     "ShellGPT AI assistant"         "nxai install sgpt" \
                "zsh"      "Z shell mejorado"              "(stub)" \
                "starship" "Prompt minimalista"            "(stub)"
            ;;
        tools)
            _print_category "Herramientas" "yes" \
                "fabric"   "AI-powered CLI toolkit"        "nxai install fabric" \
                "goose"    "Autonomous agent framework"    "nxai install goose" \
                "gh"       "GitHub CLI"                    "(stub)" \
                "fzf"      "Fuzzy finder"                  "(stub)" \
                "gum"      "Shell scripting UI"            "(stub)" \
                "curl"     "HTTP client"                   "(stub)"
            ;;
        language)
            _print_category "Lenguajes" "yes" \
                "node"   "JavaScript runtime"              "(stub)" \
                "python" "Python language"                 "(stub)" \
                "rust"   "Rust systems language"           "(stub)" \
                "go"     "Go programming language"         "(stub)"
            ;;
        db)
            _print_category "Bases de Datos" "yes" \
                "sqlite"     "Base de datos embebida"      "(stub)" \
                "postgresql" "Base de datos relacional"    "(stub)"
            ;;
        ui)
            _print_category "Interfaz de Usuario" "yes" \
                "termux-ui" "Interfaz Termux"              "(stub)" \
                "banner"    "Personalizar banner"          "(stub)"
            ;;
        automation)
            _print_category "Automatizacion" "yes" \
                "n8n" "Workflow automation"                "(stub)"
            ;;
        *)
            echo -e "${_YELLOW}Categoria desconocida: ${_cat}${_RESET}"
            echo "Categorias disponibles: ai, editor, shell, tools, language, db, ui, automation"
            return 1
            ;;
    esac
}

# ── show_guide_rich: lanza guia Rich si esta disponible ──
show_guide_rich() {
    if [ "$NEXUS_RICH_AVAILABLE" = "true" ]; then
        python3 "$NEXUS_ROOT/tui/guide.py" "$@"
    else
        echo -e "${_YELLOW}[INFO]${_RESET} Rich no disponible. Usando guia basica."
        if [ $# -eq 0 ] || [ "$1" = "--interactive" ] || [ "$1" = "-i" ]; then
            show_guide
        else
            show_guide_category "$1"
        fi
    fi
}

# Si se ejecuta directamente
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    echo "Este modulo debe ser sourced desde nexus.sh"
    exit 1
fi
