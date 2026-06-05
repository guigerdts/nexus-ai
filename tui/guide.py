#!/usr/bin/env python3
"""
NEXUS AI — Guide interactivo con Rich
Uso: python3 tui/guide.py [categoria|--interactive]
"""

import os
import shutil
import sys
import subprocess
from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from rich.prompt import Prompt, Confirm
from rich import box

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


def build_category_table(cat_name):
    """Build a Rich Table for a category with colored rows."""
    cat = CATEGORIES.get(cat_name)
    if not cat:
        return None

    table = Table(
        title=cat["title"],
        title_style="bold cyan",
        header_style="bold cyan",
        box=box.ROUNDED,
        border_style="cyan",
    )
    table.add_column("Herramienta", style="cyan", no_wrap=True)
    table.add_column("Descripcion", style="white")
    table.add_column("Estado", style="bold", no_wrap=True)
    table.add_column("Comando", no_wrap=True)

    for name, desc, install_cmd in cat["tools"]:
        if "(stub)" in install_cmd:
            estado = "[yellow]NO INSTALADO[/yellow]"
            comando = "[dim](stub)[/dim]"
        else:
            is_installed = shutil.which(name) is not None
            estado = "[green]INSTALADO[/green]" if is_installed else "[yellow]NO INSTALADO[/yellow]"
            comando = f"[yellow]{install_cmd}[/yellow]"

        table.add_row(name, desc, estado, comando)

    return table


def show_category(cat_name):
    """Show a single category as a Rich Panel with Table."""
    cat = CATEGORIES.get(cat_name)
    if not cat:
        console.print(f"[red]Categoria desconocida: {cat_name}[/red]")
        console.print("Categorias disponibles: " + ", ".join(CATEGORIES.keys()))
        return

    table = build_category_table(cat_name)
    if table:
        panel = Panel(
            table,
            title=f"[bold cyan]{cat['title']}[/bold cyan]",
            border_style="cyan",
            box=box.DOUBLE,
        )
        console.print(panel)


def show_all():
    """Show all categories as Panels."""
    for cat_name in CATEGORIES:
        show_category(cat_name)


def interactive_menu():
    """Interactive menu to select and install tools."""
    console.print(Panel(
        "[bold cyan]Guia Interactiva NEXUS AI[/bold cyan]\n"
        "[dim]Selecciona una categoria y herramienta para instalar[/dim]",
        border_style="cyan",
        box=box.DOUBLE,
    ))

    cat_names = list(CATEGORIES.keys())

    while True:
        # Step 1: pick category
        console.print("\n[bold]Categorias disponibles:[/bold]")
        for i, name in enumerate(cat_names, 1):
            console.print(f"  [cyan]{i}.[/cyan] {name}")

        choice = Prompt.ask(
            "\n[bold]Selecciona una categoria[/bold] (numero, nombre, 'all' para todas, 'q' para salir)",
            default="all"
        )

        if choice.lower() == 'q':
            break

        if choice.lower() == 'all':
            target_cats = list(CATEGORIES.keys())
        else:
            try:
                idx = int(choice) - 1
                if 0 <= idx < len(cat_names):
                    target_cats = [cat_names[idx]]
                else:
                    console.print("[red]Opcion invalida[/red]")
                    continue
            except ValueError:
                if choice in CATEGORIES:
                    target_cats = [choice]
                else:
                    console.print(f"[red]Categoria desconocida: {choice}[/red]")
                    continue

        # Step 2: show tools from selected categories
        tools_to_show = []
        for cat_name in target_cats:
            cat = CATEGORIES[cat_name]
            for name, desc, install_cmd in cat["tools"]:
                tools_to_show.append((name, desc, install_cmd, cat_name))

        if not tools_to_show:
            console.print("[yellow]No hay herramientas en esta categoria.[/yellow]")
            console.print("[dim]Presiona Enter para continuar...[/dim]")
            Prompt.ask("")
            continue

        console.print(f"\n[bold]Herramientas en [cyan]{', '.join(target_cats)}[/cyan]:[/bold]")
        tool_table = Table(box=box.SIMPLE, show_header=False)
        tool_table.add_column("#", style="dim", no_wrap=True)
        tool_table.add_column("Herramienta", style="cyan", no_wrap=True)
        tool_table.add_column("Descripcion", style="white")
        tool_table.add_column("Estado", no_wrap=True)

        for i, (name, desc, install_cmd, cat_name) in enumerate(tools_to_show, 1):
            if "(stub)" in install_cmd:
                estado = "[yellow]NO INSTALADO[/yellow]"
            else:
                is_installed = shutil.which(name) is not None
                estado = "[green]INSTALADO[/green]" if is_installed else "[yellow]NO INSTALADO[/yellow]"
            tool_table.add_row(str(i), name, desc, estado)

        console.print(tool_table)

        # Step 3: pick tool
        tool_choice = Prompt.ask(
            "\n[bold]Selecciona una herramienta para instalar[/bold] (numero o 'q' para salir)"
        )

        if tool_choice.lower() == 'q':
            break

        try:
            idx = int(tool_choice) - 1
            if 0 <= idx < len(tools_to_show):
                name, desc, install_cmd, cat_name = tools_to_show[idx]

                if "(stub)" in install_cmd:
                    console.print(f"\n[yellow]'{name}' es un stub — aun no disponible para instalacion.[/yellow]")
                    console.print("[dim]Presiona Enter para continuar...[/dim]")
                    Prompt.ask("")
                    continue

                # Confirm before installing
                if not Confirm.ask(f"\n[bold]¿Instalar [cyan]{name}[/cyan]?[/bold]"):
                    console.print("[dim]Cancelado.[/dim]")
                    continue

                console.print(f"[cyan]Instalando {name}...[/cyan]")
                try:
                    nexus_root = os.environ.get("NEXUS_ROOT", "")
                    nxai_bin = os.path.join(nexus_root, "bin", "nxai")
                    if not nexus_root or not os.path.isfile(nxai_bin):
                        console.print(f"\n[red]✗ NEXUS_ROOT no encontrado o nxai no disponible en {nxai_bin}[/red]")
                        continue
                    subprocess.run([nxai_bin, "install", name], timeout=300)
                    if shutil.which(name) is not None:
                        console.print(f"\n[green]✓ {name} instalado correctamente[/green]")
                    else:
                        console.print(f"\n[red]✗ {name} NO se instalo — verifica con 'which {name}'[/red]")
                except subprocess.TimeoutExpired:
                    console.print(f"\n[red]✗ Timeout: {name} no se instalo en 5 minutos[/red]")
            else:
                console.print("[red]Opcion invalida[/red]")
        except ValueError:
            console.print("[red]Ingresa un numero valido[/red]")

        console.print("[dim]Presiona Enter para volver al menu de categorias...[/dim]")
        Prompt.ask("")


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
