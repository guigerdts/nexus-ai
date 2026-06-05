# shell-bootstrap Specification

## Purpose

Shell configs (`.bashrc`, `.zshrc`) that set up PATH for interactive NEXUS AI usage. Must include Termux bind-mount PATH entries when running inside proot-Ubuntu with Termux accessible.

## Requirements

### Requirement: Termux PATH in shell configs

Both `shell/.bashrc` and `shell/.zshrc` MUST prepend Termux bind-mount bin directories to PATH when `/data/data/com.termux/files/usr/bin` exists. Each entry SHALL be guarded by `[ -d "$dir" ]`.

| Scenario | Condition | Behavior |
|----------|-----------|----------|
| .bashrc with Termux | `/data/data/com.termux/files/usr/bin` exists | Prepend `TERMUX_BIN` and `TERMUX_PREFIX/local/bin` to PATH |
| .zshrc with Termux | Same dir exists | Same PATH entries as .bashrc |
| No Termux | Dir does not exist | No PATH changes, no errors |
