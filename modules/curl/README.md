# Curl — Cliente HTTP/HTTPS

## Descripcion

Curl es una herramienta de linea de comandos para transferir datos con
sintaxis URL. Soporta HTTP, HTTPS, FTP, SFTP, SCP y muchos otros protocolos.

## Instalacion

```bash
nxai install curl
```

O manualmente:

```bash
pkg install curl      # Termux
apt install curl      # proot-Ubuntu
```

## Uso

```bash
curl https://api.github.com/repos/opencode-ai/opencode
curl -O https://ejemplo.com/archivo.zip
curl -fsSL https://ejemplo.com/install.sh | sh
```

## Notas para Termux

```bash
pkg install curl
curl --help
```

## Notas para proot-Ubuntu

```bash
apt install curl
curl --help
```
