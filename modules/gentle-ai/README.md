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

El instalador compila y ejecuta `termux-patches.go`, un programa Go que
parchea automaticamente 5 archivos del repositorio clonado para que
`runtime.GOOS == "android"` sea tratado como un sistema soportado.
Parches aplicados:

| Archivo | Que hace |
|---|---|
| `internal/system/detect.go` | Agrega android a `IsSupportedOS()`, `resolvePlatformProfile` y `osReleaseContent` |
| `internal/system/guard.go` | Actualiza mensaje de error para incluir Android |
| `internal/update/upgrade/download.go` | Redirige android → linux al auto-actualizarse |
| `internal/tui/model.go` | Usa `termux-open-url` para abrir enlaces |
| `internal/components/engram/download.go` | Redirige android → linux al descargar engram |

El patcher es idempotente: si el parche ya fue aplicado, lo omite.

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
