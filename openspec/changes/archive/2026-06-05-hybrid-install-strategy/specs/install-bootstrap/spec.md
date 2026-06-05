# Delta for install-bootstrap

## MODIFIED Requirements

### Requirement: Environment detection before action

The installer MUST detect the environment and select the appropriate package manager. The hardcoded PATH block (lines 505-540) MUST prepend Termux bind-mount directories when `/data/data/com.termux/files/usr/bin` exists at install time.
(Previously: no Termux bind-mount PATH awareness)

| Scenario | Condition | PATH behavior |
|----------|-----------|---------------|
| Install in proot + bind-mounts | `/data/data/com.termux/files/usr/bin` exists | `/usr/bin` and `/usr/local/bin` prepended to hardcoded PATH |
| Install in proot no bind-mounts | Dir missing | No Termux entries |
| Install on Linux puro | `NEXUS_ENV=linux` | No Termux entries, apt used |
