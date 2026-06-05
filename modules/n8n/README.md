# n8n

## Descripcion

Plataforma de automatizacion de workflows justa-codigo (fair-code) que permite
conectar servicios y automatizar tareas sin limites de vendor lock-in.

## Instalacion

```bash
nxai install n8n
```

O manualmente:

```bash
npm install -g n8n
```

## Uso

```bash
n8n start  # Inicia el servidor web en http://localhost:5678
n8n --help
```

## Notas para Termux

n8n funciona en Termux con Node.js:

```bash
pkg install nodejs
npm install -g n8n
n8n start
```

## Notas para proot-Ubuntu

```bash
apt install nodejs npm
npm install -g n8n
n8n start
```
