# Delta for agent-install

## MODIFIED Requirements

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

### Requirement: Environment-aware installation

#### Scenario: Binary wrapper LD_LIBRARY_PATH safe (replaces old)

- GIVEN `NEXUS_ENV=termux` and GLIBC libraries exist
- WHEN `install_via_binary` creates the GLIBC wrapper
- THEN the wrapper MUST use `export LD_LIBRARY_PATH=__GLIBC_LIB__${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}`
- AND NOT append a trailing colon when `LD_LIBRARY_PATH` is unset
- AND NOT interpret CWD as library path (CWE-429 mitigation)
