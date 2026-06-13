#!/usr/bin/env python3
"""NEXUS AI Dashboard TUI — Main application.

Usage:
    python3 /path/to/tui/dashboard.py

Or via nxai:
    nxai dashboard
"""

import os
import subprocess
import sys

from rich.text import Text
from textual.app import App, ComposeResult
from textual.binding import Binding
from textual.theme import Theme
from textual.widgets import DataTable, Footer, Header, Static

# Ensure NEXUS_ROOT is on sys.path so absolute package imports work
# whether the script is invoked as __main__ (exec via nexus.sh) or via -m tui.
_nexus_root = os.environ.get("NEXUS_ROOT")
if _nexus_root and _nexus_root not in sys.path:
    sys.path.insert(0, _nexus_root)

from tui.agents_panel import load_agents
from tui.history import read_entries
from tui.system_monitor import collect, check_update


# ── Inline CSS ──────────────────────────────────────
CSS = """
Screen {
    background: #1a1a2e;
}

Header {
    background: #00BCD4;
    color: #1a1a2e;
}

Footer {
    background: #00BCD4;
    color: #1a1a2e;
}

QuickGuide {
    border: solid #00BCD4;
    padding: 1;
    margin: 0 1;
    height: auto;
    max-height: 20;
}

AgentPanel {
    border: solid #00BCD4;
    padding: 0;
    margin: 0 1;
    height: auto;
    max-height: 20;
}

MonitorPanel {
    border: solid #00BCD4;
    padding: 1;
    margin: 0 1;
    height: auto;
    max-height: 12;
}

HistoryPanel {
    border: solid #00BCD4;
    padding: 0;
    margin: 0 1;
    height: auto;
    max-height: 12;
}
"""


# ── Quick Guide Panel ───────────────────────────────
class QuickGuide(Static):
    """Panel de guia rapida con contenido estatico."""

    BORDER_TITLE = "Guia Rapida"

    def on_mount(self) -> None:
        self.populate()

    def populate(self) -> None:
        self.update(
            "[bold]NEXUS AI[/bold] - Framework Bash/Shell para gestionar "
            "agentes de IA en Termux + proot-Ubuntu\n"
            "\n"
            "Instalar:\n"
            "  curl -fsSL https://raw.githubusercontent.com/guigerdts/"
            "nexus-ai/main/install.sh | bash\n"
            "\n"
            "Desinstalar:\n"
            "  1. rm -rf ~/nexus-ai\n"
            "  2. rm -f ~/.local/bin/nxai\n"
            "  (y borrar el bloque NEXUS AI de ~/.bashrc y ~/.zshrc)\n"
            "\n"
            "[bold]Comandos:[/bold]\n"
            "  install   Instala uno o todos los agentes\n"
            "  remove    Desinstala un agente\n"
            "  list      Lista agentes registrados\n"
            "  status    Muestra estado del sistema\n"
            "  agent     Gestiona agentes (add / test)\n"
            "  help      Muestra ayuda del CLI"
        )


# ── Monitor Panel ───────────────────────────────────
class MonitorPanel(Static):
    """Panel de monitor del sistema."""

    BORDER_TITLE = "Monitor del Sistema"

    def populate(self, data: dict) -> None:
        lines = []
        # Update notification at the top if available
        update_version = data.get("update_version")
        if update_version:
            lines.append(f"[bold yellow]Actualizacion disponible: {update_version}[/bold yellow]")
            lines.append("")  # blank line for separation

        lines.extend([
            f"RAM:       {data['ram_used']} MB / {data['ram_total']} MB",
            f"Disco:     {data['disk_used']} GB / {data['disk_total']} GB",
            f"Entorno:   {data['env']}",
            f"Arquitectura: {data['arch']}",
            f"Python:    {data['python_version']}",
            f"Zsh:       {data['zsh_version']}",
            f"Git:       {data['git_version']}",
        ])
        self.update("\n".join(lines))


# ── History Panel ───────────────────────────────────
class HistoryPanel(DataTable):
    """Panel de historial de operaciones."""

    BORDER_TITLE = "Historial"

    def populate(self, entries: list[dict]) -> None:
        cursor = self.cursor_type
        self.cursor_type = "none"
        self.clear()
        self.add_columns("Fecha", "Accion", "Agente", "Resultado")
        if not entries:
            self.add_row(
                Text("No hay historial de operaciones", style="italic"),
                "", "", "",
            )
            self.cursor_type = cursor
            return
        for entry in entries:
            self.add_row(
                entry.get("date", ""),
                entry.get("action", ""),
                entry.get("agent", ""),
                entry.get("result", ""),
            )
        self.cursor_type = cursor


# ── Agent Panel ─────────────────────────────────────
class AgentPanel(DataTable):
    """Panel de agentes con estado y accion por fila."""

    BORDER_TITLE = "Agentes"

    def __init__(self, nexus_root: str, **kwargs):
        super().__init__(**kwargs)
        self.nexus_root = nexus_root
        self._agents: list[dict] = []

    def populate(self, agents: list[dict]) -> None:
        self._agents = agents
        cursor = self.cursor_type
        self.cursor_type = "row"
        self.clear()
        self.add_columns("Nombre", "Tier", "Estado", "Descripcion")
        for agent in agents:
            installed = agent.get("installed", False)
            status = (
                Text("INSTALADO", style="bold cyan")
                if installed
                else Text("NO INSTALADO", style="bold yellow")
            )
            self.add_row(
                agent.get("name", ""),
                str(agent.get("tier", "")),
                status,
                agent.get("desc", ""),
                key=agent.get("name", ""),
            )
        self.cursor_type = cursor

    def on_data_table_row_selected(
        self, event: DataTable.RowSelected
    ) -> None:
        """Handle row selection — triggers install or remove."""
        agent_name = str(event.row_key.value)
        agent = next(
            (a for a in self._agents if a["name"] == agent_name), None
        )
        if not agent:
            return

        installed = agent.get("installed", False)
        action = "remove" if installed else "install"
        nxai = os.path.join(self.nexus_root, "bin", "nxai")

        try:
            subprocess.run(
                [nxai, action, agent_name],
                capture_output=True,
                text=True,
                timeout=60,
            )
        except (FileNotFoundError, subprocess.TimeoutExpired):
            pass

        # Re-check status after action
        refreshed = load_agents(self.nexus_root)
        self.populate(refreshed)


# ── Main App ────────────────────────────────────────
class NexusDashboard(App):
    """Aplicacion principal del Dashboard TUI de NEXUS AI."""

    CSS = CSS
    BINDINGS = [
        Binding("q", "quit", "Salir"),
        Binding("r", "refresh", "Refrescar"),
        Binding("1", "focus_panel('guia')", "Guia"),
        Binding("2", "focus_panel('agentes')", "Agentes"),
        Binding("3", "focus_panel('monitor')", "Monitor"),
        Binding("4", "focus_panel('historial')", "Historial"),
    ]

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.nexus_root = os.environ.get("NEXUS_ROOT", "")
        self.nexus_version = os.environ.get("NEXUS_VERSION", "0.2.0")
        self.nexus_env = os.environ.get("NEXUS_ENV", "unknown")

    def compose(self) -> ComposeResult:
        yield Header(show_clock=True)
        yield QuickGuide()
        yield AgentPanel(self.nexus_root)
        yield MonitorPanel()
        yield HistoryPanel()
        yield Footer()

    def on_mount(self) -> None:
        """Register theme, set title, and load initial data."""
        theme = Theme(
            name="nexus-dark",
            primary="#00BCD4",
            secondary="#00BCD4",
            surface="#1a1a2e",
            background="#1a1a2e",
        )
        self.register_theme(theme)
        self.theme = "nexus-dark"

        self.title = f"NEXUS AI v{self.nexus_version} - {self.nexus_env}"

        self._refresh_all()

    # ── Actions ─────────────────────────────────────
    def action_refresh(self) -> None:
        """Refrescar todos los paneles (tecla R)."""
        self._refresh_all()

    def action_focus_panel(self, panel: str) -> None:
        """Enfocar un panel por su nombre de clase en minusculas."""
        mapping = {
            "guia": QuickGuide,
            "agentes": AgentPanel,
            "monitor": MonitorPanel,
            "historial": HistoryPanel,
        }
        cls = mapping.get(panel)
        if cls is not None:
            widget = self.query_one(cls)
            widget.scroll_visible()
            widget.focus()

    # ── Internal ────────────────────────────────────
    def _refresh_all(self) -> None:
        """Recargar datos de todos los paneles."""
        nr = self.nexus_root

        try:
            mon_data = collect(nr)
            self.query_one(MonitorPanel).populate(mon_data)
        except Exception:
            pass

        try:
            history = read_entries(nr)
            self.query_one(HistoryPanel).populate(history)
        except Exception:
            pass

        try:
            agents = load_agents(nr)
            self.query_one(AgentPanel).populate(agents)
        except Exception:
            pass


def main() -> None:
    """Entry point for the TUI dashboard."""
    app = NexusDashboard()
    app.run()


if __name__ == "__main__":
    main()
