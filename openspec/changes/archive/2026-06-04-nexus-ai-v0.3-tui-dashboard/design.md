# Design: Dashboard TUI para NEXUS AI v0.3

## Technical Approach

Single `textual.App` with 4 custom widgets in a vertical layout. Python reads `modules/*/metadata.sh` directly (regex), checks `shutil.which(AGENT_BINARY)` for status, and calls `nxai install/remove` via `subprocess.run`. No psutil. `core/nexus.sh` sources `env.sh`, exports `NEXUS_ROOT`, checks `import textual`, then `exec python3 "$NEXUS_ROOT/tui/dashboard.py"`.

## Architecture Decisions

| Decision | Options | Chosen | Rationale |
|----------|---------|--------|-----------|
| App structure | Screens vs single-screen widgets | Single screen, 4 `Static`/`DataTable` widgets | No navigation or routing needed — all panels visible at once. `Footer` for keybindings. |
| Bash↔Python comm | env export + os.environ vs subprocess parsing | `export NEXUS_ROOT` before `exec`; Python reads `os.environ["NEXUS_ROOT"]` | Simplest. Bash sources `env.sh` and exports — Python inherits. Only `NEXUS_ROOT` needed; version/env from parsing `env.sh` directly. |
| Agent status detection | Subprocess source registry vs Python regex | Python reads `modules/*/metadata.sh` with regex, `shutil.which(AGENT_BINARY)` | Avoids subprocess overhead and fragility. Metadata format (`export VAR="val"`) is regex-safe. |
| System monitor | psutil vs /proc/meminfo | `/proc/meminfo` + `shutil.disk_usage()` | psutil not available in Termux by default. Both are stdlib/Linux-native. |
| Dependency check | Runtime Python import | `python3 -c "import textual"` before `exec` | Catches missing dep early with clear message. |

## Data Flow

```
User: nxai dashboard
  → core/nexus.sh: source config/env.sh (NEXUS_ROOT, NEXUS_ENV, etc.)
  → core/nexus.sh: export NEXUS_ROOT
  → core/nexus.sh: python3 -c "import textual" ? proceed : "pip install textual" + exit 1
  → core/nexus.sh: exec python3 $NEXUS_ROOT/tui/dashboard.py

tui/dashboard.py (textual.App)
  on_mount():
    ├── system_monitor.collect(NEXUS_ROOT)  → RAM, disk, env, versions
    ├── history.read(NEXUS_ROOT)            → last 20 agents.log entries
    └── agents_panel.load(NEXUS_ROOT)       → metadata + shutil.which status

  compose():
    ├── Header(NEXUS_VERSION + NEXUS_ENV)
    ├── QuickGuide(Rich Text, static)
    ├── AgentPanel(DataTable + Buttons)
    ├── MonitorPanel(Static w/ Rich Table)
    ├── HistoryPanel(DataTable)
    └── Footer(Q/R/1-4)

  on_button_pressed():
    ├── Install → subprocess.run([f"{nr}/bin/nxai", "install", f"--{agent}"])
    ├── Remove  → subprocess.run([f"{nr}/bin/nxai", "remove", agent])
    └── Refresh → recheck shutil.which() for all agents → update DataTable
```

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `tui/__init__.py` | Create | Empty package marker |
| `tui/requirements.txt` | Create | `textual` only (Rich is transitive) |
| `tui/dashboard.py` | Create | `textual.App` — compose(), on_mount(), theme, footer bindings |
| `tui/agents_panel.py` | Create | DataTable (Nombre/Tier/Estado) + Install/Remove buttons per agent |
| `tui/system_monitor.py` | Create | /proc/meminfo, disk_usage, version checks |
| `tui/history.py` | Create | agents.log parser, tail 20, pipe-separated |
| `core/nexus.sh` | Modify | Add `dashboard|ui)` case with source+export+check+exec |

## Interfaces / Contracts

**Agent metadata** (Python dict from `modules/*/metadata.sh`):
```python
{
    "name": "aider",
    "tier": 1,
    "desc": "Asistente de codigo Git-nativo con IA",
    "binary": "aider",
    "method": "pip",
    "package": "aider-chat",
    "installed": shutil.which("aider") is not None
}
```

**Log format** (from `logs/agents.log`, pipe-delimited):
```
2026-06-03 22:08:15 | INSTALLED | aider | 0.60.0
2026-06-03 22:08:16 | REMOVED | aider
```

**Shell interface** (from `core/nexus.sh`):
```
nxai install --<agent>    # Install via module install.sh
nxai remove <agent>        # Remove via module metadata
```

**Theme**:
```python
theme = Theme(
    name="nexus-dark",
    primary="#00BCD4",
    secondary="#00BCD4",
    surface="#1a1a2e",
    background="#1a1a2e",
    # rest inherit defaults
)
```

## Testing Strategy

| Layer | What to Test | Approach |
|-------|-------------|----------|
| Unit | metadata parser, /proc/meminfo parser, history parser | Python functions with known inputs, assert dict/list output |
| Integration | Agent panel load, system monitor collect | Verify against actual filesystem |
| E2E | `nxai dashboard` launches, panels render, buttons work | Manual on Termux/proot — no headless Textual runner available |

No shell test runner available per `config.yaml`. pytest available for Python tests.

## Migration / Rollout

No migration required. New `tui/` directory added, case added to `nexus.sh`. `textual` must be manually installed via `pip install textual` — not added to `install.sh`.

## Open Questions

- [ ] Should `tui/` have a `__main__.py` to allow `python3 -m tui`?
- [ ] Refresh strategy: manual `R` key only, or auto-refresh on timer?
- [ ] Textual minimum version to pin in `requirements.txt`?
