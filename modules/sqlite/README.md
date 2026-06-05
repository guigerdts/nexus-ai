# SQLite

## Descripcion

Base de datos SQL embebida, sin servidor, zero configuracion.
Almacena toda la base de datos en un unico archivo. Ideal para
desarrollo, prototipos y aplicaciones locales.

## Instalacion

```bash
nxai install sqlite
```

O manualmente:

```bash
pkg install sqlite    # Termux
apt install sqlite3  # proot-Ubuntu
```

## Uso

```bash
sqlite3 base.db
sqlite3 base.db "SELECT * FROM usuarios;"
sqlite3 base.db < script.sql
```

## Notas para Termux

```bash
pkg install sqlite
sqlite3 --version
```

## Notas para proot-Ubuntu

```bash
apt install sqlite3
```
