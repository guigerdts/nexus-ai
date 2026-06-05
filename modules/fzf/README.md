# Fzf — Buscador difuso interactivo

## Descripcion

Fzf es un buscador difuso para terminal que permite filtrar y seleccionar
archivos, historial de comandos, procesos y cualquier lista de texto de
forma interactiva.

## Instalacion

```bash
nxai install fzf
```

O manualmente:

```bash
pkg install fzf      # Termux
apt install fzf      # proot-Ubuntu
```

## Uso

```bash
# Buscar archivos recursivamente
find . -type f | fzf

# Historial de comandos
history | fzf

# Integracion con Ctrl+R / Ctrl+T
```

## Notas para Termux

```bash
pkg install fzf
fzf --help
```

## Notas para proot-Ubuntu

```bash
apt install fzf
fzf --help
```
