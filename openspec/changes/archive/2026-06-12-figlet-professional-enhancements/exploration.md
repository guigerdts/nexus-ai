# Exploration: Figlet Professional Enhancements

> Mode: openspec | Phase: explore
> Change slug: `figlet-professional-enhancements`
> Date: 2026-06-12

---

## Overview

Add figlet-based visual enhancements in 4 areas of the NEXUS AI toolkit:
MOTD, `nxai status`, install celebration, and critical error banners.

---

## Current State

### 1. Existing Figlet Pattern — `lib/nexus-guide.sh` (lines 81–131)

The `show_guide()` function contains the **only** production figlet usage:

```bash
# Font chain + width measurement
local _figlet_printed=false
if command -v figlet >/dev/null 2>&1; then
    local _figlet_output _max_width _font
    for _font in "small" "mini" ""; do
        [ -n "$_font" ] && _figlet_output=$(figlet -f "$_font" "NEXUS AI GUIA")
                      || _figlet_output=$(figlet "NEXUS AI GUIA")
        [ -z "$_figlet_output" ] && continue
        _max_width=$(echo "$_figlet_output" | wc -L)
        if [ "$_max_width" -le "$_inner" ]; then
            printf '\033[96m%s\033[0m\n' "$_figlet_output"
            _figlet_printed=true
            break
        fi
    done
fi
# Fallback: separator + uppercase text
```

**Key behaviors to preserve/reuse:**
- Font chain: `small` → `mini` → default
- Width measurement via `wc -L` vs `_inner` (terminal-derived content width)
- Cyan color (ANSI 96)
- Graceful fallback when figlet unavailable or output too wide

### 2. `show_banner()` — `lib/nexus-log.sh` (lines 77–105)

Displays hardcoded ASCII art "NEXUS AI" before every command. Has two variants:
- **Gum variant** (when `NEXUS_GUM_AVAILABLE=true`): centered with `gum style --align center`
- **Plain variant**: raw ASCII, no width detection, no figlet
- Fallback: `echo "NEXUS AI v${VERSION}"` when NOT a TTY

**This is the banner used by EVERY command** (`status`, `install`, `guide`, etc.) — any change here ripples everywhere.

### 3. `nxai status` Routing — `core/nexus.sh` (lines 933–937)

```bash
status)
    show_banner
    check_update_silent
    system_status
    ;;
```

`system_status()` (lines 708–757) prints system info. No figlet, no sub-header.

### 4. Install Success/Error — `core/nexus.sh` (lines 438–470)

In `install_agent()`, after successful install:

```bash
if gum spin ... ; then
    gum style --foreground 42 "[OK] ${target} instalado correctamente"
else
    gum style --foreground 196 "[ERROR] Fallo al instalar ${target}"
fi
```

No TTY or width check specific to celebration — it uses `[ -t 0 ]` only for the gum confirm+spin branch.

### 5. Error Logging — `lib/nexus-log.sh` (lines 55–63)

```bash
log_error() {
    if [ -t 1 ]; then
        echo -e "${NEXUS_COLOR_RED}[ERROR]${NEXUS_COLOR_RESET} $*"
    else
        echo "[ERROR] $*"
    fi
}
```

Simple red `[ERROR]` prefix. No figlet, no distinction between errors and fatal errors.

### 6. MOTD — `shell/motd.sh` (lines 29–39)

Hardcoded ASCII art (pure ASCII, not figlet):

```bash
ascii_art_block() {
    echo -e "${NEXUS_COLOR_PRIMARY}"
    echo ' _   _ ________   ___    _  _____            _____ '
    # ... 6 lines of hardcoded ASCII
    echo -e "${COLOR_GRAY}Framework de Entorno para AI Agents${NEXUS_COLOR_RESET}"
}
```

Has a comment at line 26: `# ── Arte ASCII bloque (figlet -f big) ──` — documenting that this was originally figlet output, but was committed as hardcoded art for portability.

Width detection: uses `tput cols` + `NEXUS_MOTD_MODE=full` override. Falls back to `ascii_art_compact()` below 60 cols.

### 7. Figlet Dependency — `install.sh` (line 271)

```bash
DEPS=(bash zsh curl git figlet)
```

Figlet is now a system dependency — guaranteed installed after `./install.sh` runs. But must still check `command -v figlet` at runtime for safety.

### 8. Color Infrastructure — `config/env.sh` (lines 145–152)

```bash
export NEXUS_COLOR_CYAN='\033[0;36m'
export NEXUS_COLOR_RED='\033[0;31m'
export NEXUS_COLOR_GREEN='\033[0;32m'
export NEXUS_COLOR_RESET='\033[0m'
export NEXUS_COLOR_PRIMARY="${NEXUS_COLOR_CYAN}"
```

Available in all sourced contexts. `-t 1` determined per-function.

---

## Affected Areas

| File | What It Does | Why Affected |
|------|-------------|--------------|
| `shell/motd.sh` | MOTD banner with hardcoded ASCII | Idea 1: replace with dynamic figlet |
| `lib/nexus-log.sh` | `show_banner()`, `log_error()`, `log_ok()` | Idea 2: banner for status; Idea 4: `log_fatal()` |
| `core/nexus.sh` | CLI routing, `install_agent()`, `system_status()` | Idea 2: status sub-header; Idea 3: celebration after install |
| `lib/nexus-guide.sh` | Existing figlet pattern in `show_guide()` | Reference for font chain + width measurement |
| `config/env.sh` | Color vars + TTY detection | Shared infrastructure, no changes expected |
| `lib/nexus-figlet.sh` (new) | Shared figlet helper | Would be created if extracting helper |

---

## Approach Comparison

### Option A: Extract Shared `figlet_render()` Helper (RECOMMENDED)

Create `lib/nexus-figlet.sh` with:

```bash
# ── figlet_render: render figlet text with font chain + width detection ──
# Uso: figlet_render "TEXT" [color_var] [fallback_text]
#   text:        string to render (e.g. "STATUS", "ERROR")
#   color_code:  ANSI color sequence (default: NEXUS_COLOR_CYAN)
#   fallback:    text to show if figlet unavailable/too wide
# Returns: 0 if figlet rendered, 1 if fallback used
figlet_render() {
    local _text="$1"
    local _color="${2:-${NEXUS_COLOR_CYAN}}"
    local _fallback="${3:-$_text}"

    # Compute terminal width (same pattern as guide/help)
    local _cols _inner
    _cols=$(tput cols 2>/dev/null || echo 80)
    _inner=$(( _cols - 4 ))
    [ "$_inner" -lt 40 ] && _inner=40
    [ "$_inner" -gt 120 ] && _inner=120

    if ! command -v figlet >/dev/null 2>&1; then
        [ -n "$_fallback" ] && echo -e "${_color}${_fallback}${NEXUS_COLOR_RESET}"
        return 1
    fi

    local _figlet_output _max_width _font
    for _font in "small" "mini" ""; do
        if [ -n "$_font" ]; then
            _figlet_output=$(figlet -f "$_font" "$_text" 2>/dev/null)
        else
            _figlet_output=$(figlet "$_text" 2>/dev/null)
        fi
        [ -z "$_figlet_output" ] && continue
        _max_width=$(echo "$_figlet_output" | wc -L)
        if [ "$_max_width" -le "$_inner" ]; then
            echo -e "${_color}${_figlet_output}${NEXUS_COLOR_RESET}"
            return 0
        fi
    done

    # All fonts too wide, fallback
    [ -n "$_fallback" ] && echo -e "${_color}${_fallback}${NEXUS_COLOR_RESET}"
    return 1
}
```

| Pros | Cons |
|------|------|
| Single source of truth for font chain + width measurement | One more file to maintain |
| Consistent behavior across all 4 features | Slight abstraction overhead |
| Easy to add features later | Callers need to handle return value |
| DRY — avoids 4x repetition of same pattern | Must be sourced by each caller |
| Clear upgrade path for global changes | |

### Option B: Inline Per Feature

Each feature replicates the font chain + width measurement independently.

| Pros | Cons |
|------|------|
| No new files | 4x repetition of identical ~20 line pattern |
| Each feature can customize independently | Inconsistency if one gets updated |
| Simpler mental model | Violates DRY — each is a maintenance burden |

**Verdict**: Option A is clearly better. The figlet pattern is already well-established
in `nexus-guide.sh` — extracting it into a shared function avoids 4x duplication.

---

## Feature-by-Feature Analysis

### 1. MOTD Figlet Banner

**Problem**: `ascii_art_block()` currently outputs hardcoded ASCII via `echo` statements.

**Solution**: Replace (or augment) `ascii_art_block()` to call `figlet_render "NEXUS AI"` when figlet is available. If figlet is unavailable or terminal is too narrow, fall back to a hardcoded compact version or the current hardcoded art.

**Edge cases**:
- `NEXUS_MOTD_MODE=full` must still force the banner (currently forces cols=80)
- Termux compatibility: current art is pure ASCII which Termux handles well; figlet is pure ASCII too, so this should work
- Terminal width < 60 cols: compact mode `ascii_art_compact()` should still activate

**Files changed**: `shell/motd.sh` (+ source of new helper)
**Effort**: **Medium** — need to integrate with existing width/MOTD_MODE logic

### 2. `nxai status` Figlet Header

**Problem**: `system_status()` prints raw info with no visual header.

**Solution**: Call `figlet_render "STATUS"` at the beginning of `system_status()`, or add a header before the `system_status` call in the `status` routing block. The figlet header should appear AFTER `show_banner()` but BEFORE the system info.

**Edge cases**:
- Already has `show_banner()` before — this adds a SECOND header
- Non-TTY output should skip figlet
- Narrow terminals should get the fallback

**Files changed**: `core/nexus.sh` or `lib/nexus-log.sh` (add header call)
**Effort**: **Low** — simplest of the 4; just add one function call

### 3. Install Celebration

**Problem**: After successful install, only `gum style "[OK]"` is shown.

**Solution**: After successful install + `[ -t 1 ]` + `$(tput cols) >= 80`, call `figlet_render "$target"` with green color to show the tool name as ASCII art, followed by a checkmark.

**Shape of change** (in `core/nexus.sh`):
```bash
if gum spin ... ; then
    if [ -t 1 ] && [ "$(tput cols 2>/dev/null || echo 0)" -ge 80 ]; then
        figlet_render "$target" "$NEXUS_COLOR_GREEN"
    fi
    gum style --foreground 42 "[OK] ${target} instalado correctamente"
    ...
```

**Edge cases**:
- `[ -t 1 ]` check for stdout (after install completes — output should still go to the terminal)
- Terminal width ≥ 80 cols minimum for tool name figlet
- Agent names with hyphens or special chars (figlet handles standard ASCII fine)
- Non-interactive installs (scripts, Docker): skip completely
- Category installs (install multiple): only show for each successful one — could be noisy

**Files changed**: `core/nexus.sh` (install_agent function)
**Effort**: **Low-Medium** — simple logic but needs placement in the right success path

### 4. Critical Error Banner

**Problem**: `log_error()` only shows `[ERROR]` prefix. Fatal errors need to stand out.

**Solution**: Create `log_fatal()` in `lib/nexus-log.sh` that:
1. Checks `[ -t 1 ]` — only renders figlet on interactive terminals
2. Calls `figlet_render "ERROR"` with red color
3. Then displays the error message with `log_error` styling

```bash
log_fatal() {
    if [ -t 1 ] && command -v figlet >/dev/null 2>&1; then
        figlet_render "ERROR" "$NEXUS_COLOR_RED"
    fi
    log_error "$*"
}
```

**Usage restriction**: Only call `log_fatal()` for truly unrecoverable errors — failed critical dependency, corrupted state, etc. Warnings and recoverable errors still use `log_error()`.

**Edge cases**:
- Must distinguish from `log_error` — this is for FATAL only
- JSON mode: should emit structured output, skip figlet
- Pipe/redirect: skip figlet, just emit `[FATAL]`

**Files changed**: `lib/nexus-log.sh`
**Effort**: **Low** — one new function wrapping existing `log_error`

---

## Effort Summary

| Idea | Effort | Complexity | Risk |
|------|--------|------------|------|
| 1. MOTD Figlet Banner | **Medium** | Medium — integrates with existing width/MOTD_MODE | Figlet might not be installed yet at MOTD time; needs graceful fallback |
| 2. `nxai status` Header | **Low** | Trivial — one function call | Redundancy with `show_banner()`; test visual appearance |
| 3. Install Celebration | **Low-Medium** | Low — TTY+width guard + figlet call | Can be noisy during batch installs; special chars in names |
| 4. Critical Error Banner | **Low** | Low — new `log_fatal()` wrapper | Overuse risk; must enforce fatal-only discipline |
| **Shared helper** | **Low** | Foundation — one-time extraction | Must source correctly; must handle all edge cases |

---

## Recommendation for Proposal Phase

**Extract a shared `figlet_render()` helper** in `lib/nexus-figlet.sh`, then implement features in order:

1. **`lib/nexus-figlet.sh`** — create shared function (foundation for everything else)
2. **Idea 1: MOTD** — replace hardcoded art in `ascii_art_block()` in `shell/motd.sh`
3. **Idea 2: Status** — add header in `system_status()` or the status routing in `core/nexus.sh`
4. **Idea 3: Celebration** — add after successful install in `core/nexus.sh`
5. **Idea 4: Fatal** — add `log_fatal()` in `lib/nexus-log.sh`

**Do NOT modify the existing `show_guide()` figlet code** during this change — it continues to work as-is. It can be migrated to use the shared helper in a future refactor.

---

## Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| Figlet not available at runtime | All features fallback gracefully | `command -v figlet` in shared helper; all callers handle return value |
| Terminal too narrow for figlet output | Font chain measures vs `_inner`, falls back | Generic fallback text in caller |
| Feature creep — adding figlet where it doesn't belong | Visual noise, slower CLI | Restrict: MOTD, status header, install celebration, and fatal errors ONLY |
| `log_fatal()` overused for non-fatal errors | Dilutes meaning of fatal banner | Document in code + code review enforcement; only for catastrophic failures |
| MOTD figlet + MOTD_MODE=full conflict | `NEXUS_MOTD_MODE=full` must still force banner | Check MOTD_MODE first, then figlet |
| Batch install celebration noise | 20 figlet banners during `nxai install --all` | Consider aggregate celebration or per-agent throttle; evaluate during design |

---

## Ready for Proposal

**Yes**. The exploration is complete. Key findings:

1. **Figlet is a system dependency** (install.sh line 271) — guaranteed available after install, but always check at runtime
2. **The figlet pattern** (font chain `small`→`mini`→default + `wc -L` width check + cyan color) is well-established in `nexus-guide.sh` and should be extracted to a shared function
3. **Extraction** avoids 4x duplication — clear ROI
4. **All 4 features** have clear, low-risk integration points
5. **The proposal** should recommend: shared helper first, then implement features in dependency order (1→2→3→4), with the option to defer MOTD (Idea 1) if risk is higher
