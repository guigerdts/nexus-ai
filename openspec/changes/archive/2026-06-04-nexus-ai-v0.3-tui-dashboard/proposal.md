# Proposal: Dashboard TUI para NEXUS AI v0.3

## Intent

v0.3 agrega un Dashboard TUI interactivo con Textual. Reemplaza consultas CLI dispersas (`nxai status`, `nxai list`) por una vista unificada de 4 paneles: monitoreo del sistema y gestión visual de agentes (install/remove) desde una terminal.

## Scope

### In Scope
- `tui/` — 6 archivos Python: dashboard.py, agents_panel.py, system_monitor.py, history.py, `__init__.py`, requirements.txt
- `core/nexus.sh` — case `dashboard|ui)` con source + export + exec
- `openspec/specs/nexus-cli/spec.md` — agregar spec para dashboard/ui
- Dependencia opcional: `textual` (pip), chequeada en runtime

### Out of Scope
- `install.sh` sin cambios (pip install textual es manual)
- `config/env.sh` sin cambios
- Sin psutil, Rich standalone, logs/nexus.log
- Sin modo offline o fallback sin Textual

## Capabilities

### New Capabilities
- `dashboard-tui`: Textual App con 4 paneles, botones Install/Remove por agente, monitor de sistema (RAM/storage/entorno/versiones), historial de operaciones. Requiere `pip install textual` en runtime.

### Modified Capabilities
- `nexus-cli`: Agregar comandos `dashboard` y `ui` al case/esac. Exportar NEXUS_ROOT via `source config/env.sh` antes de `exec python3`. Verificar `import textual` antes de lanzar.

## Architecture

```
core/nexus.sh (dashboard|ui)
  → source config/env.sh, export NEXUS_ROOT
  → python3 -c "import textual" (check)
  → exec python3 $NEXUS_ROOT/tui/dashboard.py

tui/dashboard.py (textual.App)
  ├── Quick Guide (Rich Text estatico)
  ├── Agent Panel (DataTable + Button widgets)
  ├── System Monitor (Static con Rich Table)
  └── History (DataTable, 20 entradas)
```

**Comunicacion Bash↔Python**:
- `os.environ["NEXUS_ROOT"]` para ruta base (exportada antes de exec)
- `subprocess.run([f"{nexus_root}/bin/nxai", "install", f"--{agent}"])` con ruta absoluta
- `subprocess.run([f"{nexus_root}/bin/nxai", "remove", agent])`
- `shutil.which(AGENT_BINARY)` para estado instalado
- `/proc/meminfo` + `shutil.disk_usage()` para monitor (sin psutil)
- Parser directo de `logs/agents.log` (pipe-separated) para historial

**Quick Guide — contenido exacto**:
- **Que es NEXUS AI**: Framework Bash/Shell para gestionar agentes de IA en Termux + proot-Ubuntu ARM64
- **Instalar**: `curl -fsSL https://raw.githubusercontent.com/guigerdts/nexus-ai/main/install.sh | bash`
- **Desinstalar**: `rm -rf ~/.nexus && rm -f ~/.local/bin/nxai`
- **Comandos**: tabla con `install, remove, list, status, agent, help`

## Visual Design

- Primary `#00BCD4` (cyan), bg `#1a1a2e`, white text. Solo ASCII (Termux). Espanol.
- Header con version + entorno, Footer con atajos: `[Q] Salir [R] Refrescar [1-4] Paneles`

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `core/nexus.sh` | Modified | Case `dashboard|ui)` con source + export + exec |
| `tui/dashboard.py` | New | Textual App entry point, compose, event handlers |
| `tui/agents_panel.py` | New | DataTable (Nombre, Tier, Estado) + Button widgets |
| `tui/system_monitor.py` | New | RAM, storage, entorno, python/zsh/git --version |
| `tui/history.py` | New | Parser de logs/agents.log, ultimas 20 |
| `tui/__init__.py` | New | Package marker |
| `tui/requirements.txt` | New | `textual` |
| `openspec/specs/nexus-cli/spec.md` | Modified | Agregar spec para dashboard/ui |

## Dependencies

- `textual` (PyPI) — opcional, verificado en runtime. Rich como transitiva.
- No se modifica install.sh. Usuario corre `pip install textual` manualmente.

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| NEXUS_ROOT no accesible en Python | Medium | Export antes de exec en nexus.sh |
| logs/nexus.log no existe | High | Leer logs/agents.log (formato pipe) |
| psutil no disponible en Termux | High | /proc/meminfo + shutil.disk_usage() |
| Textual en ARM64 | Low | Python puro, sin C compilado |
| Python ≥3.13 en Termux | Low | Textual requiere ≥3.8 |
| TUI muestra estado desactualizado | Low | Siempre leer FS actual, sin cache |

## Rollback Plan

1. Eliminar case `dashboard|ui)` de `core/nexus.sh`
2. `rm -rf tui/`
3. Revertir cambios en `openspec/specs/nexus-cli/spec.md`
4. `git checkout -- core/nexus.sh`

## Success Criteria

- [ ] `nxai dashboard` y `nxai ui` lanzan el TUI (con textual instalado)
- [ ] Sin textual: "pip install textual" y exit 1
- [ ] Quick Guide con contenido exacto (que-es, install, uninstall, 6 comandos)
- [ ] Agent Panel lista 12 agentes con estado INSTALADO/NO INSTALADO
- [ ] Boton Install ejecuta `{nexus_root}/bin/nxai install --{agent}`
- [ ] Boton Remove ejecuta `{nexus_root}/bin/nxai remove {agent}`
- [ ] System Monitor: RAM, storage, NEXUS_ENV, python/zsh/git version
- [ ] History: ultimas 20 entradas de logs/agents.log
- [ ] Tema cyan #00BCD4, dark bg, ASCII only, espanol, sin emojis
