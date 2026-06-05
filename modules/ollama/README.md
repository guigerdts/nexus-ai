# Ollama

## Descripcion

Ejecuta modelos de lenguaje locales como LLaMA, Mistral, Qwen, y muchos mas
directamente desde la terminal, sin necesidad de conexion a la nube.

## Instalacion

```bash
nxai install ollama
```

O manualmente:

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

## Uso

```bash
ollama pull llama3.2
ollama run llama3.2
```

## Notas para Termux

Ollama no funciona directamente en Termux. Usa proot-Ubuntu:

```bash
apt install curl
curl -fsSL https://ollama.com/install.sh | sh
```

## Notas para proot-Ubuntu

```bash
apt install curl
curl -fsSL https://ollama.com/install.sh | sh
```
