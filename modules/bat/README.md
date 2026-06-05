# Bat

## Descripcion

Bat es un clon de cat con soporte de sintaxis coloreada para muchos
lenguajes de programacion. Incluye integracion con git y numeracion
de lineas.

## Instalacion

```bash
nxai install bat
```

O manualmente:

```bash
pkg install bat      # Termux
apt install bat      # proot-Ubuntu
```

## Uso

```bash
bat archivo.txt
bat --style=numbers,changes archivo.rs
```

## Notas para Termux

```bash
pkg install bat
bat --help
```

## Notas para proot-Ubuntu

```bash
apt install bat
bat --help
```
