# nerd-fonts — Fuentes Nerd Fonts para terminal

## Descripcion

Coleccion de fuentes con glyphs extra para terminal (icons, powerline, devicons).

**URL**: https://www.nerdfonts.com/

**Instalacion manual — no automatizada**

## Instrucciones

### En Termux nativo

```bash
# Descarga una fuente Nerd Font
# Por ejemplo, JetBrains Mono Nerd Font:
# 1. Visita: https://www.nerdfonts.com/font-downloads
# 2. Descarga la fuente de tu preferencia
# 3. Copia los archivos .ttf a ~/.termux/font.ttf
```

### En proot-Ubuntu

```bash
# Descarga la fuente y colocala en ~/.local/share/fonts/
mkdir -p ~/.local/share/fonts
# Descarga y extrae la fuente, luego:
fc-cache -fv
```

## Documentacion oficial

https://www.nerdfonts.com/
