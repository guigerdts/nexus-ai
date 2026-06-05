# Wget

## Descripcion

Herramienta de descarga de archivos via HTTP, HTTPS y FTP desde la
terminal. Soporta descargas recursivas, reanudacion y espejado de
sitios web.

## Instalacion

```bash
nxai install wget
```

O manualmente:

```bash
pkg install wget      # Termux
apt install wget      # proot-Ubuntu
```

## Uso

```bash
wget https://ejemplo.com/archivo.zip
wget -c https://ejemplo.com/grande.iso  # reanudar descarga
wget --recursive https://ejemplo.com/
```

## Notas para Termux

```bash
pkg install wget
```

## Notas para proot-Ubuntu

```bash
apt install wget
```
