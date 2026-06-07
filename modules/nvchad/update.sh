#!/usr/bin/env bash
# modules/nvchad/update.sh
# Actualiza nvchad a la version mas reciente

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/nexus-install.sh" 2>/dev/null || {
    echo "[ERROR] nexus-install.sh no encontrado"
    exit 1
}
source "$SCRIPT_DIR/metadata.sh" 2>/dev/null || true

log_info "Verificando actualizacion para ${AGENT_NAME:-nvchad}..."

_dir="${AGENTS[$AGENT_NAME]:-}"
if [ -n "$_dir" ] && [ -d "$_dir/.git" ]; then
    log_info "Actualizando via git pull..."
    (cd "$_dir" && git pull) && {
        mark_installed "$AGENT_NAME"
        log_ok "${AGENT_NAME} actualizado correctamente."
    } || log_warn "Fallo git pull para ${AGENT_NAME}"
elif [ -f "$SCRIPT_DIR/install.sh" ]; then
    log_info "No es repositorio git, reinstalando..."
    (source "$SCRIPT_DIR/install.sh") && {
        mark_installed "$AGENT_NAME"
        log_ok "${AGENT_NAME} actualizado correctamente."
    }
else
    log_warn "${AGENT_NAME} no tiene install.sh — no se puede actualizar."
fi

exit 0
