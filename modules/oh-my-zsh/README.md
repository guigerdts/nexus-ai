# Oh My Zsh

## Descripcion

Framework open-source para gestionar la configuracion de Zsh con cientos de
plugins y temas.

## Instalacion

```bash
nxai install oh-my-zsh
```

O manualmente:

```bash
RUNZSH=no git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
```

## Uso

```bash
# Configurar Zsh como shell predeterminada
chsh -s $(which zsh)

# Editar ~/.zshrc para activar plugins
# plugins=(git docker node npm)
```

## Notas para Termux

Zsh y oh-my-zsh funcionan correctamente en Termux:

```bash
pkg install zsh git
RUNZSH=no git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
chsh -s zsh
```

## Notas para proot-Ubuntu

```bash
apt install zsh git
RUNZSH=no git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
chsh -s $(which zsh)
```
