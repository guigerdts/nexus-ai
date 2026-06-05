# PostgreSQL

## Descripcion

Sistema de base de datos SQL relacional de codigo abierto. Este
modulo instala el cliente `psql` para conectarse a bases de datos
PostgreSQL desde la terminal.

## Instalacion

```bash
nxai install postgresql
```

O manualmente:

```bash
pkg install postgresql # Termux
apt install postgresql-client # proot-Ubuntu
```

## Uso

```bash
psql --version
psql -h localhost -U usuario -d basedatos
```

## Notas para Termux

```bash
pkg install postgresql
psql --version
```

## Notas para proot-Ubuntu

Para solo el cliente:
```bash
apt install postgresql-client
psql --version
```

Para servidor completo:
```bash
apt install postgresql
```
