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
            ("gemini-cli", "CLI oficial de Google Gemini", "nxai install gemini-cli"),
            ("claude-code", "Claude Code CLI de Anthropic", "nxai install claude-code"),
            ("ollama", "Ejecuta LLMs locales (LLaMA, Mistral)", "nxai install ollama"),
            ("engram", "Memoria persistente para sesiones de IA", "nxai install engram"),
            ("sgpt", "Asistente de terminal GPT", "nxai install sgpt"),
            ("fabric", "Framework de automatizacion con IA", "nxai install fabric"),
            ("antigravity", "CLI experimental de IA", "(stub)"),
            ("pi", "Asistente de IA desde terminal", "(stub)"),
            ("gentle-ai", "CLI de desarrollo asistido por IA", "(stub)"),
            ("qwen-code", "CLI de codigo asistido por Qwen AI", "(stub)"),
            ("minimax-cli", "CLI para la API de MiniMax AI", "(stub)"),
            ("codegraph", "Analizador de grafos de codigo con IA", "(stub)"),
            ("openclaude", "CLI de IA para programacion", "(stub)"),
            ("mistral-vibe", "CLI para Mistral AI Vibe coding", "(stub)"),
        ]
    },
    "editor": {
        "title": "Editores",
        "tools": [
            ("neovim", "Editor moderno con LSP nativo", "nxai install neovim"),
            ("nvchad", "Configuracion NvChad para Neovim", "nxai install nvchad"),
        ]
    },
    "shell": {
        "title": "Terminal / Shell",
        "tools": [
            ("zsh", "Z shell con plugins y temas", "nxai install zsh"),
            ("starship", "Prompt minimalista personalizable", "nxai install starship"),
            ("oh-my-zsh", "Framework para gestionar Zsh", "nxai install oh-my-zsh"),
            ("sgpt", "Asistente de terminal GPT", "nxai install sgpt"),
        ]
    },
    "tools": {
        "title": "Herramientas",
        "tools": [
            ("gh", "GitHub CLI oficial", "nxai install gh"),
            ("bat", "cat con sintaxis coloreada", "nxai install bat"),
            ("eza", "ls moderno con colores y arbol", "nxai install eza"),
            ("lazygit", "UI interactiva para Git", "nxai install lazygit"),
            ("jq", "Procesador JSON de linea de comandos", "nxai install jq"),
            ("fzf", "Buscador difuso interactivo", "nxai install fzf"),
            ("gum", "Toolkit de UI para shell scripts", "nxai install gum"),
            ("curl", "Cliente HTTP/HTTPS para transferencia", "nxai install curl"),
            ("git", "Sistema de control de versiones distribuido", "nxai install git"),
            ("wget", "Descarga de archivos via HTTP/HTTPS/FTP", "nxai install wget"),
        ]
    },
    "language": {
        "title": "Lenguajes",
        "tools": [
            ("nodejs", "Entorno JavaScript Node.js y npm", "nxai install nodejs"),
            ("python", "Python 3 interprete y pip", "nxai install python"),
            ("rust", "Compilador Rust y cargo", "nxai install rust"),
            ("golang", "Lenguaje Go — compilador y herramientas", "nxai install golang"),
            ("perl", "Lenguaje de programacion Perl", "nxai install perl"),
            ("php", "Lenguaje de programacion PHP", "nxai install php"),
            ("clang", "Compilador C/C++ LLVM Clang", "nxai install clang"),
        ]
    },
    "db": {
        "title": "Bases de Datos",
        "tools": [
            ("sqlite", "BD SQL embebida zero-config", "nxai install sqlite"),
            ("postgresql", "BD SQL relacional PostgreSQL", "nxai install postgresql"),
            ("mariadb", "BD SQL fork de MySQL — rapida y open source", "nxai install mariadb"),
            ("mongodb", "BD NoSQL orientada a documentos", "(stub)"),
        ]
    },
    "node": {
        "title": "Node.js",
        "tools": [
            ("typescript", "Compilador de TypeScript a JavaScript", "nxai install typescript"),
            ("pm2", "Administrador de procesos Node.js", "nxai install pm2"),
            ("nodemon", "Monitor de reinicio automatico para Node.js", "nxai install nodemon"),
        ]
    },
    "ui": {
        "title": "Interfaz de Usuario",
        "tools": [
            ("termux-styling", "Personalizacion visual de Termux", "(stub)"),
            ("nerd-fonts", "Fuentes Nerd Fonts para terminal", "(stub)"),
            ("banner", "Banner ASCII de NEXUS AI (ya incluido)", "(stub)"),
        ]
    },
    "automation": {
        "title": "Automatizacion",
        "tools": [
            ("n8n", "Workflow automation — alternativa a Zapier", "nxai install n8n"),
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
