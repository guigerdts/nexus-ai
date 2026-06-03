# Goose - Agente de codigo autonomo (Block)

## Descripcion

Goose es un agente de codigo autonomo creado por Block (Square).
Permite desarrollar, depurar y refactorizar codigo de forma automatica.

## Instalacion

```bash
nxai install goose
```

O manualmente:

```bash
curl -fsSL https://github.com/block/goose/install.sh | bash
```

## Uso

```bash
goose --help
```

## Requisitos

- curl
- Conexion a internet

## Notas para Termux

Goose puede requerir proot-Ubuntu para funcionar correctamente.
El instalador oficial puede no ser compatible con Termux nativo.

```bash
# En proot-Ubuntu:
curl -fsSL https://github.com/block/goose/install.sh | bash
```
