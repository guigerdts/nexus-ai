# Delta for agent-install

## ADDED Requirements

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

## MODIFIED Requirements

### Requirement: Shared install functions

The library MUST provide the following functions for any agent script to call:

| Function | Behavior |
|----------|----------|
| `check_dependency(name, cmd)` | Verifies `cmd` exists, prints warning if missing |
| `install_via_pip(package)` | Installs with `pip3 install --user` |
| `install_via_npm(package)` | Installs with `npm install -g` |
| `install_via_curl(url)` | Pipes `curl <url> \| bash` |
| `install_via_apt(package)` | Installs with `apt install -y` |
| `install_via_cargo(package)` | Installs with `cargo install` |
| `mark_installed(agent)` | Logs agent as installed in `agents.log` AND adds to `installed.txt` manifest |
| `mark_removed(agent)` | Logs agent as removed in `agents.log` AND removes from `installed.txt` manifest |
| `update_installed_manifest(agent, action)` | Adds/removes agent name from `installed.txt` manifest |

(Previously: no `update_installed_manifest()` function; `mark_installed`/`mark_removed` only wrote to `agents.log`)

#### Scenario: Pip install works end-to-end

- GIVEN `python3` and `pip3` are available
- WHEN an agent's install.sh calls `install_via_pip "aider-chat"`
- THEN `pip3 install --user aider-chat` MUST be executed
- AND `mark_installed "aider"` MUST be called on success

#### Scenario: Missing dependency warns but does not crash

- GIVEN `node` is not installed
- WHEN `check_dependency "nodejs" "node --version"` is called
- THEN the system MUST print "Dependencia faltante: nodejs"
- AND return non-zero without aborting the parent script

#### Scenario: Curl install accepts URL

- GIVEN a valid URL to an install script
- WHEN `install_via_curl "https://example.com/install.sh"` is called
- THEN the script MUST download and pipe it to bash
