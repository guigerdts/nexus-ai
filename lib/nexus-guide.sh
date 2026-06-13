#!/usr/bin/env bash
# NEXUS AI — lib/nexus-guide.sh
# Guia interactiva por categorias
# Version: 0.8.0

# ── Colores ANSI ──
_CYAN=$'\033[96m'
_YELLOW=$'\033[33m'
_GRAY=$'\033[2m\033[90m'
_RESET=$'\033[0m'
_SEP="══════════════════════════════"

# ── _print_category: renderiza una categoria ──
# Uso: _print_category "Titulo" tiene_uninstall herramientas...
_print_category() {
    local _title="$1"
    shift
    local _has_uninstall="$1"
    shift

    # Terminal width calculation (same as core/nexus.sh)
    local _cols _bw _inner _i
    _cols=$(tput cols 2>/dev/null || echo 80)
    _bw=$(( _cols - 2 ))
    [ "$_bw" -lt 78 ] && _bw=78
    [ "$_bw" -gt 86 ] && _bw=86
    _inner=$(( _bw - 2 ))

    # Build category content into an array (preserves newlines)
    local -a _lines=()
    _lines+=("")
    _lines+=("${_CYAN}${_SEP}${_RESET}")
    _lines+=("${_CYAN}  ${_title}${_RESET}")
    _lines+=("${_CYAN}${_SEP}${_RESET}")
    _lines+=("$(printf "%-16s %-35s %s" "Herramienta" "Descripcion" "Instalar")")
    _lines+=("$(printf "%-16s %-35s %s" "----------------" "-----------------------------------" "--------")")

    # Herramientas
    local _name _desc _cmd
    while [ $# -gt 0 ]; do
        _name="$1"
        _desc="$2"
        _cmd="$3"
        shift 3

        if [ "$_cmd" = "(stub)" ]; then
            _lines+=("$(printf "%-16s %-35s ${_GRAY}%s${_RESET}" "$_name" "$_desc" "$_cmd")")
        else
            _lines+=("$(printf "%-16s %-35s ${_YELLOW}%s${_RESET}" "$_name" "$_desc" "$_cmd")")
        fi
    done

    # Desinstalar
    if [ "$_has_uninstall" = "yes" ]; then
        _lines+=("${_GRAY}Desinstalar: nxai remove <herramienta>${_RESET}")
    fi
    _lines+=("")

    # Draw top border: ╭─╮
    printf '\033[38;5;201m╭'
    for ((_i=0; _i<_inner; _i++)); do printf '─'; done
    printf '╮\033[0m\n'

    # Content lines with padding
    local _line _plain _visible _pad
    for _line in "${_lines[@]}"; do
        _plain=$(sed $'s/\x1b\[[0-9;]*[a-zA-Z]//g' <<< "$_line")
        _visible=${#_plain}
        _pad=$(( _inner - _visible ))
        [ "$_pad" -lt 0 ] && _pad=0
        printf '\033[38;5;201m│\033[0m%s%*s\033[38;5;201m│\033[0m\n' "$_line" "$_pad" ''
    done

    # Draw bottom border: ╰─╯
    printf '\033[38;5;201m╰'
    for ((_i=0; _i<_inner; _i++)); do printf '─'; done
    printf '╯\033[0m\n'
}

# ── show_guide: muestra todas las categorias ──
show_guide() {
    # Compute terminal width for figlet measurement (same as core/nexus.sh)
    local _cols _bw _inner
    _cols=$(tput cols 2>/dev/null || echo 80)
    _bw=$(( _cols - 2 ))
    [ "$_bw" -lt 78 ] && _bw=78
    [ "$_bw" -gt 86 ] && _bw=86
    _inner=$(( _bw - 2 ))

    echo ""

    # Dynamic figlet title with font chain and fallback
    local _figlet_printed=false
    if command -v figlet >/dev/null 2>&1; then
        local _figlet_output _max_width _font
        for _font in "small" "mini" ""; do
            if [ -n "$_font" ]; then
                _figlet_output=$(figlet -f "$_font" "NEXUS AI GUIA" 2>/dev/null)
            else
                _figlet_output=$(figlet "NEXUS AI GUIA" 2>/dev/null)
            fi
            [ -z "$_figlet_output" ] && continue
            _max_width=$(echo "$_figlet_output" | wc -L)
            if [ "$_max_width" -le "$_inner" ]; then
                printf '\033[96m%s\033[0m\n' "$_figlet_output"
                printf '\033[96mPOR CATEGORIAS\033[0m\n\n'
                _figlet_printed=true
                break
            fi
        done
    fi

    # Fallback: figlet not available or no font fit
    if [ "$_figlet_printed" != "true" ]; then
        printf '\n'
        printf '\033[96m════════════════════════════════════════\033[0m\n'
        printf '\033[96m  NEXUS AI GUIA POR CATEGORIAS\033[0m\n'
        printf '\033[96m════════════════════════════════════════\033[0m\n'
        printf '\n'
    fi

    show_guide_category "ai"
    show_guide_category "editor"
    show_guide_category "shell"
    show_guide_category "tools"
    show_guide_category "language"
    show_guide_category "db"
    show_guide_category "node"
    show_guide_category "ui"
    show_guide_category "automation"
    show_guide_category "scaffolding"
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
                "codegraph"    "Grafo de codigo pre-indexado para agentes AI" "(npm)" \
                "openclaude"   "CLI de IA para programacion"               "(stub)" \
                "mistral-vibe" "CLI para Mistral AI Vibe coding"           "(pip)"
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
        scaffolding)
            _print_category "Scaffolding de Proyectos" "no" \
                "nextjs"   "Next.js app con App Router"                    "nxai create nextjs <name>" \
                "vite"     "Vite + React/Vue/Svelte starter"               "nxai create vite <name>" \
                "express"  "Express.js API server (local template)"        "nxai create express <name>" \
                "nestjs"   "NestJS framework application"                  "nxai create nestjs <name>"
            ;;
        *)
            echo -e "${_YELLOW}Categoria desconocida: ${_cat}${_RESET}"
            echo "Categorias disponibles: ai, editor, shell, tools, language, db, node, ui, automation, scaffolding"
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
