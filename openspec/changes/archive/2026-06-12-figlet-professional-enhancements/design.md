# Design: Figlet Professional Enhancements

## Technical Approach
Extract existing figlet pattern from `lib/nexus-guide.sh` into a shared `lib/nexus-figlet.sh` helper. Four consumers call it with different text and colors. All degrade gracefully if figlet is unavailable or terminal is too narrow.

## Architecture Decisions

### Decision: Shared helper vs inline
- **Choice**: Shared `figlet_render()` in new file
- **Alternatives**: Inline per consumer, extract into existing file
- **Rationale**: Pattern used in 5 places; DRY; easy to test; single fallback behavior

### Decision: Bundle install celebration
- **Choice**: Single "COMPLETADO" figlet for batch, individual per-tool figlet for single installs
- **Alternatives**: Figlet per tool even in batch mode
- **Rationale**: 20 figlets in a row is noise, not celebration

### Decision: log_fatal() as separate function
- **Choice**: New `log_fatal()` in lib/nexus-log.sh, NOT reused by log_error()
- **Alternatives**: Modify log_error() to use figlet, add flag
- **Rationale**: Explicit call site = deliberate use; prevents figlet overuse

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `lib/nexus-figlet.sh` | Create | Shared `figlet_render()` helper |
| `shell/motd.sh` | Modify | Replace hardcoded ASCII with figlet_render("NEXUS AI") |
| `core/nexus.sh` | Modify | Add figlet_render("STATUS") in status routing; source new file |
| `lib/nexus-install.sh` | Modify | Add figlet_render(name) for single install, track batch list |
| `lib/nexus-log.sh` | Modify | Add `log_fatal()` with figlet_render("ERROR") in red |

## Function Signatures

```bash
# lib/nexus-figlet.sh
figlet_render() {
    local _text="$1"
    local _color="${2:-96}"       # ANSI color code, default cyan
    local _font1="${3:-small}"
    local _font2="${4:-mini}"
    local _font3="${5:-}"
    # font chain: font1 → font2 → font3 → uppercase fallback
    # width detection: tput cols → _inner clamp 76-86
    # wc -L measurement vs _inner
    # prints directly to stdout
}

# lib/nexus-log.sh
log_fatal() {
    local _msg="$@"
    figlet_render "ERROR" "91"
    echo -e "${NEXUS_COLOR_ERROR}[FATAL]${NEXUS_COLOR_RESET} $_msg"
    exit 1
}
```

## Data Flow
```
nxai install <tool>
  → install_agent()
    → (single) figlet_render "TOOLNAME" 92  → print
    → (batch)   add to list → after loop: figlet_render "COMPLETADO" 92 → print list

nxai status
  → case "status"
    → figlet_render "STATUS" → print version → system_status()

Terminal opens
  → shell/motd.sh with NEXUS_MOTD_MODE=full
    → figlet_render "NEXUS AI" → print

log_fatal "repo unreachable"
  → figlet_render "ERROR" 91 → print fatal message → exit 1
```

## Open Questions
- [ ] Should `figlet_render()` go through stdout or a return variable?
- [ ] Exact _inner clamp values for MOTD (likely 40-60, not 76-86)?
- [ ] Need NEXUS_ROOT available at MOTD time for source?

## Testing Strategy
Manual visual verification for each feature (no shell test runner available).

## Migration / Rollout
No migration needed. New file is sourced by core/nexus.sh.