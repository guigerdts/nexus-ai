#!/usr/bin/env bash
# modules/nvchad/install.sh
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/nexus-install.sh"

# ── Verificar dependencias ─────────────────────────
check_dependency "git" "git --version" || exit 1
check_dependency "Neovim" "nvim --version" || exit 1

# ── Definir destino ────────────────────────────────
NVCHAD_DIR="${HOME}/.config/nvim"
REPO="https://github.com/NvChad/starter"

# ── Verificar si ya esta instalado ──────────────────
if [ -f "$NVCHAD_DIR/init.lua" ]; then
    log_info "NvChad ya esta instalado en $NVCHAD_DIR"
    mark_installed "nvchad" "latest"
    exit 0
fi

# ── Crear directorio si no existe ──────────────────
mkdir -p "$(dirname "$NVCHAD_DIR")"

# ── Instalar NvChad via git clone ──────────────────
log_info "Instalando NvChad desde $REPO..."
git clone --depth 1 "$REPO" "$NVCHAD_DIR"

# ── Verificar instalacion ──────────────────────────
if [ -f "$NVCHAD_DIR/init.lua" ]; then
    mark_installed "nvchad" "latest"
    log_ok "NvChad instalado correctamente en $NVCHAD_DIR"
else
    log_error "Fallo la instalacion de NvChad"
    exit 1
fi
