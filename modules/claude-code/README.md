# Claude Code - CLI de Anthropic

## Descripcion

Claude Code CLI de Anthropic. Permite programar con Claude directamente
desde la terminal. Requiere Node.js y consume recursos significativos.

## Instalacion

```bash
nxai install claude-code
```

O manualmente:

```bash
npm install -g @anthropic-ai/claude-code
```

## Uso

```bash
claude-code
# o
claude
```

## Requisitos

- Node.js 18+
- npm
- ~2GB de espacio disponible
- Cuenta de Anthropic

## Notas para Termux

**⚠️  INSTALACION PESADA**

Claude Code puede consumir ~2GB de espacio en Termux.
Se recomienda instalar en proot-Ubuntu en lugar de Termux nativo:

```bash
# En proot-Ubuntu:
apt install nodejs npm
npm install -g @anthropic-ai/claude-code
```

En Termux nativo, asegurate de tener suficiente espacio:

```bash
pkg install nodejs
npm install -g @anthropic-ai/claude-code
```

Puede requerir ~4GB de RAM para sesiones largas.
