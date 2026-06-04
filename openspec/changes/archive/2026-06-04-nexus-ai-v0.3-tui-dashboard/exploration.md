# Exploration: Dashboard TUI para NEXUS AI v0.3

## Current State

El proyecto NEXUS AI v0.2 tiene una CLI funcional basada en Bash (`core/nexus.sh`) con 12 agentes registrados. Los comandos se enrutan via `case/esac` y el symlink `bin/nxai -> ../core/nexus.sh`.

### Infraestructura existente clave para el TUI:

- **`core/nexus.sh`** — CLI principal. Case/esac para: `install`, `remove`, `list`, `status`, `agent`, `memory`, `update`, `help`. Cada comando es una función. El entry point es `bin/nxai` que resuelve a `core/nexus.sh`. Las funciones relevantes para el TUI:
  - `system_status()` — ya muestra versión, entorno, arquitectura, agentes instalados (útil como referencia para Section 3)
  - `list_agents()` — itera `AGENT_ORDER` y verifica instalación via `command -v AGENT_BINARY` o `test.sh` (útil como referencia para Section 2)

- **`config/agents.registry.sh`** — Construye `AGENTS[]` (asociativo: nombre→directorio) y `AGENT_ORDER[]` (indexado). Exporta por cada agente: `AGENT_NAME`, `AGENT_VERSION`, `AGENT_DESC`, `AGENT_URL`, `AGENT_TIER` (1-3), `AGENT_METHOD` (pip/npm/curl/cargo/apt/stub/manual), `AGENT_BINARY`, `AGENT_PACKAGE`.

- **`config/env.sh`** — Exporta `NEXUS_VERSION=0.2.0`, `NEXUS_ENV` (termux|proot-ubuntu|linux), `NEXUS_ARCH` (arm64|x86_64), `NEXUS_LANG`, `NEXUS_ROOT`, `NEXUS_MODULES_DIR`, `NEXUS_LOG_FILE`.

- **`lib/nexus-install.sh`** — `mark_installed(agent, version)` y `mark_removed(agent)` escriben a `logs/agents.log`. Formato: `YYYY-MM-DD HH:MM:SS | ACTION | agent | [version]`. También `install_via_pip`, `uninstall_via_pip`, etc.

- **`lib/nexus-log.sh`** — Solo stdout con colores. `NEXUS_LOG_FILE` está definido pero **nunca se escribe**. El log persistente real está en `logs/agents.log`.

- **12 agentes** con `metadata.sh` estandarizado. Cada uno exporta: `AGENT_NAME`, `AGENT_VERSION`, `AGENT_DESC`, `AGENT_URL`, `AGENT_TIER` (1-3), `AGENT_METHOD`, `AGENT_BINARY`. Algunos incluyen `AGENT_PACKAGE`.

- **Runtimes**: Rich y Textual **NO están instalados** en el sistema actual. Python 3 existe y está disponible.

- **`logs/agents.log`** — 6 entries existentes en formato pipe-separated. `logs/nexus.log` mencionado en `NEXUS_LOG_FILE` **no existe**.

### Especificaciones existentes relevantes:
- `openspec/specs/nexus-cli/spec.md` — Define case/esac routing, ASCII-only output, Spanish locale. Toda la salida al usuario debe ser en español.

## Affected Areas

| Archivo | Por qué |
|---------|---------|
| `core/nexus.sh` | Se agrega case `dashboard|ui)` con verificación de dependencias Python y `exec` al TUI |
| `tui/dashboard.py` | **NUEVO** — Punto de entrada principal del dashboard (Rich o Textual según enfoque) |
| `tui/agents_panel.py` | **NUEVO** — Panel interactivo de agentes (instalar/remover) |
| `tui/system_monitor.py` | **NUEVO** — Recolecta RAM, storage, entorno, versión de Python/Zsh/Git |
| `tui/history.py` | **NUEVO** — Parsea `logs/agents.log` y muestra últimas 20 entradas |
| `tui/__init__.py` | **NUEVO** — Package marker |
| `tui/requirements.txt` | **NUEVO** — `rich`, `textual` |
| `openspec/specs/nexus-cli/spec.md` | **ACTUALIZAR** — Agregar especificación para `dashboard`/`ui` command |
| `install.sh` | **POSIBLE** — Agregar paso opcional para `pip install rich textual` |
| `config/env.sh` | **NO** — No necesita cambios (NEXUS_ROOT, etc. ya están) |
| `logs/agents.log` | **NO** — Historia se lee pero no escribe |

### Dependencias del sistema (detectables desde el TUI):
- `free -m` o `/proc/meminfo` para RAM
- `df -h` para storage
- `python3 --version`, `zsh --version`, `git --version`

## Approaches

### 1. Textual Puro (recomendado)

Usar Textual como framework único. Rich viene como dependencia transitiva (`pip install textual` → instala rich automáticamente). Dashboard.py es una `textual.App` con todos los paneles como widgets.

- **Dashboard**: `textual.widgets.Header`, `Footer`, `Static` con Rich renderables para logo/bienvenida
- **Agent Panel**: `DataTable` con columnas (Nombre, Tier, Estado, Acción) + `Button` widgets para Install/Remove
- **System Monitor**: `Static` con Rich `Table` o `Panel`
- **History**: `DataTable` o `ListView` con últimas 20 entradas

```
Textual App (dashboard.py)
├── Welcome Section (Rich Text + Panel)
├── Agent Panel (DataTable + Buttons)
├── System Monitor (Rich Table)
└── History (DataTable)
```

| Pros | Cons | Esfuerzo |
|------|------|----------|
| Framework único, sin fricción entre Rich y Textual | Textual es más pesado que Rich solo | Medio |
| Textual ya usa Rich internamente para renderizado | Curva de aprendizaje de Textual (aunque es Python puro) | |
| Interactividad nativa (botones, keybindings) | | |
| Single `pip install textual` es más simple para el usuario | | |
| Transitive dependency: textual ya trae rich | | |

### 2. Rich + Textual Combinados (como propone el user)

Dashboard.py arranca con Rich (Layout con Sections 1, 3, 4 estáticos), y al presionar una tecla (ej. `A`) lanza un subproceso Textual o cambia de screen.

| Pros | Cons | Esfuerzo |
|------|------|----------|
| Rich solo es ultra rápido para la vista estática | Complejidad: dos frameworks, dos entry points, estado compartido | Alto |
| Secciones 1/3/4 se renderizan en milisegundos | ¿Cómo se vuelve de Textual a Rich? ¿Subproceso? ¿Screen switch nativo? | |
| Textual solo cuando se necesita interacción | El usuario necesita ambas dependencias instaladas | |
| | Mayor superficie de bugs (coordinación entre procesos) | |

### 3. Rich-only con diálogos de selección

Usar Rich para todo. La interacción del panel de agentes se resuelve con `rich.prompt.Prompt` o una lista seleccionable usando `rich.table.Table` + input numérico.

| Pros | Cons | Esfuerzo |
|------|------|----------|
| Dependencia única (`rich` sola) | UX pobre: nada de botones, solo input de texto | Bajo |
| Ultra rápido, instantáneo | Instalar/remover requiere escribir el nombre del agente | |
| Sin complejidad de Textual | No hay feedback visual de "instalando..." | |

## Recommendation

**Enfoque 1: Textual Puro** — por las siguientes razones:

1. **Textual ya incluye Rich** como dependencia transitiva. `pip install textual` instala automáticamente `rich`. No hay razón para instalar ambos por separado y lidiar con el switching.

2. **Interactividad real**. El usuario quiere botones Install/Remove con feedback visual. Textual tiene `Button`, `DataTable`, `LoadingIndicator` — Rich solo no puede hacer esto sin _prompts_ inline.

3. **Single Python script**: `dashboard.py` es una `textual.App`. No hay que coordinar dos procesos, no hay estado compartido frágil.

4. **Secciones 1, 3, 4 funcionan igual de bien en Textual**. Usar `Static(rich_text)` dentro de Textual permite usar toda la sintaxis de Rich (colores, paneles, tablas) sin salir del framework.

5. **Dependencia única**: El check en `core/nexus.sh` solo verifica `import textual`. Si no está, muestra `pip install textual` y sale.

### Arquitectura propuesta

```
core/nexus.sh dashboard|ui)
  → check: python3 -c "import textual" 2>/dev/null
  → si falla: echo "pip install textual" && exit 1
  → exec python3 "$NEXUS_ROOT/tui/dashboard.py"

tui/dashboard.py
  → textual.App
  ├── compose(): yield widgets.Header, WelcomePanel, AgentPanel, MonitorPanel, HistoryPanel, Footer
  ├── on_button_pressed(event): llama a nxai install/remove vía subprocess.run
  └── on_mount(): carga datos del sistema y agents.log

tui/agents_panel.py
  → Widget personalizado con DataTable + botones
  → Lee AGENT_ORDER desde el registro (via subprocess ejecutando bash)

tui/system_monitor.py
  → Funciones Python que recolectan:
    - RAM: psutil o /proc/meminfo
    - Storage: shutil.disk_usage() o df
    - Entorno: NEXUS_ENV desde os.environ
    - Versiones: subprocess.run(["python3","--version"]), etc.

tui/history.py
  → Lee logs/agents.log, parsea pipe-separated, devuelve últimas 20
  → Formato: Date | Action | Agent | Version
```

### Integración con Bash

El TUI no puede `source` Bash directamente. Necesita comunicarse con el framework via `subprocess`:

- **Listar agentes + estado**: `source config/env.sh && source config/agents.registry.sh && registry_list`
  - O más simple: el TUI lee `modules/*/metadata.sh` directamente desde Python y verifica `AGENT_BINARY` con `shutil.which()`
- **Instalar agente**: `subprocess.run(["nxai", "install", agent_name])`
- **Remover agente**: `subprocess.run(["nxai", "remove", agent_name])`
- **Leer versión**: `os.environ.get("NEXUS_VERSION")` no funciona porque el TUI es un proceso hijo. Mejor leer `config/env.sh` vía subprocess, o hardcodear la ruta y parsear el archivo.

**Recomendación para comunicación Bash↔Python**: Parsear `config/env.sh` y `modules/*/metadata.sh` directamente desde Python (son Bash, pero las asignaciones `export VAR="value"` son triviales de parsear con regex). Esto evita depender de que `bash` esté configurado correctamente en el subprocess.

## Risks

1. **Comunicación Bash↔Python**: El TUI no hereda las variables de entorno de Bash porque `exec python3` es un proceso nuevo. `NEXUS_ROOT`, `NEXUS_VERSION`, etc. no están disponibles en `os.environ`. 
   - **Mitigación**: El TUI debe auto-detectar `NEXUS_ROOT` (ej: `__file__` está en `$NEXUS_ROOT/tui/dashboard.py` → subir dos directorios), o parsear `config/env.sh` directamente.

2. **`logs/nexus.log` no existe**: `NEXUS_LOG_FILE` apunta a `logs/nexus.log` pero ningún módulo escribe allí. La historia real está en `logs/agents.log` con formato pipe-separated.
   - **Mitigación**: Section 4 debe leer `logs/agents.log`, no `logs/nexus.log`. O crear un log unificado.

3. **Termux sin psutil**: `psutil` no está instalado por defecto en Termux. `pip install textual` no trae psutil.
   - **Mitigación**: Usar `/proc/meminfo` y `shutil.disk_usage()` que son estándar de Python/libc.

4. **Rich/Textual en ARM64**: Ambas corren en Python puro, pero instalar en Termux ARM64 puede tener problemas si hay dependencias C compiladas (Textual no tiene, es Python puro). Verificar.

5. **Compatibilidad Termux (Python 3.13)**: Textual requiere Python ≥3.8. Python 3.13 en Termux funciona. Verificar que no haya dependencias faltantes.

6. **Idempotencia del TUI**: Si el usuario abre/cierra el TUI mientras un agente se está instalando en background, puede haber inconsistencias.
   - **Mitigación**: El TUI siempre lee estado actual del filesystem (no cachea).

## Ready for Proposal

**Sí**. La exploración está completa. El orchestrator puede proceder a `sdd-propose` con el enfoque **Textual Puro** (Enfoque 1). 

Resumen para el usuario:
- La propuesta debe usar **Textual como framework único** (no Rich+Textual combinados)
- Textual ya incluye Rich como dependencia transitiva
- La comunicación Bash↔Python se hace parseando `config/env.sh` y `modules/*/metadata.sh` directamente desde Python
- Section 4 debe leer `logs/agents.log` en lugar de `logs/nexus.log` (que no existe)
- 6 riesgos identificados, todos mitigables
