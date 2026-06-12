# Exploration: Nexus Guide — Magenta Boxes & Figlet Title

> Mode: openspec | Phase: explore
> Change slug: `nexus-guide-magenta-boxes-and-figlet-title`
> Date: 2026-06-12

---

## 1. Tool Availability

| Tool     | Status       | Path         |
|----------|-------------|--------------|
| `figlet` | ✅ Available | `/bin/figlet` |
| `toilet` | ❌ Not found | —            |
| `tput`   | ✅ Available | `/bin/tput`  |

**Conclusion**: Part 1 will use `figlet` (the only available large-ASCII renderer). Fallback path (uppercase + padding) is needed only if `figlet` is absent at runtime (defensive check).

---

## 2. Current State — `lib/nexus-guide.sh`

### 2a. `show_guide()` — Title Rendering (lines 54-70)

```bash
show_guide() {
    echo ""
    echo -e "${_CYAN}════════════════════════════════════════${_RESET}"
    echo -e "${_CYAN}  Guia NEXUS AI por Categorias${_RESET}"
    echo -e "${_CYAN}════════════════════════════════════════${_RESET}"
    echo ""
    # ... then calls show_guide_category for each category
}
```

- Uses a hardcoded `_SEP`-like line (40 `═` chars)
- Title text: `Guia NEXUS AI por Categorias` (not uppercase)
- Color: `_CYAN` = `\033[96m` (bright cyan)
- No ASCII art, no dynamic width

### 2b. `_print_category()` — Category Output (lines 15-51)

```bash
_print_category() {
    local _title="$1"
    shift
    local _has_uninstall="$1"
    shift
    local _name _desc _cmd

    # Header cyan
    echo ""
    echo -e "${_CYAN}${_SEP}${_RESET}"
    echo -e "${_CYAN}  ${_title}${_RESET}"
    echo -e "${_CYAN}${_SEP}${_RESET}"

    # Columns
    printf "%-16s %-35s %s\n" "Herramienta" "Descripcion" "Instalar"
    printf "%-16s %-35s %s\n" "----------------" "-----------------------------------" "--------"

    # Tools loop with printf
    while [ $# -gt 0 ]; do
        _name="$1"
        _desc="$2"
        _cmd="$3"
        shift 3
        if [ "$_cmd" = "(stub)" ]; then
            printf "%-16s %-35s ${_GRAY}%s${_RESET}\n" "$_name" "$_desc" "$_cmd"
        else
            printf "%-16s %-35s ${_YELLOW}%s${_RESET}\n" "$_name" "$_desc" "$_cmd"
        fi
    done

    # Uninstall
    if [ "$_has_uninstall" = "yes" ]; then
        echo -e "${_GRAY}Desinstalar: nxai remove <herramienta>${_RESET}"
    fi
    echo ""
}
```

- Each category is printed with loose `echo`/`printf` — **no box/border**
- `_SEP` = `══════════════════════════════` (34 chars) — hardcoded, not dynamic
- Column widths are fixed (16 + 35 = 51 chars, plus the command column)
- Each category ends with a blank line (`echo ""`)

### 2c. Color Variables (lines 7-11)

```bash
_CYAN="\033[96m"
_YELLOW="\033[33m"
_GRAY="\033[2m\033[90m"
_RESET="\033[0m"
_SEP="══════════════════════════════"
```

---

## 3. Affected Code — The Box-Drawing Pattern from `core/nexus.sh`

### Full Block: Lines 42-116 of `core/nexus.sh` (inside `show_help()`)

```bash
if [ -t 1 ]; then
    local _cols _bw _inner _i _content _line _plain _visible _pad _divider
    _cols=$(tput cols 2>/dev/null || echo 80)
    _bw=$(( _cols - 2 ))
    [ "$_bw" -lt 78 ] && _bw=78
    [ "$_bw" -gt 86 ] && _bw=86
    _inner=$(( _bw - 2 ))

    # Divider ─: _inner - 2 (prefixed by "  " in content)
    _divider=""
    for ((_i=0; _i<_inner-2; _i++)); do _divider+="─"; done

    _content=$( ... )   # builds content with printf

    # ── Borde superior ╭─╮ ──
    printf '\033[38;5;201m╭'
    for ((_i=0; _i<_inner; _i++)); do printf '─'; done
    printf '╮\033[0m\n'

    # ── Lineas de contenido con padding individual ──
    while IFS= read -r _line; do
        _plain=$(sed $'s/\x1b\[[0-9;]*[a-zA-Z]//g' <<< "$_line")
        _visible=${#_plain}
        _pad=$(( _inner - _visible ))
        [ "$_pad" -lt 0 ] && _pad=0
        printf '\033[38;5;201m│\033[0m%s%*s\033[38;5;201m│\033[0m\n' "$_line" "$_pad" ''
    done <<< "$_content"

    # ── Borde inferior ╰─╯ ──
    printf '\033[38;5;201m╰'
    for ((_i=0; _i<_inner; _i++)); do printf '─'; done
    printf '╯\033[0m\n'
fi
```

### Key Components Isolated

**Strip-ANSI** (line 106):
```bash
_plain=$(sed $'s/\x1b\[[0-9;]*[a-zA-Z]//g' <<< "$_line")
```

**Width calculation** (lines 44-48):
```bash
_cols=$(tput cols 2>/dev/null || echo 80)
_bw=$(( _cols - 2 ))
[ "$_bw" -lt 78 ] && _bw=78
[ "$_bw" -gt 86 ] && _bw=86
_inner=$(( _bw - 2 ))
```

- `_cols`: terminal width (via `tput cols`, fallback 80)
- `_bw`: box width = cols - 2 (1 char padding each side), clamped 78-86
- `_inner`: content width = box width - 2 (for the border │ characters → actually _inner is the space BETWEEN the borders, used for ─ count)

Wait — let me re-examine. The box borders use `╭─╮` pattern. `_bw` is the full box width (including corners). The top border prints `╭` + `_inner` dashes + `╮`. So `_inner` is the number of dashes, which equals the content width inside the box.

Then each content line is: `│` + `_line` + `_pad` spaces + `│`.

Where `_pad = _inner - _visible`. So `_visible` (stripped-ANSI length) must fit within `_inner`.

`_inner = _bw - 2`. And `_bw = _cols - 2`. So `_inner = _cols - 4`.

Wait, actually let me think about this more carefully:

- `_cols = 80` (typical terminal)
- `_bw = 80 - 2 = 78` (clamped to 78-86, so 78)
- `_inner = 78 - 2 = 76`

So the box is 78 chars wide (╭ + 76 ─ + ╮ = 78), and content is 76 chars wide inside.

But the clamping `[ "$_bw" -lt 78 ] && _bw=78` means minimum box width is 78, and `[ "$_bw" -gt 86 ] && _bw=86` means max is 86. So content inner width ranges from 76 to 84.

**Printing loop** (lines 105-111):
```bash
while IFS= read -r _line; do
    _plain=$(sed $'s/\x1b\[[0-9;]*[a-zA-Z]//g' <<< "$_line")
    _visible=${#_plain}
    _pad=$(( _inner - _visible ))
    [ "$_pad" -lt 0 ] && _pad=0
    printf '\033[38;5;201m│\033[0m%s%*s\033[38;5;201m│\033[0m\n' "$_line" "$_pad" ''
done <<< "$_content"
```

- Strips ANSI from each line → measures visible length
- Calculates padding to right-justify before the right `│`
- Floors pad at 0 (if content accidentally overflows, the box just won't close perfectly)

**Box border characters**: `╭` `╮` `╰` `╯` `─` `│`

**Color**: `\033[38;5;201m` — neon magenta (ANSI 256-color code 201)

---

## 4. Approaches

### Part 1 — Title in `show_guide()`

**Approach A: Figlet (primary — figlet available)**

```bash
# Check if figlet is available
if command -v figlet &>/dev/null; then
    echo ""
    echo -e "${_CYAN}$(figlet "NEXUS AI GUIA")${_RESET}"
    echo -e "${_CYAN}  POR CATEGORIAS${_RESET}"    # with extra padding
    echo ""
else
    # fallback (see below)
fi
```

The default figlet font produces ~5-line ASCII art for "NEXUS AI GUIA" (confirmed working). "por Categorias" becomes "POR CATEGORIAS" in uppercase with extra padding.

**Approach B: Toilet** — not available, discard.

**Approach C: Fallback** — if neither figlet nor toilet
```bash
echo ""
echo ""
echo -e "${_CYAN}════════════════════════════════════════${_RESET}"
echo -e "${_CYAN}  NEXUS AI GUIA POR CATEGORIAS${_RESET}"
echo -e "${_CYAN}════════════════════════════════════════${_RESET}"
echo ""
```

Keeps current pattern but uppercase text + one extra blank line above and below.

### Part 2 — Box Around `_print_category` Output

**Approach A: Reuse exact `core/nexus.sh` pattern (recommended)**

Wrap `_print_category` output in the same box-drawing pattern:
1. Define a `_print_box()` or similar helper that:
   - Gets terminal width via `tput cols`
   - Calculates `_bw` and `_inner` (clamped same as help box — but maybe relaxed for guide since categories have wider content)
   - Prints `╭─╮` top border in `\033[38;5;201m`
   - Prints each content line with strip-ANSI, visible-width padding, and `│` borders
   - Prints `╰─╯` bottom border

2. Modify `_print_category()` to capture its output and pipe through the box wrapper.

**Design decision to make**: The `show_help()` box clamps `_bw` to 78-86. For guide categories (which have columns at fixed widths 16+35 = 51 + command column), we should likely use a wider or more relaxed clamp. The category table content can be wider than the help content.

Possible approaches to generate content for the box:
- Option A: Modify `_print_category` to build a string variable instead of immediately echoing, then pass to a box-drawing function
- Option B: Have `_print_category` echo/printf as normal but capture the output in a temporary variable/here-string and pipe through box drawing
- Option C: Capture `_print_category` output into a variable (like `_content=$(...)_print_category ... )`) and then box it, similar to how `show_help()` captures `_content`

**Approach B: Simpler box (discarded)**
Using `gum style --border rounded` if gum is available. **Problem**: Uses magenta ANSI color (38;5;201) which is the requirement — gum's default colors may not match, and we want consistency with `show_help()`.

---

## 5. Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| Figlet not installed at runtime | Title falls back to plain text | Check `command -v figlet` at runtime |
| ANSI 38;5;201 unsupported in old terminals | Shows wrong color or no color | Use 256-color — widely supported since ~2012; terminals without it fall back to nearest color |
| `tput cols` fails (e.g., non-interactive shell) | Box width may be wrong | Fallback to `echo 80` as in original code |
| Content wider than `_inner` | Box breaks visually | `_pad = max(0, _inner - _visible)` — the original already handles this gracefully |
| The `_print_category` table has fixed columns (16+35+flex) | May overflow box on narrow terminals | The clamping already exists; content will just hit right border gracefully |
| The `_print_category` function returns nothing — it only echoes | Need to capture output for wrapping | Capture with `_content=$(..._print_category ...)` pattern |

---

## 6. Ready for Proposal

**Yes**. The exploration is complete. Key findings:

1. **figlet** is available, **toilet** is not → use figlet with fallback
2. **tput** is available → dynamic terminal width detection works
3. **Box-drawing code** in `core/nexus.sh` lines 99-116 is clean, self-contained, and reusable
4. Strip-ANSI uses `sed $'s/\x1b\[[0-9;]*[a-zA-Z]//g'`
5. Visible width measured with `${#_plain}`
6. Padding uses `%*s` format specifier before the right `│`
7. The `_print_category` function's output needs to be captured and wrapped — the pattern from `show_help()` (capture into `_content` then feed line-by-line) is the right approach
