# NEXUS AI

Framework de entorno para Termux/proot-Ubuntu.
Convierte Android en una workstation profesional para agentes de IA.

**Estado:** v0.2.0 — estable. Dual-environment (Termux nativo + proot-Ubuntu).

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

---

## Estructura del proyecto

```
nexus-ai/
├── config/
│   ├── env.sh              # Variables de entorno y detección del sistema
│   └── agents.registry.sh  # Registro de agentes (auto-generado)
├── shell/
│   ├── .zshrc              # Configuración de Zsh (template con plugins)
│   ├── .bashrc             # Configuración de Bash (env + PATH + MOTD)
│   ├── starship.toml       # Paleta cyan para Starship prompt
│   └── motd.sh             # Mensaje de bienvenida (ASCII art + tips)
├── core/
│   └── nexus.sh            # CLI principal (nxai — case/esac router)
├── bin/
│   └── nxai -> ../core/nexus.sh  # Symlink de entrada
├── lib/
│   ├── nexus-install.sh    # Funciones de instalación (pip, apt, npm, pkg)
│   └── nexus-log.sh        # Logging con colores [OK]/[WARN]/[ERROR]
├── modules/                # 12 agentes registrados
│   ├── aider/              # Tier 1 — asistente de código
│   ├── opencode/           # Tier 1 — CLI multi-modelo
│   ├── codex/              # Tier 1 — OpenAI Codex CLI
│   ├── antigravity/        # Tier 2 — CLI experimental
│   ├── pi/                 # Tier 2 — asistente de terminal
│   ├── fabric/             # Tier 2 — framework de automatización
│   ├── sgpt/               # Tier 2 — shell-gpt
│   ├── goose/              # Tier 2 — agente autónomo
│   ├── engram/             # Tier 2 — memoria persistente
│   ├── gentle-ai/          # Tier 3 — CLI de desarrollo asistido
│   ├── openclou/           # Tier 3 — CLI de programación
│   └── claude-code/        # Tier 3 — Claude Code CLI
├── logs/                   # Archivos de registro
│   └── agents.log
└── install.sh              # Instalador principal (8 pasos)
```

## Requisitos previos

- **Termux** (nativo) desde F-Droid, o **proot-distro Ubuntu**
- `bash`, `zsh`, `curl`, `git` (se instalan automáticamente con `install.sh`)

## Instalación

### Rápida (curl | bash)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/guigerdts/nexus-ai/main/install.sh)
```

### Manual (git clone)

```bash
git clone https://github.com/guigerdts/nexus-ai.git ~/nexus-ai
cd ~/nexus-ai
./install.sh
```

### Flags disponibles

| Flag | Descripción |
|------|-------------|
| `--help` | Muestra la ayuda y sale |
| `--no-zsh` | Omite la configuración de Zsh y plugins |
| `--no-bashrc` | Omite la configuración de Bash (.bashrc) |
| `--no-starship` | Omite Starship (usa `vcs_info` como fallback) |
| `--no-motd` | Omite el mensaje de bienvenida (MOTD) |
| `--dir PATH` | Establece un directorio de instalación personalizado |

### Ejemplos

```bash
# Instalación completa
./install.sh

# Solo dependencias y MOTD (sin Zsh)
./install.sh --no-zsh

# Mínima instalación
./install.sh --no-starship --no-motd

# Instalar en directorio específico
./install.sh --dir ~/nexus
```

### Plugins Zsh instalados

| Plugin | Función |
|--------|---------|
| zsh-autosuggestions | Sugerencias basadas en historial |
| zsh-syntax-highlighting | Resaltado de sintaxis en comandos |
| fzf + fzf-tab | Búsqueda difusa y completado interactivo |
| zoxide | Navegación inteligente de directorios |
| atuin | Historial de comandos con sincronización |
| thefuck | Corrección automática de comandos |
| zsh-vi-mode | Modo vi para Zsh |

## Agentes disponibles (12)

Los agentes se organizan en 3 tiers según su madurez y soporte:

| Agente | Tier | Método | Descripción |
|--------|------|--------|-------------|
| **aider** | 1 | pip | Asistente de código Git-nativo con IA |
| **opencode** | 1 | npm | CLI multi-modelo de código abierto (150K+ stars) |
| **codex** | 1 | npm | OpenAI Codex CLI (GPT-5.5) |
| **antigravity** | 2 | manual | CLI experimental de IA |
| **pi** | 2 | pip | Asistente de IA desde terminal (Pi.ai) |
| **fabric** | 2 | pip | Framework open-source para automatización con IA |
| **sgpt** | 2 | pip | Asistente de terminal GPT (shell-gpt) |
| **goose** | 2 | curl | Agente de código autónomo (Block) |
| **engram** | 2 | manual | Memoria persistente para sesiones de IA |
| **gentle-ai** | 3 | stub | CLI de desarrollo asistido por IA |
| **openclou** | 3 | stub | CLI de programación con IA |
| **claude-code** | 3 | stub | Claude Code CLI de Anthropic |

Uso: `nxai install --all` para instalar todos, o `nxai install <agente>` para uno solo.

## Uso

```bash
nxai help                # Muestra ayuda completa
nxai status              # Estado del sistema (versión, entorno, agentes)
nxai list                # Lista agentes con estado de instalación
nxai install --all       # Instala todos los agentes
nxai install <agente>    # Instala un agente específico
nxai remove <agente>     # Desinstala un agente
nxai agent add <nombre> <url>  # Agrega un agente personalizado
nxai agent test <nombre> # Prueba si un agente funciona
```

## Desinstalación

1. Abre `~/.zshrc` y `~/.bashrc`, y elimina el bloque NEXUS AI en ambos:
   ```
   # >>> NEXUS AI BEGIN >>>
   ...
   # <<< NEXUS AI END <<<
   ```
2. Elimina el directorio de instalación:
   ```bash
   rm -rf ~/nexus-ai
   ```

## Personalización

- **Prompt Starship:** edita `shell/starship.toml` (no sobrescribe `~/.config/starship.toml`)
- **MOTD:** edita `shell/motd.sh` para cambiar tips, colores o arte ASCII
- **Plugins:** se instalan en `shell/plugins/` — añade o quita desde `shell/.zshrc`
- **Agentes custom:** `nxai agent add <nombre> <url>` crea un módulo desde un repo Git

## Licencia

MIT — GUIGERDTS
