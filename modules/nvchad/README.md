# NvChad

## Descripcion

Configuracion moderna y rapida para Neovim basada en NvChad Starter, con
interfaz pulida y atajos intuitivos.

## Instalacion

```bash
nxai install nvchad
```

O manualmente:

```bash
git clone --depth 1 https://github.com/NvChad/starter ~/.config/nvim
```

## Uso

```bash
nvim
# NvChad se configura automaticamente al primer inicio
# Presiona <space> + th para ver el tema
# Presiona <space> + ff para buscar archivos
```

## Requisitos

- Neovim 0.9+ instalado
- Terminal con soporte true color
- Nerd Font para iconos (opcional)

## Notas para Termux

Neovim funciona en Termux. Primero instala Neovim y luego NvChad:

```bash
pkg install neovim git
git clone --depth 1 https://github.com/NvChad/starter ~/.config/nvim
nvim  # Los plugins se instalan automaticamente
```

## Notas para proot-Ubuntu

```bash
apt install neovim git
git clone --depth 1 https://github.com/NvChad/starter ~/.config/nvim
nvim  # Los plugins se instalan automaticamente
```
