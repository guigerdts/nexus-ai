# GitHub CLI (gh)

## Descripcion

CLI oficial de GitHub para gestionar issues, pull requests, repositorios,
Gists, y mas, directamente desde la terminal.

## Instalacion

```bash
nxai install gh
```

O manualmente:

```bash
pkg install gh      # Termux
apt install gh      # proot-Ubuntu
```

## Uso

```bash
gh --help
gh repo create
gh pr list
gh issue view 42
```

## Notas para Termux

gh funciona correctamente en Termux:

```bash
pkg install gh
gh auth login
```

## Notas para proot-Ubuntu

```bash
apt install gh
gh auth login
```
