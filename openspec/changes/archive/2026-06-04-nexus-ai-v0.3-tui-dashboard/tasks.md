# Tasks: Nexus AI v0.3 — Dashboard TUI

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | ~350-400 |
| 400-line budget risk | Low |
| Chained PRs recommended | No |
| Suggested split | Single PR |
| Delivery strategy | ask-on-risk |
| Chain strategy | pending |

Decision needed before apply: Yes
Chained PRs recommended: No
Chain strategy: pending
400-line budget risk: Low

### Suggested Work Units

| Unit | Goal | Likely PR | Notes |
|------|------|-----------|-------|
| 1 | All phases (foundation → data layer → UI → CLI → verify) | PR 1 | base=main; ~350-400 lines total |

## Phase 1: Foundation

- [x] 1.1 Create `tui/__init__.py` — empty package marker
- [x] 1.2 Create `tui/requirements.txt` with `textual>=0.50.0`
- [x] 1.3 Create `tui/__main__.py` — `from .dashboard import main; main()`

## Phase 2: Data Layer

- [x] 2.1 Create `tui/system_monitor.py` — `collect()`: parse `/proc/meminfo`, `shutil.disk_usage()`, `subprocess` for `python --version` / `zsh --version` / `git --version`
- [x] 2.2 Create `tui/history.py` — `read_entries()`: read `logs/agents.log`, return last 20 entries (newest first), pipe-separated parsing
- [x] 2.3 Create `tui/agents_panel.py` — `load_agents()`: glob `modules/*/metadata.sh`, regex `AGENT_*` vars, `shutil.which(AGENT_BINARY)` for installed status

## Phase 3: UI Layer

- [x] 3.1 Create `tui/dashboard.py` — `textual.App` with `Theme` (cyan `#00BCD4`, bg `#1a1a2e`), `Header` showing version+env, `compose()` with 4 panels + `Footer`
- [x] 3.2 Wire QuickGuide — `Static` panel with static content: que-es, install/uninstall commands, 6-row command table
- [x] 3.3 Wire AgentPanel — `DataTable` (Nombre/Tier/Estado/Descripcion) with row-click install/remove
- [x] 3.4 Wire MonitorPanel — `Static` widget: RAM, disk, NEXUS_ENV, arch, python/zsh/git versions
- [x] 3.5 Wire HistoryPanel — `DataTable` showing date/action/agent/result from `logs/agents.log` (last 20)
- [x] 3.6 Wire Footer — keybindings: Q=Salir, R=Refrescar, 1-4=seccion; Spanish labels, ASCII-only, no emojis

## Phase 4: CLI Integration

- [x] 4.1 Add `dashboard|ui)` case to `core/nexus.sh` before `*)`: source `config/env.sh`, export `NEXUS_ROOT`, check `python3 -c "import textual"`, `exec python3 "$NEXUS_ROOT/tui/dashboard.py" "$@"`, support `--help` usage without launching TUI

## Phase 5: Verify

- [x] 5.1 Manual: `nxai dashboard` launches TUI with 4 panels visible (textual installed)
- [x] 5.2 Manual: `nxai dashboard --help` shows usage without TUI
- [x] 5.3 Manual: `nxai ui` alias works identically to `nxai dashboard`
- [x] 5.4 Manual: QuickGuide, Monitor, History panels render expected content (Spanish, ASCII-only)
- [x] 5.5 Manual: Install/Remove buttons execute `subprocess.run` against `{nexus_root}/bin/nxai`
- [x] 5.6 Manual: R key refreshes agent status, Q key quits
