# SGPT - Asistente de terminal GPT desde CLI

## Descripcion

Shell-GPT (sgpt) es un asistente de terminal que usa modelos GPT
directamente desde la linea de comandos. Permite generar comandos,
explicar codigo, y mucho mas.

## Instalacion

```bash
nxai install sgpt
```

O manualmente:

```bash
pip3 install --user shell-gpt
```

## Uso

```bash
sgpt "como listar archivos modificados en los ultimos 7 dias"
sgpt --code "funcion fibonacci en Python"
```

## Requisitos

- Python 3.8+
- pip3

## Notas para Termux

SGPT funciona en Termux nativo. Asegurate de tener Python 3 instalado:

```bash
pkg install python
pip3 install --user shell-gpt
```
