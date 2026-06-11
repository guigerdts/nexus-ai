#!/usr/bin/env bash
# modules/gentle-ai/install.sh
# Instala gentle-ai desde fuente: clona repo + compila con Go
set -euo pipefail

# ── Source install library ─────────────────────────
# shellcheck source=../../lib/nexus-install.sh
NEXUS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$NEXUS_ROOT/lib/nexus-install.sh"
source "$(dirname "${BASH_SOURCE[0]}")/metadata.sh"

# ── Dependencias ───────────────────────────────────
log_info "Verificando dependencias para gentle-ai..."

GO_VERSION=""
if command -v go &>/dev/null; then
    GO_VERSION="$(go version 2>/dev/null | sed -n 's/.*go\([0-9]*\.[0-9]*\).*/\1/p')"
fi

if [ -z "$GO_VERSION" ] || [ "$(printf '%s\n' "1.23" "$GO_VERSION" | sort -V | head -1)" != "1.23" ]; then
    log_warn "Go >= 1.23 requerido. Detectado: ${GO_VERSION:-ninguno}"
    if [ "${NEXUS_TERMUX_ACCESSIBLE:-false}" = "true" ] || [ "${NEXUS_ENV:-}" = "termux" ]; then
        log_info "Instalando golang via pkg..."
        pkg install -y golang 2>/dev/null || apt install -y golang 2>/dev/null || {
            log_error "No se pudo instalar golang. Instalalo manualmente: pkg install golang"
            exit 1
        }
    else
        log_error "Go >= 1.23 no encontrado. Instala Go primero."
        exit 1
    fi
fi
log_ok "Go ${GO_VERSION} detectado"

if ! command -v git &>/dev/null; then
    log_info "Instalando git..."
    if [ "${NEXUS_TERMUX_ACCESSIBLE:-false}" = "true" ] || [ "${NEXUS_ENV:-}" = "termux" ]; then
        pkg install -y git 2>/dev/null || apt install -y git 2>/dev/null
    else
        apt install -y git 2>/dev/null || {
            log_error "No se pudo instalar git"
            exit 1
        }
    fi
fi

# ── Clonar/actualizar repositorio ──────────────────
REPO_DIR="${AGENT_REPO_DIR:-$NEXUS_ROOT/gentle-ai}"
REPO_URL="https://github.com/Gentleman-Programming/gentle-ai.git"

if [ -d "$REPO_DIR/.git" ]; then
    log_info "Actualizando repositorio existente en ${REPO_DIR}..."
    git -C "$REPO_DIR" fetch origin && git -C "$REPO_DIR" reset --hard origin/main
else
    log_info "Clonando repositorio desde ${REPO_URL}..."
    rm -rf "$REPO_DIR" 2>/dev/null || true
    git clone "$REPO_URL" "$REPO_DIR"
fi

# ── Parche Android/Termux ───────────────────────────
PATCHER_SRC="$NEXUS_ROOT/modules/gentle-ai/termux-patches.go"
PATCHER_BIN="$NEXUS_ROOT/bin/termux-patcher-gentle-ai"
mkdir -p "$NEXUS_ROOT/bin"
if [ ! -f "$PATCHER_BIN" ] || [ "$PATCHER_SRC" -nt "$PATCHER_BIN" ]; then
    log_info "Compilando patcher de Termux..."
    if ! go build -o "$PATCHER_BIN" "$PATCHER_SRC"; then
        log_error "No se pudo compilar el patcher"
        exit 1
    fi
fi

log_info "Aplicando parches Termux a gentle-ai..."
patch_output=$("$PATCHER_BIN" "$REPO_DIR" 2>&1)
patch_rc=$?
echo "$patch_output" | while IFS= read -r line; do log_info "$line"; done
if [ $patch_rc -ne 0 ]; then
    log_error "Falló el patcher de Termux"
    exit 1
fi
log_ok "Parches Termux aplicados"

# ── Compilar ───────────────────────────────────────
log_info "Compilando gentle-ai..."
cd "$REPO_DIR"
CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o gentle-ai ./cmd/gentle-ai/

# ── Instalar binario ───────────────────────────────
INSTALL_DIR="${PREFIX:-/usr/local}/bin"
mkdir -p "$INSTALL_DIR"
cp gentle-ai "$INSTALL_DIR/gentle-ai"
chmod +x "$INSTALL_DIR/gentle-ai"

log_ok "gentle-ai compilado e instalado en ${INSTALL_DIR}/gentle-ai"

# ── Registrar ───────────────────────────────────────
mark_installed "$AGENT_NAME" "source"
exit 0
