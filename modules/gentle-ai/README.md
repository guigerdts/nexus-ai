# Gentle-AI - CLI de codigo abierto para desarrollo asistido por IA

## Descripcion

Gentle-AI es una CLI de codigo abierto para desarrollo asistido por IA.
Compilada desde fuente via Go.

## Instalacion

```bash
nxai install gentle-ai
```

Esto clona el repositorio, compila con Go y copia el binario al PATH.

## Uso

```bash
gentle-ai --help
```

## Requisitos

- Go >= 1.23
- Git
- Conexion a internet

## Termux / Android

El instalador aplica un parche automatico para compatibilidad con Termux
(Android). Modifica los archivos `guard.go` y `detect.go` del repo clonado
para que `runtime.GOOS == "android"` sea tratado como un sistema soportado
(perfil Linux con `apt` como gestor de paquetes).

## Actualizacion

```bash
nxai update gentle-ai
```

## Desinstalacion

```bash
nxai uninstall gentle-ai
```

## Repositorio

https://github.com/Gentleman-Programming/gentle-ai
