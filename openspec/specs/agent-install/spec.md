# agent-install Specification

## Purpose

Generic install library at `lib/nexus-install.sh` providing shared functions for agent lifecycle management. All agent `install.sh` scripts source this library instead of reimplementing dependency checks and install logic.

## Requirements

### Requirement: Shared install functions

The library MUST provide the following functions for any agent script to call:

| Function | Behavior |
|----------|----------|
| `install_via_pip(package)` | Installs with `pip3 install --user`; fallback to venv on PEP 668; last resort `--break-system-packages` with warning |
| `install_via_binary(tool, url, binary)` | Downloads tarball, extracts binary, creates GLIBC wrapper with safe LD_LIBRARY_PATH |

#### Scenario: Pip install works end-to-end (unchanged)

- GIVEN `python3` and `pip3` are available
- WHEN an agent's install.sh calls `install_via_pip "aider-chat"`
- THEN `pip3 install --user aider-chat` MUST be executed
- AND `mark_installed "aider"` MUST be called on success

#### Scenario: Pip install with PEP 668 creates venv

- GIVEN `pip3 install --user` fails due to PEP 668 (externally-managed-environment)
- WHEN `install_via_pip` is called
- THEN the system MUST create a venv at `$NEXUS_ROOT/venvs/<agent>/`
- AND install the package inside the venv
- AND NOT use `--break-system-packages` silently

#### Scenario: Pip install --break-system-packages warns

- GIVEN venv creation also fails (e.g. no python3-venv)
- WHEN `install_via_pip` falls back to `--break-system-packages`
- THEN the system MUST emit a warning about system package violation
- AND proceed only as last resort

#### Scenario: Missing dependency warns but does not crash

- GIVEN `node` is not installed
- WHEN `check_dependency "nodejs" "node --version"` is called
- THEN the system MUST print "Dependencia faltante: nodejs"
- AND return non-zero without aborting the parent script

#### Scenario: Curl install accepts URL

- GIVEN a valid URL to an install script
- WHEN `install_via_curl "https://example.com/install.sh"` is called
- THEN the script MUST download and pipe it to bash

### Requirement: Install manifest tracking

The system MUST maintain an install manifest at `$NEXUS_ROOT/logs/installed.txt` — a plain-text file with one agent name per line. The function `update_installed_manifest(agent, action)` MUST add (action="install") or remove (action="remove") the agent name from `installed.txt`.

#### Scenario: Install adds agent to manifest

- GIVEN an agent install succeeds
- WHEN `mark_installed` triggers `update_installed_manifest` with action "install"
- THEN the agent name MUST appear in `logs/installed.txt`

#### Scenario: Remove deletes agent from manifest

- GIVEN an agent name exists in `logs/installed.txt`
- WHEN `mark_removed` triggers `update_installed_manifest` with action "remove"
- THEN the agent name MUST NOT appear in `logs/installed.txt`

#### Scenario: Remove non-installed agent is no-op

- GIVEN an agent name is NOT in `logs/installed.txt`
- WHEN `update_installed_manifest` is called with action "remove"
- THEN `logs/installed.txt` MUST remain unchanged

### Requirement: Agent install state

The system MUST record install state in `$NEXUS_ROOT/logs/agents.log` with timestamp, agent name, action (install/remove), and exit status.

#### Scenario: Install creates log entry

- GIVEN an agent is successfully installed
- WHEN `mark_installed` is called
- THEN `agents.log` MUST contain a line with timestamp, agent name, "INSTALADO", and "OK"

#### Scenario: Re-install is idempotent

- GIVEN an agent is already marked as installed
- WHEN `mark_installed` is called again for the same agent
- THEN `agents.log` MUST NOT duplicate the entry
- AND the existing entry MUST be updated with the new timestamp

### Requirement: Environment-aware installation

The system MUST detect the runtime environment and `NEXUS_TERMUX_ACCESSIBLE` before selecting package managers. Priority: (1) when `NEXUS_TERMUX_ACCESSIBLE=true`, `install_via_pip` MUST use `TERMUX_PIP`, `install_via_apt` MUST map to `TERMUX_PKG`; (2) when `NEXUS_ENV=termux`, existing Termux-native behavior (`pkg` for apt) MUST be preserved; (3) on all other environments, standard system package managers (`apt`, `pip3`) MUST be used. Agent installers MUST NOT defer to parent NEXUS_ENV when Termux accessible.

#### Scenario: proot-Ubuntu + Termux bind-mounts (happy path)

- GIVEN `NEXUS_ENV=proot-ubuntu` and `NEXUS_TERMUX_ACCESSIBLE=true`
- WHEN `install_via_pip "aider-chat"` is called
- THEN `TERMUX_PIP install --user aider-chat` MUST execute
- AND `TERMUX_PKG install python-numpy` MUST run — no source compilation OOM

#### Scenario: Termux uses pkg

- GIVEN `NEXUS_ENV` is `"termux"`
- WHEN `install_via_apt` is called
- THEN the function MUST silently map to `pkg install`
- AND NOT call `apt` directly

#### Scenario: proot-Ubuntu without Termux (fallback)

- GIVEN `NEXUS_ENV=proot-ubuntu` and `NEXUS_TERMUX_ACCESSIBLE=false`
- WHEN `install_via_apt "python3-numpy"` is called
- THEN `apt install -y` MUST execute (original behavior)
- AND numpy --no-build / --no-deps fallback must remain available

#### Scenario: Python version mismatch (risk)

- GIVEN Termux pip Python 3.13, proot python 3.12
- WHEN `TERMUX_PIP install --user aider-chat` succeeds
- THEN `python3 -c "import aider"` MUST resolve to Termux python3

#### Scenario: Binary wrapper LD_LIBRARY_PATH safe

- GIVEN `NEXUS_ENV=termux` and GLIBC libraries exist
- WHEN `install_via_binary` creates the GLIBC wrapper
- THEN the wrapper MUST use `export LD_LIBRARY_PATH=__GLIBC_LIB__${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}`
- AND NOT append a trailing colon when `LD_LIBRARY_PATH` is unset
- AND NOT interpret CWD as library path (CWE-429 mitigation)

### Requirement: Agent installer NEXUS_ENV fix

Agent install scripts (`modules/*/install.sh`) MUST check `NEXUS_TERMUX_ACCESSIBLE` before deferring to parent. When `true`, MUST use `TERMUX_PKG install python-numpy` for numpy pre-install.

#### Scenario: Aider numpy uses pkg

- GIVEN `NEXUS_TERMUX_ACCESSIBLE=true`
- WHEN aider install runs numpy pre-install
- THEN `TERMUX_PKG install python-numpy` MUST be called
- AND numpy compilation fallback MUST be skipped
