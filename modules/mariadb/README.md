# MariaDB

## Descripcion

Base de datos SQL relacional, fork de MySQL con mejoras de
rendimiento, almacenamiento y licencias open source. Completamente
compatible con MySQL.

## Instalacion

```bash
nxai install mariadb
```

O manualmente:

```bash
pkg install mariadb   # Termux
apt install mariadb-client # proot-Ubuntu (cliente)
```

## Uso

```bash
mariadb --version
mariadb -u usuario -p
```

## Notas para Termux

```bash
pkg install mariadb
```

MariaDB en Termux instala tanto el cliente como el servidor.

## Notas para proot-Ubuntu

Para solo el cliente:
```bash
apt install mariadb-client
```

Para servidor completo:
```bash
apt install mariadb-server
```
