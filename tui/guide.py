#!/usr/bin/env python3
"""
NEXUS AI — Guide interactivo con Rich
Uso: python3 tui/guide.py [categoria|--interactive]
"""

import sys
import subprocess
from rich.console import Console
from rich.table import Table
from rich.prompt import Prompt

console = Console()

CATEGORIES = {
    "ai": {
        "title": "IA / Agentes",
        "tools": [
            ("opencode", "CLI multi-modelo 150K+ stars", "nxai install opencode"),
            ("codex", "OpenAI Codex CLI", "nxai install codex"),
            ("claude-code", "Claude Code CLI", "nxai install claude-code"),
            ("openclou", "OpenCLO UI agent", "nxai install openclou"),
            ("antigravity", "Autonomous coding agent", "nxai install antigravity"),
            ("pi", "Terminal AI assistant", "nxai install pi"),
            ("gentle-ai", "OpenCode Gentle AI", "nxai install gentle-ai"),
            ("engram", "Persistent memory agent", "nxai install engram"),
        ]
    },
    "editor": {
        "title": "Editores",
        "tools": [
            ("aider", "Coding AI Git-nativo", "nxai install aider"),
            ("neovim", "Editor de texto avanzado", "(stub)"),
        ]
    },
    "shell": {
        "title": "Terminal / Shell",
        "tools": [
            ("sgpt", "ShellGPT AI assistant", "nxai install sgpt"),
            ("zsh", "Z shell mejorado", "(stub)"),
            ("starship", "Prompt minimalista", "(stub)"),
        ]
    },
    "tools": {
        "title": "Herramientas",
        "tools": [
            ("fabric", "AI-powered CLI toolkit", "nxai install fabric"),
            ("goose", "Autonomous agent framework", "nxai install goose"),
            ("gh", "GitHub CLI", "(stub)"),
            ("fzf", "Fuzzy finder", "(stub)"),
            ("gum", "Shell scripting UI", "(stub)"),
            ("curl", "HTTP client", "(stub)"),
        ]
    },
    "language": {
        "title": "Lenguajes",
        "tools": [
            ("node", "JavaScript runtime", "(stub)"),
            ("python", "Python language", "(stub)"),
            ("rust", "Rust systems language", "(stub)"),
            ("go", "Go programming language", "(stub)"),
        ]
    },
    "db": {
        "title": "Bases de Datos",
        "tools": [
            ("sqlite", "Base de datos embebida", "(stub)"),
            ("postgresql", "Base de datos relacional", "(stub)"),
        ]
    },
    "ui": {
        "title": "Interfaz de Usuario",
        "tools": [
            ("termux-ui", "Interfaz Termux", "(stub)"),
            ("banner", "Personalizar banner", "(stub)"),
        ]
    },
    "automation": {
        "title": "Automatizacion",
        "tools": [
            ("n8n", "Workflow automation", "(stub)"),
        ]
    }
}


def show_category(cat_name):
    """Show a single category table."""
    cat = CATEGORIES.get(cat_name)
    if not cat:
        console.print(f"[red]Categoria desconocida: {cat_name}[/red]")
        console.print("Categorias disponibles: " + ", ".join(CATEGORIES.keys()))
        return

    table = Table(title=cat["title"], title_style="bold cyan")
    table.add_column("Herramienta", style="cyan", no_wrap=True)
    table.add_column("Descripcion", style="white")
    table.add_column("Instalar", style="dim")

    for name, desc, install in cat["tools"]:
        table.add_row(name, desc, install)

    console.print(table)


def show_all():
    """Show all categories."""
    for cat_name in CATEGORIES:
        show_category(cat_name)


def interactive_menu():
    """Interactive menu to select and install tools."""
    console.print("[bold cyan]Guia Interactiva NEXUS AI[/bold cyan]")
    console.print("")

    # Build flat tool list
    all_tools = []
    for cat_name, cat in CATEGORIES.items():
        for name, desc, install_cmd in cat["tools"]:
            if "(stub)" not in install_cmd:
                all_tools.append((name, desc, install_cmd, cat_name))

    # Show category menu first
    cat_names = list(CATEGORIES.keys())
    console.print("[bold]Categorias disponibles:[/bold]")
    for i, name in enumerate(cat_names, 1):
        console.print(f"  {i}. {name}")

    choice = Prompt.ask(
        "Selecciona una categoria (o 'all' para todas, 'q' para salir)",
        default="all"
    )

    if choice.lower() == 'q':
        return

    if choice.lower() == 'all':
        target_cats = list(CATEGORIES.keys())
    else:
        try:
            idx = int(choice) - 1
            if 0 <= idx < len(cat_names):
                target_cats = [cat_names[idx]]
            else:
                console.print("[red]Opcion invalida[/red]")
                return
        except ValueError:
            if choice in CATEGORIES:
                target_cats = [choice]
            else:
                console.print(f"[red]Categoria desconocida: {choice}[/red]")
                return

    # Show tools from selected categories
    tools_to_show = []
    for cat_name in target_cats:
        cat = CATEGORIES[cat_name]
        for name, desc, install_cmd in cat["tools"]:
            tools_to_show.append((name, desc, install_cmd, cat_name))

    console.print("\n[bold]Herramientas disponibles:[/bold]")
    for i, (name, desc, install_cmd, cat_name) in enumerate(tools_to_show, 1):
        stub_mark = " [dim](stub)[/dim]" if "(stub)" in install_cmd else ""
        console.print(f"  {i}. {name} — {desc}{stub_mark}")

    tool_choice = Prompt.ask(
        "Selecciona una herramienta para instalar (o 'q' para salir)"
    )

    if tool_choice.lower() == 'q':
        return

    try:
        idx = int(tool_choice) - 1
        if 0 <= idx < len(tools_to_show):
            name, desc, install_cmd, cat_name = tools_to_show[idx]
            if "(stub)" in install_cmd:
                console.print(f"[yellow]'{name}' es un stub — aun no disponible para instalacion.[/yellow]")
            else:
                console.print(f"[cyan]Instalando {name}...[/cyan]")
                result = subprocess.run(install_cmd.split(), capture_output=True, text=True)
                if result.returncode == 0:
                    console.print(f"[green]✓ {name} instalado correctamente[/green]")
                else:
                    console.print(f"[red]✗ Error instalando {name}: {result.stderr}[/red]")
        else:
            console.print("[red]Opcion invalida[/red]")
    except ValueError:
        console.print("[red]Ingresa un numero valido[/red]")


def main():
    if len(sys.argv) == 1:
        show_all()
    elif sys.argv[1] == "--interactive":
        interactive_menu()
    elif sys.argv[1] in CATEGORIES:
        show_category(sys.argv[1])
    else:
        console.print(f"[red]Uso: python3 guide.py [categoria|--interactive][/red]")
        sys.exit(1)


if __name__ == "__main__":
    main()
