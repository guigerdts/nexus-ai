#!/usr/bin/env bash
# NEXUS AI — lib/nexus-guide.sh
# Guia interactiva por categorias
# Version: 0.6.0

# ── show_guide: muestra todas las categorias ──
show_guide() {
    echo ""
    echo "=== Guia NEXUS AI por Categorias ==="
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
            echo "IA / Agentes"
            echo "============"
            echo "Herramienta     Descripcion                    Instalar"
            echo "----------     -----------                    --------"
            echo "opencode        CLI multi-modelo 150K+ stars   nxai install opencode"
            echo "codex           OpenAI Codex CLI               nxai install codex"
            echo "claude-code     Claude Code CLI                nxai install claude-code"
            echo "openclou        OpenCLO UI agent               nxai install openclou"
            echo "antigravity     Autonomous coding agent        nxai install antigravity"
            echo "pi              Terminal AI assistant          nxai install pi"
            echo "gentle-ai       OpenCode Gentle AI             nxai install gentle-ai"
            echo "engram          Persistent memory agent        nxai install engram"
            echo ""
            echo "Desinstalar: nxai remove <herramienta>"
            echo ""
            ;;
        editor)
            echo "Editores"
            echo "========"
            echo "Herramienta     Descripcion                    Instalar"
            echo "----------     -----------                    --------"
            echo "aider           Coding AI Git-nativo           nxai install aider"
            echo "neovim          Editor de texto avanzado       (stub)"
            echo ""
            echo "Desinstalar: nxai remove <herramienta>"
            echo ""
            ;;
        shell)
            echo "Terminal / Shell"
            echo "================"
            echo "Herramienta     Descripcion                    Instalar"
            echo "----------     -----------                    --------"
            echo "sgpt            ShellGPT AI assistant          nxai install sgpt"
            echo "zsh             Z shell mejorado               (stub)"
            echo "starship        Prompt minimalista             (stub)"
            echo ""
            echo "Desinstalar: nxai remove <herramienta>"
            echo ""
            ;;
        tools)
            echo "Herramientas"
            echo "============"
            echo "Herramienta     Descripcion                    Instalar"
            echo "----------     -----------                    --------"
            echo "fabric          AI-powered CLI toolkit         nxai install fabric"
            echo "goose           Autonomous agent framework     nxai install goose"
            echo "gh              GitHub CLI                     (stub)"
            echo "fzf             Fuzzy finder                   (stub)"
            echo "gum             Shell scripting UI             (stub)"
            echo "curl            HTTP client                    (stub)"
            echo ""
            echo "Desinstalar: nxai remove <herramienta>"
            echo ""
            ;;
        language)
            echo "Lenguajes"
            echo "========="
            echo "Herramienta     Descripcion                    Instalar"
            echo "----------     -----------                    --------"
            echo "node            JavaScript runtime             (stub)"
            echo "python          Python language                (stub)"
            echo "rust            Rust systems language          (stub)"
            echo "go              Go programming language        (stub)"
            echo ""
            ;;
        db)
            echo "Bases de Datos"
            echo "=============="
            echo "Herramienta     Descripcion                    Instalar"
            echo "----------     -----------                    --------"
            echo "sqlite          Base de datos embebida         (stub)"
            echo "postgresql      Base de datos relacional       (stub)"
            echo ""
            ;;
        ui)
            echo "Interfaz de Usuario"
            echo "==================="
            echo "Herramienta     Descripcion                    Instalar"
            echo "----------     -----------                    --------"
            echo "termux-ui       Interfaz Termux                (stub)"
            echo "banner          Personalizar banner            (stub)"
            echo ""
            ;;
        automation)
            echo "Automatizacion"
            echo "=============="
            echo "Herramienta     Descripcion                    Instalar"
            echo "----------     -----------                    --------"
            echo "n8n             Workflow automation            (stub)"
            echo ""
            ;;
        *)
            echo "Categoria desconocida: $_cat"
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
        echo "[INFO] Rich no disponible. Usando guia basica."
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
