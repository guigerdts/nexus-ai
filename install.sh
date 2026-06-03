#!/usr/bin/env bash
# NEXUS AI — install.sh
# Instalador principal: detecta entorno, instala dependencias, configura Zsh, plugins, prompt y MOTD
# Version: 0.1.0
#
# Flags: --help, --no-zsh, --no-bashrc, --no-starship, --no-motd, --dir PATH
# Uso: ./install.sh [opciones]

# ── Configuración inicial ─────────────────────────
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=config/env.sh
source "$SCRIPT_DIR/config/env.sh"

# ── Flags por defecto ────────────────────────────
INSTALL_ZSH=true
INSTALL_BASHRC=true
INSTALL_STARSHIP=true
INSTALL_MOTD=true
CUSTOM_DIR=""

# ── Helper: mostrar uso ──────────────────────────
usage() {
    cat <<EOF
NEXUS AI v${NEXUS_VERSION} — Instalador

Uso: install.sh [opciones]

Opciones:
  --help          Muestra esta ayuda y sale
  --no-zsh        Omite la configuración de Zsh
  --no-bashrc      Omite la configuración de Bash (.bashrc)
  --no-starship    Omite Starship (usa vcs_info como fallback)
  --no-motd        Omite el mensaje de bienvenida (MOTD)
  --dir PATH       Establece un directorio de instalación personalizado

Sin opciones: instalación completa en el directorio actual.

Ejemplos:
  install.sh                          Instalación completa
  install.sh --no-zsh                 Solo dependencias y MOTD
  install.sh --no-zsh --no-bashrc     Sin shell config (solo binarios)
  install.sh --no-starship --no-motd  Mínima instalación
  install.sh --dir ~/nexus            Instalar en directorio específico
EOF
    exit 0
}

# ── Parsear flags ─────────────────────────────────
while [[ $# -gt 0 ]]; do
    case "$1" in
        --help)
            usage
            ;;
        --no-zsh)
            INSTALL_ZSH=false
            shift
            ;;
        --no-bashrc)
            INSTALL_BASHRC=false
            shift
            ;;
        --no-starship)
            INSTALL_STARSHIP=false
            shift
            ;;
        --no-motd)
            INSTALL_MOTD=false
            shift
            ;;
        --dir)
            if [ -z "${2:-}" ]; then
                echo "Error: --dir requiere un argumento."
                exit 1
            fi
            CUSTOM_DIR="$2"
            shift 2
            ;;
        *)
            echo "Error: flag desconocido: $1"
            usage
            ;;
    esac
done

# ── Directorio personalizado ─────────────────────
if [ -n "$CUSTOM_DIR" ]; then
    NEXUS_ROOT="$CUSTOM_DIR"
    echo "Usando directorio personalizado: $NEXUS_ROOT"
fi

# ==================================================
#  FUNCIONES DE PROGRESO
# ==================================================
step() {
    local current="$1"
    local total="$2"
    local desc="$3"
    echo ""
    echo -e "${NEXUS_COLOR_PRIMARY}[${current}/${total}]${NEXUS_COLOR_RESET} ${desc}..."
}

ok() {
    echo -e "  ${NEXUS_COLOR_PRIMARY}✓${NEXUS_COLOR_RESET} $1"
}

warn() {
    echo -e "  \033[0;33m⚠\033[0m $1"
}

fail() {
    echo -e "  \033[0;31m✗\033[0m $1"
}

# ==================================================
#  PASO 1: Verificar entorno
# ==================================================
step 1 8 "Verificando entorno"
echo "  Entorno detectado: ${NEXUS_ENV}"
echo "  Arquitectura: ${NEXUS_ARCH}"
echo "  Directorio raíz: ${NEXUS_ROOT}"

if [ ! -d "$NEXUS_ROOT" ]; then
    mkdir -p "$NEXUS_ROOT"
    ok "Directorio raíz creado"
fi

# Verificar bash
if command -v bash &>/dev/null; then
    ok "Bash disponible"
else
    fail "Bash no encontrado. Abortando."
    exit 1
fi

# ==================================================
#  PASO 2: Instalar dependencias del sistema
# ==================================================
step 2 8 "Instalando dependencias del sistema"

# Seleccionar gestor de paquetes según entorno
case "$NEXUS_ENV" in
    termux)
        PKG_MANAGER="pkg"
        ;;
    proot-ubuntu|linux)
        PKG_MANAGER="apt"
        ;;
esac

DEPS=(bash zsh curl git)

if [ "$NEXUS_ENV" = "linux" ]; then
    warn "Entorno no Termux detectado. Se usará apt (puede no funcionar en todas las distribuciones)."
fi

if command -v "$PKG_MANAGER" &>/dev/null; then
    echo "  Usando gestor de paquetes: ${PKG_MANAGER}"
    echo "  Paquetes requeridos: ${DEPS[*]}"

    # Ejecutar instalación de paquetes (silenciosa)
    if ${PKG_MANAGER} update -qq 2>/dev/null && ${PKG_MANAGER} install -y "${DEPS[@]}" 2>/dev/null; then
        ok "Dependencias instaladas correctamente"
    else
        warn "No se pudieron instalar todas las dependencias. Continúa con las disponibles."
    fi
else
    warn "Gestor de paquetes '${PKG_MANAGER}' no encontrado."
    warn "Instala manualmente: ${DEPS[*]}"
fi

# ==================================================
#  PASO 3: Crear estructura de directorios
# ==================================================
step 3 8 "Creando estructura de directorios"

mkdir -p "$NEXUS_ROOT"/{core,shell/plugins,modules,bin,config,lib,logs}
ok "Directorios creados: core/, shell/plugins/, modules/, bin/, config/, lib/, logs/"

# ==================================================
#  PASO 4: Instalar plugins de Zsh
# ==================================================
step 4 8 "Instalando plugins de Zsh"

if [ "$INSTALL_ZSH" = true ]; then

    # Lista de plugins: nombre:url
    PLUGINS=(
        "zsh-autosuggestions:https://github.com/zsh-users/zsh-autosuggestions.git"
        "zsh-syntax-highlighting:https://github.com/zsh-users/zsh-syntax-highlighting.git"
        "fzf:https://github.com/junegunn/fzf.git"
        "fzf-tab:https://github.com/Aloxaf/fzf-tab.git"
        "zoxide:https://github.com/ajeetdsouza/zoxide.git"
        "atuin:https://github.com/atuinsh/atuin.git"
        "thefuck:https://github.com/nvbn/thefuck.git"
        "zsh-vi-mode:https://github.com/jeffreytse/zsh-vi-mode.git"
    )

    INSTALLED_COUNT=0
    FAILED_COUNT=0

    for entry in "${PLUGINS[@]}"; do
        name="${entry%%:*}"
        url="${entry#*:}"
        target="$NEXUS_ROOT/shell/plugins/$name"

        if [ -d "$target" ]; then
            ok "${name} — ya instalado"
            INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
        else
            echo "  Instalando ${name}..."
            if git_output=$(GIT_TERMINAL_PROMPT=0 git clone --depth 1 "$url" "$target" 2>&1); then
                ok "${name} instalado correctamente"
                INSTALLED_COUNT=$((INSTALLED_COUNT + 1))

                # Post-instalación específica por plugin
                case "$name" in
                    fzf)
                        # Intentar compilar binario de fzf
                        (cd "$target" && ./install --bin 2>/dev/null) && ok "fzf binario compilado" || warn "fzf binario no compilado (se usará desde plugins/)"
                        ;;
                esac
            else
                git_error="$(echo "${git_output}" | tail -1)"
                warn "${name} falló: ${git_error}"
                FAILED_COUNT=$((FAILED_COUNT + 1))
            fi
        fi
    done

    echo ""
    ok "Plugins: ${INSTALLED_COUNT} instalados, ${FAILED_COUNT} fallos"

else
    echo "  Omitido (--no-zsh)"
fi

# ==================================================
#  PASO 5: Configurar Starship (prompt)
# ==================================================
step 5 8 "Configurando Starship"

if [ "$INSTALL_STARSHIP" = true ]; then
    if command -v starship &>/dev/null; then
        ok "Starship ya está instalado"
    else
        echo "  Intentando instalar Starship..."
        # Instalar Starship (script oficial)
        if curl -sS https://starship.rs/install.sh | sh -s -- -y 2>/dev/null; then
            ok "Starship instalado correctamente"
        else
            warn "Starship no se pudo instalar — se usará vcs_info como fallback nativo"
        fi
    fi

    # Verificar que el archivo de configuración existe
    if [ -f "$NEXUS_ROOT/shell/starship.toml" ]; then
        ok "Configuración de Starship encontrada en shell/starship.toml"
    else
        warn "Archivo de configuración Starship no encontrado"
    fi

    # Comprobar si el usuario tiene su propio starship.toml
    if [ -f "$HOME/.config/starship.toml" ]; then
        ok "Tu configuración personal de Starship en ~/.config/starship.toml se ha preservado (NEXUS usa su propio archivo)"
    fi
else
    echo "  Omitido (--no-starship — se usará vcs_info como fallback)"
fi

# ==================================================
#  PASO 6: Configurar .zshrc (bloque idempotente)
# ==================================================
step 6 8 "Configurando .zshrc"

if [ "$INSTALL_ZSH" = true ]; then

    ZSHRC="$HOME/.zshrc"
    NEXUS_BLOCK_MARKER="# >>> NEXUS AI BEGIN >>>"

    # ── Backup del .zshrc existente (solo si no hay bloque NEXUS) ──
    if [ -f "$ZSHRC" ]; then
        if ! grep -q "$NEXUS_BLOCK_MARKER" "$ZSHRC" 2>/dev/null; then
            cp "$ZSHRC" "${ZSHRC}.nexus-backup"
            ok "Backup de .zshrc creado en ${ZSHRC}.nexus-backup"
        fi
    fi

    # ── Idempotencia: si ya tiene el bloque, no duplicar ──
    if grep -q "$NEXUS_BLOCK_MARKER" "$ZSHRC" 2>/dev/null; then
        ok "NEXUS AI ya está configurado en .zshrc — omitiendo (no se duplica)"
    else
        # Reemplazar placeholder @NEXUS_ROOT@ con la ruta real y añadir al .zshrc
        if [ -f "$SCRIPT_DIR/shell/.zshrc" ]; then
            # Añadir una línea en blanco antes del bloque
            echo "" >> "$ZSHRC"
            sed "s|@NEXUS_ROOT@|$NEXUS_ROOT|g" "$SCRIPT_DIR/shell/.zshrc" >> "$ZSHRC"
            ok "Configuración de Zsh añadida a ${ZSHRC}"
        else
            fail "Archivo fuente shell/.zshrc no encontrado en ${SCRIPT_DIR}"
        fi
    fi

    # Verificar orden de carga del plugin zsh-vi-mode
    if grep -q "zsh-vi-mode" "$ZSHRC" 2>/dev/null; then
        # Comprobar que zsh-vi-mode es el último plugin cargado
        vi_mode_line="$(grep -n "zsh-vi-mode" "$ZSHRC" 2>/dev/null | tail -1 | cut -d: -f1 || true)"
        last_plugin_line="$(grep -n "source.*plugins" "$ZSHRC" 2>/dev/null | tail -1 | cut -d: -f1 || true)"
        if [ -n "$vi_mode_line" ] && [ -n "$last_plugin_line" ] && [ "$vi_mode_line" -ge "$last_plugin_line" ]; then
            ok "zsh-vi-mode es el último plugin (orden de carga correcto)"
        fi
    fi

else
    echo "  Omitido (--no-zsh)"
fi

# ── Configurar .bashrc (misma lógica idempotente) ──
if [ "$INSTALL_BASHRC" = true ]; then

    BASHRC="$HOME/.bashrc"
    NEXUS_BLOCK_MARKER="# >>> NEXUS AI BEGIN >>>"

    # ── Backup del .bashrc existente (solo si no hay bloque NEXUS) ──
    if [ -f "$BASHRC" ]; then
        if ! grep -q "$NEXUS_BLOCK_MARKER" "$BASHRC" 2>/dev/null; then
            cp "$BASHRC" "${BASHRC}.nexus-backup"
            ok "Backup de .bashrc creado en ${BASHRC}.nexus-backup"
        fi
    fi

    # ── Idempotencia: si ya tiene el bloque, no duplicar ──
    if grep -q "$NEXUS_BLOCK_MARKER" "$BASHRC" 2>/dev/null; then
        ok "NEXUS AI ya está configurado en .bashrc — omitiendo (no se duplica)"
    else
        if [ -f "$SCRIPT_DIR/shell/.bashrc" ]; then
            # Añadir una línea en blanco antes del bloque
            echo "" >> "$BASHRC"
            cat "$SCRIPT_DIR/shell/.bashrc" >> "$BASHRC"
            ok "Configuración de Bash añadida a ${BASHRC}"
        else
            fail "Archivo fuente shell/.bashrc no encontrado en ${SCRIPT_DIR}"
        fi
    fi

else
    echo "  Omitido (--no-bashrc)"
fi

# ==================================================
#  PASO 7: Post-instalación (MOTD + bienvenida)
# ==================================================
step 7 8 "Post-instalación"

if [ "$INSTALL_MOTD" = true ]; then
    echo ""

    # ── Mostrar MOTD por primera vez ──
    if [ -f "$NEXUS_ROOT/shell/motd.sh" ]; then
        # Forzar banner completo para la bienvenida
        # shellcheck source=shell/motd.sh
        NEXUS_MOTD_MODE=full source "$NEXUS_ROOT/shell/motd.sh"
    fi

    echo ""

    # ── Mensaje de bienvenida en español ──
    echo -e "${NEXUS_COLOR_PRIMARY}╔══════════════════════════════════════════════╗${NEXUS_COLOR_RESET}"
    echo -e "${NEXUS_COLOR_PRIMARY}║     ¡BIENVENIDO A NEXUS AI v${NEXUS_VERSION}!          ║${NEXUS_COLOR_RESET}"
    echo -e "${NEXUS_COLOR_PRIMARY}╠══════════════════════════════════════════════╣${NEXUS_COLOR_RESET}"
    echo -e "${NEXUS_COLOR_PRIMARY}║${NEXUS_COLOR_RESET}  Instalación completada exitosamente.        ${NEXUS_COLOR_PRIMARY}║${NEXUS_COLOR_RESET}"
    echo -e "${NEXUS_COLOR_PRIMARY}║${NEXUS_COLOR_RESET}                                                  ${NEXUS_COLOR_PRIMARY}║${NEXUS_COLOR_RESET}"
    echo -e "${NEXUS_COLOR_PRIMARY}║${NEXUS_COLOR_RESET}  Próximos pasos:                                ${NEXUS_COLOR_PRIMARY}║${NEXUS_COLOR_RESET}"
    echo -e "${NEXUS_COLOR_PRIMARY}║${NEXUS_COLOR_RESET}  • source ~/.zshrc  (Zsh) o source ~/.bashrc (Bash) ${NEXUS_COLOR_PRIMARY}║${NEXUS_COLOR_RESET}"
    echo -e "${NEXUS_COLOR_PRIMARY}║${NEXUS_COLOR_RESET}  • o abre una nueva terminal                     ${NEXUS_COLOR_PRIMARY}║${NEXUS_COLOR_RESET}"
    echo -e "${NEXUS_COLOR_PRIMARY}║${NEXUS_COLOR_RESET}  • explora los comandos disponibles              ${NEXUS_COLOR_PRIMARY}║${NEXUS_COLOR_RESET}"
    echo -e "${NEXUS_COLOR_PRIMARY}╚══════════════════════════════════════════════╝${NEXUS_COLOR_RESET}"
    echo ""

    # ── Instrucciones de desinstalación ──
    echo -e "\033[0;37mDocumentación: ${NEXUS_ROOT}/README.md\033[0m"
    echo -e "\033[0;37mPara desinstalar: borra el bloque NEXUS AI de ~/.zshrc y ~/.bashrc, luego elimina ${NEXUS_ROOT}\033[0m"
    echo ""
else
    echo "  Omitido (--no-motd)"
fi

# ==================================================
#  PASO 8: Configurar CLI NEXUS AI y PATH
# ==================================================
step 8 8 "Configurando CLI NEXUS AI"

# Crear symlink bin/nxai si no existe
if [ ! -f "$NEXUS_ROOT/bin/nxai" ]; then
    ln -sf "../core/nexus.sh" "$NEXUS_ROOT/bin/nxai"
    ok "Symlink bin/nxai creado"
else
    ok "Symlink bin/nxai ya existe"
fi

# ── PATH absoluto hardcodeado ─────────────────────
# El template shell/.bashrc usa deteccion dinamica de NEXUS_ROOT,
# que puede fallar en entornos proot/Termux. Este PATH absoluto
# es una red de seguridad escrita al momento de instalacion.
NEXUS_PATH_MARKER="# === NEXUS AI PATH (absoluto) ==="

# Append a .bashrc (si se configuro en Step 6)
if [ "${INSTALL_BASHRC:-false}" = "true" ] && [ -f "$BASHRC" ]; then
    if ! grep -qF "$NEXUS_PATH_MARKER" "$BASHRC" 2>/dev/null; then
        echo "" >> "$BASHRC"
        echo "$NEXUS_PATH_MARKER" >> "$BASHRC"
        echo "export PATH=\"$NEXUS_ROOT/bin:\$PATH\"" >> "$BASHRC"
        ok "PATH absoluto agregado a ${BASHRC}"
    else
        ok "PATH absoluto ya existe en ${BASHRC} — omitiendo"
    fi
fi

# Append a .zshrc (si se configuro en Step 5)
ZSHRC="${ZSHRC:-$HOME/.zshrc}"
if [ "${INSTALL_ZSH:-false}" = "true" ] && [ -f "$ZSHRC" ]; then
    if ! grep -qF "$NEXUS_PATH_MARKER" "$ZSHRC" 2>/dev/null; then
        echo "" >> "$ZSHRC"
        echo "$NEXUS_PATH_MARKER" >> "$ZSHRC"
        echo "export PATH=\"$NEXUS_ROOT/bin:\$PATH\"" >> "$ZSHRC"
        ok "PATH absoluto agregado a ${ZSHRC}"
    else
        ok "PATH absoluto ya existe en ${ZSHRC} — omitiendo"
    fi
fi

ok "CLI NEXUS AI configurado. Probá: nxai help"

# ==================================================
#  FIN
# ==================================================
echo ""
echo -e "${NEXUS_COLOR_PRIMARY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NEXUS_COLOR_RESET}"
echo -e "${NEXUS_COLOR_PRIMARY}Instalación completada.${NEXUS_COLOR_RESET}"
echo -e "${NEXUS_COLOR_PRIMARY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NEXUS_COLOR_RESET}"
echo ""
