# >>> NEXUS AI BEGIN >>>
# ============================================
# NEXUS AI — shell/.zshrc
# Configuración de Zsh con plugins y prompt dual
# Version: 0.1.0
# ============================================
#
# @NEXUS_ROOT@ es reemplazado por install.sh con la ruta real.
# Para uso directo desde el repo: la auto-detección de Zsh lo resuelve.

# ── Determinar NEXUS_ROOT ─────────────────────────
NEXUS_ROOT="${NEXUS_ROOT:-@NEXUS_ROOT@}"
if [ ! -d "$NEXUS_ROOT/config" ]; then
    # Fallback: auto-detección desde la ubicación de este archivo
    case "${(%):-%x}" in
        *.zsh|*.zshrc)
            _zsh_dir="$(cd "$(dirname "${(%):-%x}")" 2>/dev/null && pwd)"
            NEXUS_ROOT="$(cd "$_zsh_dir/.." 2>/dev/null && pwd || echo "$NEXUS_ROOT")"
            unset _zsh_dir
            ;;
    esac
fi

# ── Source env.sh ─────────────────────────────────
if [ -f "$NEXUS_ROOT/config/env.sh" ]; then
    # shellcheck source=../config/env.sh
    source "$NEXUS_ROOT/config/env.sh"
fi

# ── Cargar config centralizada nexus.env ─────────
# confia en env.sh que ya agrego los PATH esenciales.
if [ -n "${NEXUS_ROOT:-}" ] && [ -f "$NEXUS_ROOT/config/nexus.env" ]; then
    source "$NEXUS_ROOT/config/nexus.env"
fi

# ═══════════════════════════════════════════════════
#  PLUGINS DE ZSH
# ═══════════════════════════════════════════════════
#
# ORDEN DE CARGA (documentado — ver design.md):
#   1. zsh-autosuggestions
#   2. zsh-syntax-highlighting   (debe ir DETRÁS de autosuggestions)
#   3. fzf
#   4. fzf-tab
#   5. zoxide
#   6. atuin
#   7. thefuck
#   8. zsh-vi-mode               ← SIEMPRE ÚLTIMO
#
# zsh-vi-mode debe ser el último porque rebinda teclas y widgets.
# Si se carga antes, rompe keybindings de otros plugins.

_PLUGIN_DIR="$NEXUS_ROOT/shell/plugins"

# ── 1. zsh-autosuggestions ────────────────────────
if [ -f "$_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
    source "$_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# ── 2. zsh-syntax-highlighting ────────────────────
if [ -f "$_PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
    source "$_PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# ── 3. fzf ────────────────────────────────────────
if [ -d "$_PLUGIN_DIR/fzf" ]; then
    # Añadir binario fzf al PATH si existe
    [ -f "$_PLUGIN_DIR/fzf/bin/fzf" ] && export PATH="$_PLUGIN_DIR/fzf/bin:$PATH"
    # Source shell integration
    [ -f "$_PLUGIN_DIR/fzf/shell/completion.zsh" ] && source "$_PLUGIN_DIR/fzf/shell/completion.zsh"
    [ -f "$_PLUGIN_DIR/fzf/shell/key-bindings.zsh" ] && source "$_PLUGIN_DIR/fzf/shell/key-bindings.zsh"
fi

# ── 4. fzf-tab ────────────────────────────────────
if [ -f "$_PLUGIN_DIR/fzf-tab/fzf-tab.plugin.zsh" ]; then
    source "$_PLUGIN_DIR/fzf-tab/fzf-tab.plugin.zsh"
fi

# ── 5. zoxide ─────────────────────────────────────
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
fi

# ── 6. atuin ──────────────────────────────────────
if command -v atuin &>/dev/null; then
    eval "$(atuin init zsh)"
fi

# ── 7. thefuck ────────────────────────────────────
if command -v thefuck &>/dev/null; then
    eval "$(thefuck --alias)"
fi

# ── 8. zsh-vi-mode — SIEMPRE ÚLTIMO ──────────────
# Cargar al final para no interferir con keybindings de otros plugins.
# Ver diseño: zsh-vi-mode rewrites keybindings; si carga antes, rompe
# zsh-autosuggestions (accept-suggestion) y zsh-syntax-highlighting.
ZVM_CURSOR_STYLE_ENABLED=false
if [ -f "$_PLUGIN_DIR/zsh-vi-mode/zsh-vi-mode.plugin.zsh" ]; then
    source "$_PLUGIN_DIR/zsh-vi-mode/zsh-vi-mode.plugin.zsh"
fi

unset _PLUGIN_DIR

# ═══════════════════════════════════════════════════
#  PROMPT DUAL: Starship → vcs_info (fallback)
# ═══════════════════════════════════════════════════
#
# 1. Si Starship está disponible → lo usamos como prompt primario
# 2. Si no → vcs_info nativo (sin dependencias externas)

if command -v starship &>/dev/null; then
    export STARSHIP_CONFIG="$NEXUS_ROOT/shell/starship.toml"
    eval "$(starship init zsh)"
else
    # ── Fallback: vcs_info nativo ──
    autoload -Uz vcs_info
    precmd() {
        vcs_info
    }
    zstyle ':vcs_info:git:*' formats '(%b)'
    zstyle ':vcs_info:git:*' actionformats '(%b|%a)'
    setopt PROMPT_SUBST
    PROMPT='%B%F{cyan}%n@%m%f%b %B%F{white}%~%f%b ${vcs_info_msg_0_}%# '
fi

# ═══════════════════════════════════════════════════
#  MOTD
# ═══════════════════════════════════════════════════
if [ -f "$NEXUS_ROOT/shell/motd.sh" ]; then
    # shellcheck source=../shell/motd.sh
    source "$NEXUS_ROOT/shell/motd.sh"
fi

# <<< NEXUS AI END <<<
