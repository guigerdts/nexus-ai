# NEXUS AI

Framework de entorno para Termux/proot-Ubuntu.
Convierte Android en una workstation profesional para agentes de IA.

**Estado:** v0.8.0 — estable. Dual-environment (Termux nativo + proot-Ubuntu).
**Sintaxis:** `nxai install <categoria> --<flag>` — ejemplo: `nxai install ai --opencode`
**Total:** 82 herramientas en 9 categorias.

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
├── modules/                # 82 modulos registrados (9 categorias)
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
│   ├── gentle-ai/          # AI  — desarrollo asistido (compilado desde fuente)
│   ├── qwen-code/          # AI  — Qwen AI (npm)
│   ├── minimax-cli/        # AI  — MiniMax AI (npm mmx-cli)
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
curl -fsSL https://raw.githubusercontent.com/guigerdts/nexus-ai/main/install.sh | bash
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
| `--all` | Instalación completa (todos los componentes) |
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

## Modulos disponibles (82 herramientas)

Los modulos se organizan en 9 categorias. Ejecuta `nxai guide` para ver la guia completa.

### IA / Agentes (17)

| Modulo | Metodo | Descripcion |
|--------|--------|-------------|
| opencode | npm | CLI multi-modelo de codigo abierto (150K+ stars) |
| agy | binary | Reemplazo de Gemini CLI (Antigravity) |
| claude-code | binary | Claude Code CLI de Anthropic |
| gemini-cli | npm | CLI oficial de Google Gemini (DEPRECATED → agy) |
| codex | npm | OpenAI Codex CLI (fork ARM64 en Termux) |
| ollama | curl | Ejecuta LLMs locales (LLaMA, Mistral, Qwen) |
| engram | binary | Memoria persistente para sesiones de IA |
| sgpt | pip | Asistente de terminal GPT (shell-gpt) |
| fabric | curl | Framework open-source para automatizacion con IA |
| antigravity | curl | CLI experimental de IA (comparte flag agy) |
| gentle-ai | git | CLI de desarrollo asistido por IA (compilado desde fuente) |
| qwen-code | npm | CLI de codigo asistido por Qwen AI |
| minimax-cli | npm | CLI multimodal para la API de MiniMax AI (mmx-cli) |
| codegraph | stub | Analizador de grafos de codigo con IA |
| openclaude | stub | CLI de IA para programacion |
| mistral-vibe | stub | CLI para Mistral AI Vibe coding |
| pi | stub | Asistente de IA desde terminal |

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

### Herramientas (22)

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
| lsd | stub | ls con iconos y colores |
| tree | stub | Visualizacion de arbol de directorios |
| make | stub | Herramienta de build automatizado |
| bc | stub | Calculadora de precision arbitraria |
| shfmt | stub | Formateador de shell scripts |
| tmate | stub | Terminal compartida via SSH |
| proot | stub | Proot-distro para entornos Linux |
| imagemagick | stub | Procesamiento de imagenes CLI |
| cloudflared | stub | Tunel Cloudflare para exposicion web |
| ncurses | stub | Biblioteca de interfaz de terminal |
| translate | stub | Traduccion CLI via Google Translate |
| html2text | stub | Conversion HTML a texto plano |

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
| postgresql | pkg | BD SQL relacional PostgreSQL |
| mariadb | pkg | BD SQL fork de MySQL |
| sqlite | pkg | BD SQL embebida zero-config |
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

Uso: `nxai install ai --opencode` para instalar un agente por categoria y flag.

## Uso

```bash
nxai help                    # Muestra ayuda completa
nxai status                  # Estado del sistema (versión, entorno, agentes)
nxai list                    # Resumen de categorias
nxai list ai                 # Lista agentes de IA con estado
nxai install ai --opencode   # Instala opencode en categoria AI
nxai install tools --all     # Instala todas las herramientas
nxai remove opencode         # Desinstala opencode
nxai remove ai --gum         # Desinstala gum de categoria tools
nxai update                  # Actualiza NEXUS AI a la última versión
nxai update --check          # Verifica si hay una nueva versión disponible
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
