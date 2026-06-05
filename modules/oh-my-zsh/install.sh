#!/usr/bin/env bash
# modules/oh-my-zsh/install.sh
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── Verificar dependencias ─────────────────────────
check_dependency "git" "git --version" || exit 1
check_dependency "zsh" "zsh --version" || exit 1

# ── Definir destino ────────────────────────────────
OH_MY_ZSH_DIR="${HOME}/.oh-my-zsh"
REPO="https://github.com/ohmyzsh/ohmyzsh.git"

# ── Verificar si ya esta instalado ──────────────────
if [ -d "$OH_MY_ZSH_DIR" ]; then
    log_info "oh-my-zsh ya esta instalado en $OH_MY_ZSH_DIR"
    mark_installed "oh-my-zsh" "latest"
    exit 0
fi

# ── Instalar oh-my-zsh via git clone ────────────────
log_info "Instalando oh-my-zsh desde $REPO..."
RUNZSH=no git clone --depth 1 "$REPO" "$OH_MY_ZSH_DIR"

# ── Verificar instalacion ──────────────────────────
if [ -d "$OH_MY_ZSH_DIR" ]; then
    mark_installed "oh-my-zsh" "latest"
    log_ok "oh-my-zsh instalado correctamente en $OH_MY_ZSH_DIR"
    log_info "Configura Zsh como shell predeterminada: chsh -s $(which zsh)"
else
    log_error "Fallo la instalacion de oh-my-zsh"
    exit 1
fi
