# NEXUS AI

Framework de entorno para Termux/proot-Ubuntu.
Convierte Android en una workstation profesional para agentes de IA.

**Estado:** v0.8.0 — estable. Dual-environment (Termux nativo + proot-Ubuntu).

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
│   ├── nexus-log.sh        # Logging con colores [OK]/[WARN]/[ERROR]
│   └── nexus-update.sh     # Actualizaciones: check silencioso + apply
├── modules/                # 49 modulos registrados (9 categorias)
│   ├── opencode/           # AI  — CLI multi-modelo
│   ├── codex/              # AI  — OpenAI Codex CLI
│   ├── gemini-cli/         # AI  — Google Gemini CLI
│   ├── claude-code/        # AI  — Claude Code CLI
│   ├── ollama/             # AI  — LLMs locales
│   ├── engram/             # AI  — memoria persistente
│   ├── sgpt/               # AI  — shell-gpt
│   ├── fabric/             # AI  — automatizacion IA
│   ├── antigravity/        # AI  — CLI experimental (stub)
│   ├── pi/                 # AI  — asistente terminal (stub)
│   ├── gentle-ai/          # AI  — desarrollo asistido (stub)
│   ├── qwen-code/          # AI  — Qwen AI (stub)
│   ├── minimax-cli/        # AI  — MiniMax AI (stub)
│   ├── codegraph/          # AI  — analizador grafos (stub)
│   ├── openclaude/         # AI  — CLI programacion (stub)
│   ├── mistral-vibe/       # AI  — Mistral Vibe (stub)
│   ├── neovim/             # editor — Neovim LSP
│   ├── nvchad/             # editor — NvChad config
│   ├── zsh/                # shell — Z shell
│   ├── starship/           # shell — prompt minimalista
│   ├── oh-my-zsh/          # shell — framework Zsh
│   ├── gh/                 # tools — GitHub CLI
│   ├── bat/                # tools — cat coloreado
│   ├── eza/                # tools — ls moderno
│   ├── lazygit/            # tools — Git TUI
│   ├── jq/                 # tools — JSON CLI
│   ├── fzf/                # tools — fuzzy finder
│   ├── gum/                # tools — UI toolkit
│   ├── curl/               # tools — HTTP client
│   ├── git/                # tools — control versiones
│   ├── wget/               # tools — descarga archivos
│   ├── nodejs/             # language — Node.js
│   ├── python/             # language — Python 3
│   ├── rust/               # language — Rust
│   ├── golang/             # language — Go
│   ├── perl/               # language — Perl
│   ├── php/                # language — PHP
│   ├── clang/              # language — C/C++
│   ├── sqlite/             # db — BD embebida
│   ├── postgresql/         # db — BD relacional
│   ├── mariadb/            # db — BD MySQL fork
│   ├── mongodb/            # db — BD NoSQL (stub)
│   ├── typescript/         # node — TypeScript
│   ├── pm2/                # node — admin procesos
│   ├── nodemon/            # node — reinicio automatico
│   ├── termux-styling/     # ui — personalizacion (stub)
│   ├── nerd-fonts/         # ui — fuentes (stub)
│   ├── banner/             # ui — ASCII banner (stub)
│   ├── n8n/                # automation — workflows
│   └── ...
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

## Modulos disponibles (49 por categoria)

Los modulos se organizan en 9 categorias. Ejecuta `nxai guide` para ver la guia completa.

> **Nota**: sgpt aparece listado en IA / Agentes y en Terminal / Shell. Son 49 modulos unicos (los subtotales suman 50 porque sgpt cuenta en ambas).

### IA / Agentes (16)

| Modulo | Metodo | Descripcion |
|--------|--------|-------------|
| opencode | npm | CLI multi-modelo de codigo abierto (150K+ stars) |
| codex | npm | OpenAI Codex CLI (GPT-5.5) |
| gemini-cli | npm | CLI oficial de Google Gemini |
| claude-code | npm | Claude Code CLI de Anthropic |
| ollama | curl | Ejecuta LLMs locales (LLaMA, Mistral, Qwen) |
| engram | binary | Memoria persistente para sesiones de IA |
| sgpt | pip | Asistente de terminal GPT (shell-gpt) |
| fabric | pip | Framework open-source para automatizacion con IA |
| antigravity | stub | CLI experimental de IA |
| pi | pip | Asistente de IA desde terminal (Pi.ai) |
| gentle-ai | stub | CLI de desarrollo asistido por IA |
| qwen-code | stub | CLI de codigo asistido por Qwen AI |
| minimax-cli | stub | CLI para la API de MiniMax AI |
| codegraph | stub | Analizador de grafos de codigo con IA |
| openclaude | stub | CLI de IA para programacion |
| mistral-vibe | stub | CLI para Mistral AI Vibe coding |

### Editores (2)

| Modulo | Metodo | Descripcion |
|--------|--------|-------------|
| neovim | pkg | Editor moderno con LSP nativo |
| nvchad | git | Configuracion NvChad para Neovim |

### Terminal / Shell (4)

| Modulo | Metodo | Descripcion |
|--------|--------|-------------|
| zsh | pkg | Z shell con plugins y temas |
| starship | curl | Prompt minimalista personalizable |
| oh-my-zsh | git | Framework para gestionar Zsh |
| sgpt | pip | Asistente de terminal GPT (tambien en AI) |

### Herramientas (10)

| Modulo | Metodo | Descripcion |
|--------|--------|-------------|
| gh | pkg | GitHub CLI oficial |
| bat | pkg | cat con sintaxis coloreada |
| eza | pkg | ls moderno con colores y arbol |
| lazygit | pkg | UI interactiva para Git |
| jq | pkg | Procesador JSON de linea de comandos |
| fzf | pkg | Buscador difuso interactivo |
| gum | pkg | Toolkit de UI para shell scripts |
| curl | pkg | Cliente HTTP/HTTPS para transferencia |
| git | pkg | Sistema de control de versiones distribuido |
| wget | pkg | Descarga de archivos via HTTP/HTTPS/FTP |

### Lenguajes (7)

| Modulo | Metodo | Descripcion |
|--------|--------|-------------|
| nodejs | pkg | Entorno JavaScript Node.js y npm |
| python | pkg | Python 3 interprete y pip |
| rust | pkg | Compilador Rust y cargo |
| golang | pkg | Lenguaje Go — compilador y herramientas |
| perl | pkg | Lenguaje de programacion Perl |
| php | pkg | Lenguaje de programacion PHP |
| clang | pkg | Compilador C/C++ LLVM Clang |

### Bases de Datos (4)

| Modulo | Metodo | Descripcion |
|--------|--------|-------------|
| sqlite | pkg | BD SQL embebida zero-config |
| postgresql | pkg | BD SQL relacional PostgreSQL |
| mariadb | pkg | BD SQL fork de MySQL |
| mongodb | stub | BD NoSQL orientada a documentos |

### Node.js (3)

| Modulo | Metodo | Descripcion |
|--------|--------|-------------|
| typescript | npm | Compilador de TypeScript a JavaScript |
| pm2 | npm | Administrador de procesos Node.js |
| nodemon | npm | Monitor de reinicio automatico para Node.js |

### Interfaz de Usuario (3)

| Modulo | Metodo | Descripcion |
|--------|--------|-------------|
| termux-styling | stub | Personalizacion visual de Termux |
| nerd-fonts | stub | Fuentes Nerd Fonts para terminal |
| banner | stub | Banner ASCII de NEXUS AI (ya incluido) |

### Automatizacion (1)

| Modulo | Metodo | Descripcion |
|--------|--------|-------------|
| n8n | npm | Workflow automation — alternativa a Zapier/Make |

Uso: `nxai install --all` para instalar todos, o `nxai install <modulo>` para uno solo.

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
nxai update              # Actualiza NEXUS AI a la última versión
nxai update --check      # Verifica si hay una nueva versión disponible
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
