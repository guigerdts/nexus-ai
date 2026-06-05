# Gum — Toolkit de UI para shell scripts

## Descripcion

Gum es un toolkit de interfaz de usuario para shell scripts desarrollado
por Charmbracelet. Permite crear prompts, selectores, spinners, y otros
elementos interactivos desde scripts bash.

## Instalacion

```bash
nxai install gum
```

O manualmente:

```bash
pkg install gum      # Termux
apt install gum      # proot-Ubuntu
```

## Uso

```bash
gum choose "opcion 1" "opcion 2" "opcion 3"
gum input --placeholder "Escribe tu nombre"
gum spin --spinner dot --title "Cargando..." -- sleep 2
```

## Notas para Termux

```bash
pkg install gum
gum --help
```

## Notas para proot-Ubuntu

```bash
apt install gum
gum --help
```
