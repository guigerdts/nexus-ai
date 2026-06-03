# Aider - Asistente de codigo Git-nativo con IA

## Descripcion

Aider es un asistente de codigo que trabaja directamente con tu repositorio Git.
Permite programar con IA en la terminal, con soporte para multiples modelos.

## Instalacion

```bash
nxai install aider
```

O manualmente:

```bash
pip3 install --user aider-chat
```

## Uso

```bash
aider --model claude-3-5-sonnet
aider --model gpt-4o
```

## Requisitos

- Python 3.8+
- pip3
- Git

## Notas para Termux

Aider funciona en Termux nativo. Asegurate de tener Python 3 instalado:

```bash
pkg install python
pip3 install --user aider-chat
```

Puede requerir ~500MB de RAM para modelos grandes.
