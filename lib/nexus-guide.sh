#!/usr/bin/env bash
# NEXUS AI — lib/nexus-guide.sh
# Guia interactiva por categorias
# Version: 0.8.0

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
    show_guide_category "node"
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
                "opencode"     "CLI multi-modelo 150K+ stars"              "nxai install opencode" \
                "codex"        "OpenAI Codex CLI"                          "nxai install codex" \
                "gemini-cli"   "CLI oficial de Google Gemini"              "nxai install gemini-cli" \
                "claude-code"  "Claude Code CLI de Anthropic"              "nxai install claude-code" \
                "ollama"       "Ejecuta LLMs locales (LLaMA, Mistral)"     "nxai install ollama" \
                "engram"       "Memoria persistente para sesiones de IA"   "nxai install engram" \
                "sgpt"         "Asistente de terminal GPT"                 "nxai install sgpt" \
                "fabric"       "Framework de automatizacion con IA"        "nxai install fabric" \
                "antigravity"  "CLI experimental de IA"                    "(stub)" \
                "pi"           "Asistente de IA desde terminal"            "(stub)" \
                "gentle-ai"    "CLI de desarrollo asistido por IA"         "(fuente)" \
                "qwen-code"    "CLI de codigo asistido por Qwen AI"        "(npm)" \
                "minimax-cli"  "CLI multimodal para MiniMax AI"            "(mmx-cli)" \
                "codegraph"    "Analizador de grafos de codigo con IA"     "(stub)" \
                "openclaude"   "CLI de IA para programacion"               "(stub)" \
                "mistral-vibe" "CLI para Mistral AI Vibe coding"           "(stub)"
            ;;
        editor)
            _print_category "Editores" "yes" \
                "neovim"   "Editor moderno con LSP nativo"                 "nxai install neovim" \
                "nvchad"   "Configuracion NvChad para Neovim"              "nxai install nvchad"
            ;;
        shell)
            _print_category "Terminal / Shell" "yes" \
                "zsh"       "Z shell con plugins y temas"                  "nxai install zsh" \
                "starship"  "Prompt minimalista personalizable"            "nxai install starship" \
                "oh-my-zsh" "Framework para gestionar Zsh"                 "nxai install oh-my-zsh" \
                "sgpt"      "Asistente de terminal GPT"                    "nxai install sgpt"
            ;;
        tools)
            _print_category "Herramientas" "yes" \
                "gh"       "GitHub CLI oficial"                            "nxai install gh" \
                "bat"      "cat con sintaxis coloreada"                    "nxai install bat" \
                "eza"      "ls moderno con colores y arbol"                "nxai install eza" \
                "lazygit"  "UI interactiva para Git"                       "nxai install lazygit" \
                "jq"       "Procesador JSON de linea de comandos"          "nxai install jq" \
                "fzf"      "Buscador difuso interactivo"                   "nxai install fzf" \
                "gum"      "Toolkit de UI para shell scripts"              "nxai install gum" \
                "curl"     "Cliente HTTP/HTTPS para transferencia"         "nxai install curl" \
                "git"      "Sistema de control de versiones distribuido"   "nxai install git" \
                "wget"     "Descarga de archivos via HTTP/HTTPS/FTP"       "nxai install wget"
            ;;
        language)
            _print_category "Lenguajes" "yes" \
                "nodejs"   "Entorno JavaScript Node.js y npm"              "nxai install nodejs" \
                "python"   "Python 3 interprete y pip"                     "nxai install python" \
                "rust"     "Compilador Rust y cargo"                       "nxai install rust" \
                "golang"   "Lenguaje Go — compilador y herramientas"       "nxai install golang" \
                "perl"     "Lenguaje de programacion Perl"                 "nxai install perl" \
                "php"      "Lenguaje de programacion PHP"                  "nxai install php" \
                "clang"    "Compilador C/C++ LLVM Clang"                   "nxai install clang"
            ;;
        db)
            _print_category "Bases de Datos" "yes" \
                "sqlite"     "BD SQL embebida zero-config"                 "nxai install sqlite" \
                "postgresql" "BD SQL relacional PostgreSQL"                "nxai install postgresql" \
                "mariadb"    "BD SQL fork de MySQL — rapida y open source" "nxai install mariadb" \
                "mongodb"    "BD NoSQL orientada a documentos"             "(stub)"
            ;;
        node)
            _print_category "Node.js" "yes" \
                "typescript" "Compilador de TypeScript a JavaScript"       "nxai install typescript" \
                "pm2"        "Administrador de procesos Node.js"           "nxai install pm2" \
                "nodemon"    "Monitor de reinicio automatico para Node.js" "nxai install nodemon"
            ;;
        ui)
            _print_category "Interfaz de Usuario" "yes" \
                "termux-styling" "Personalizacion visual de Termux"        "(stub)" \
                "nerd-fonts"     "Fuentes Nerd Fonts para terminal"        "(stub)" \
                "banner"         "Banner ASCII de NEXUS AI (ya incluido)"  "(stub)"
            ;;
        automation)
            _print_category "Automatizacion" "yes" \
                "n8n" "Workflow automation — alternativa a Zapier"        "nxai install n8n"
            ;;
        *)
            echo -e "${_YELLOW}Categoria desconocida: ${_cat}${_RESET}"
            echo "Categorias disponibles: ai, editor, shell, tools, language, db, node, ui, automation"
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
