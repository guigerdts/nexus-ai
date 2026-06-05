# Delta for agent-install

## MODIFIED Requirements

### Requirement: Environment-aware installation

The system MUST detect `NEXUS_TERMUX_ACCESSIBLE` before selecting package managers. When `true`, `install_via_pip` MUST use `TERMUX_PIP`, `install_via_apt` MUST map to `TERMUX_PKG`, `install_via_npm` MUST use `TERMUX_BIN/npm`. Agent installers MUST NOT defer to parent NEXUS_ENV when Termux accessible — termux-first strategy for deps.
(Previously: only mapped pkg on Termux, apt on proot — no cross-env)

#### Scenario: proot-Ubuntu + Termux bind-mounts (happy path)

- GIVEN `NEXUS_ENV=proot-ubuntu` and `NEXUS_TERMUX_ACCESSIBLE=true`
- WHEN `install_via_pip "aider-chat"` is called
- THEN `TERMUX_PIP install --user aider-chat` MUST execute
- AND `TERMUX_PKG install python-numpy` MUST run — no source compilation OOM

#### Scenario: proot-Ubuntu without Termux (fallback)

- GIVEN `NEXUS_ENV=proot-ubuntu` and `NEXUS_TERMUX_ACCESSIBLE=false`
- WHEN `install_via_apt "python3-numpy"` is called
- THEN `apt install -y` MUST execute (original behavior)
- AND numpy --no-build / --no-deps fallback must remain available

#### Scenario: Linux puro / Termux native (no change)

- GIVEN `NEXUS_ENV=linux` or `NEXUS_ENV=termux`
- WHEN any install function is called
- THEN existing behavior MUST be preserved

#### Scenario: Python version mismatch (risk)

- GIVEN Termux pip Python 3.13, proot python 3.12
- WHEN `TERMUX_PIP install --user aider-chat` succeeds
- THEN `python3 -c "import aider"` MUST resolve to Termux python3

## ADDED Requirements

### Requirement: Agent installer NEXUS_ENV fix

Agent install scripts (`modules/*/install.sh`) MUST check `NEXUS_TERMUX_ACCESSIBLE` before deferring to parent. When `true`, MUST use `TERMUX_PKG install python-numpy` for numpy pre-install.

#### Scenario: Aider numpy uses pkg

- GIVEN `NEXUS_TERMUX_ACCESSIBLE=true`
- WHEN aider install runs numpy pre-install
- THEN `TERMUX_PKG install python-numpy` MUST be called
- AND numpy compilation fallback MUST be skipped
