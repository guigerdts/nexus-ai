# Patch Notes — NEXUS AI v0.1.0 Final Release

**Release**: v0.1.0
**Date**: 2026-06-03
**Status**: ✅ FINAL — Verified on physical Termux/proot ARM64 device

## Post-Archive Bug Fixes

After the initial v0.1 implementation (21 tasks, 34 scenarios) was archived, 7 bug fixes were applied and verified on a physical Termux/proot ARM64 device. These fixes resolve edge cases discovered during real-world testing that the initial verification pass did not catch.

---

### Fix 1: URL parsing bug in install.sh (line 205)

**Bug**: `url="${entry##*:}"` used `##` (greedy suffix removal) instead of `#` (non-greedy). For a plugin entry like `zsh-autosuggestions:https://github.com/zsh-users/zsh-autosuggestions.git`, the greedy `##*:` matched the **last** colon (after `https:`), producing `//github.com/...` — a broken URL missing the `https:` scheme.

**Fix**: Changed to `url="${entry#*:}"`. The single `#` matches the first colon separator correctly, preserving the full `https://` URL.

**File**: `install.sh`, line 205

**Rationale**: Double `##` in `${var##pattern}` removes the longest matching prefix. Since the URL contains a colon (`https:`), the greedy match consumed everything up to the **last** colon, not the first. This is a classic shell parameter expansion gotcha — `${var#pattern}` (single `#`) is correct for first-colon separation.

---

### Fix 2: grep pipeline safety under `set -euo pipefail` (install.sh, lines 308-309)

**Bug**: Under `set -euo pipefail`, a `grep` that finds no matches causes the entire pipeline to exit with code 1. In the vi-mode verification block, `grep -q "zsh-vi-mode" "$ZSHRC"` and `grep -n "source.*plugins" "$ZSHRC"` would abort the script if the user's `.zshrc` didn't yet have these patterns.

**Fix**: Added `|| true` guards to both grep pipelines:
```bash
vi_mode_line="$(grep -n "zsh-vi-mode" "$ZSHRC" 2>/dev/null | tail -1 | cut -d: -f1 || true)"
last_plugin_line="$(grep -n "source.*plugins" "$ZSHRC" 2>/dev/null | tail -1 | cut -d: -f1 || true)"
```

**File**: `install.sh`, lines 308-309

**Rationale**: `set -euo pipefail` makes **every** pipeline failure fatal. `grep` returns exit code 1 when no match is found — this is not an error in this context. The `|| true` guard ensures the pipeline always succeeds, and downstream checks handle the empty-string case gracefully.

---

### Fix 3: `count_agents()` crash on empty modules/ (shell/motd.sh)

**Bug**: `count_agents()` used `ls -1d "$agents_dir"/*/` to count agent directories. When `modules/` is empty, the glob `*/` does not expand (remains literal), and `ls` returns exit code 2 (no such file or directory). Under `set -euo pipefail` (set by `install.sh` before sourcing `env.sh`/`motd.sh`), this would abort the entire MOTD with a shell error — or worse, abort the parent script.

**Fix**: Replaced with:
```bash
find "$agents_dir" -mindepth 1 -maxdepth 1 -type d -not -name '.*' 2>/dev/null | wc -l
```
`find` exits 0 even when no results match, and `-not -name '.*'` filters hidden directories.

**File**: `shell/motd.sh`, line 60

**Rationale**: `ls` with an empty glob is a well-known shell pitfall. Even with `shopt -s nullglob` (Bash-only), the pattern is unsafe. `find` is POSIX-compatible, deterministic, and returns exit code 0 for empty results. The `2>/dev/null` handles non-existent directories gracefully.

---

### Fix 4: ASCII art — Unicode replaced with pure ASCII (shell/motd.sh)

**Bug**: The original MOTD used Unicode block characters (`███`) for compact mode and box-drawing characters (`─`) for the separator. On Termux/proot ARM64 terminals, Unicode blocks render as garbled characters or question marks, especially in non-graphical or minimal terminal emulators.

**Fix**:
- Block art: Replaced with `figlet -f big` pure ASCII output (all characters in 0x20-0x7e range)
- Compact mode: `███` → `###`
- Separator: `─` (U+2500) → `=` (40 equals signs)
- Tip icon: `💡` (U+1F4A1) → `>>>`

**File**: `shell/motd.sh`, lines 34-46, 51, 88

**Rationale**: Pure ASCII (7-bit printable) is guaranteed to render correctly on every terminal, from the most minimal serial console to full-featured terminal emulators. The `figlet -f big` output was chosen specifically because it produces dense, readable block art using only standard ASCII characters.

---

### Fix 5: Subtitle added to MOTD (shell/motd.sh, line 41)

**Change**: Added `"Framework de Entorno para AI Agents"` in gray (`COLOR_GRAY`) between the ASCII art block and the info line.

**Code**:
```bash
echo -e "${COLOR_GRAY}Framework de Entorno para AI Agents${NEXUS_COLOR_RESET}"
```

**File**: `shell/motd.sh`, line 41

**Rationale**: The subtitle gives immediate context about what NEXUS AI is — essential for first-time users who open a terminal and see the MOTD. Gray color keeps it visually subordinate to the main art and info line.

---

### Fix 6: Terminal width detection — `NEXUS_MOTD_MODE` override + `stty size` fallback (shell/motd.sh, lines 96-101)

**Bug**: Previous width detection relied solely on `tput cols`, which can fail or return incorrect values in minimal environments (e.g., non-interactive shells, cron, SSH without a PTY). There was no way to force full-banner mode.

**Fix**:
- Added `NEXUS_MOTD_MODE` constant at the top of motd.sh, defaulting to `auto`
- Width detection order:
  1. `NEXUS_MOTD_MODE=full` → skip detection, use 80 cols (full banner)
  2. `tput cols` (if stdout is a TTY)
  3. `stty size` fallback (if tput fails)
  4. Default 80 cols

**File**: `shell/motd.sh`, lines 27, 96-101

**Rationale**: The cascading fallback ensures the MOTD works in all environments: interactive, non-interactive, piped, or minimal. The `NEXUS_MOTD_MODE=full` override is specifically designed for `install.sh`'s welcome banner (Fix 7).

---

### Fix 7: install.sh step 7 — force full MOTD banner (install.sh, line 363)

**Change**: Added `NEXUS_MOTD_MODE=full` environment variable before sourcing `motd.sh` in the post-install welcome:

```bash
NEXUS_MOTD_MODE=full source "$NEXUS_ROOT/shell/motd.sh"
```

**File**: `install.sh`, line 363

**Rationale**: The post-install welcome in `install.sh` should always show the full ASCII art banner, regardless of terminal width. Without this override, a user installing in a narrow terminal (e.g., phone split-screen) would see only the compact `### NEXUS AI` line — a poor first impression. The override integrates with the width detection system in Fix 6.

---

## Files Changed

| File | Fixes | Lines Changed |
|------|-------|---------------|
| `install.sh` | 1, 2, 7 | 3 lines (205, 308, 309, 363) |
| `shell/motd.sh` | 3, 4, 5, 6 | 8 lines (34-41, 46, 51, 88, 96-101) |

## Verification

All 7 fixes were verified on a physical Termux/proot ARM64 device with:

| Check | Result |
|-------|--------|
| Plugin URL parsing (colon handling) | ✅ Correct — `https://` preserved |
| `set -euo pipefail` with empty grep | ✅ Exit 0 — no abort |
| `count_agents()` with empty modules/ | ✅ Returns 0, exit 0 |
| ASCII art rendering (all chars 0x20-0x7e) | ✅ No Unicode, renders on all terminals |
| Subtitle position and color | ✅ Gray between art and info |
| Width detection (MOTD_MODE, tput, stty) | ✅ Cascading fallback works |
| install.sh full banner on step 7 | ✅ Always shows full ASCII art |

## Known Post-Release Items (v0.2 candidates)

- ~/.config/starship.toml prompt before overwriting (design.md Open Question)
- ShellCheck integration for CI
- `install.sh` final banner box-drawing characters (verify-report.md SUGGESTION)
- `nexus` CLI command skeleton (`core/nexus.sh`)

---

*This release marks the completion of NEXUS AI v0.1.0 foundation. The framework is ready for agent module development.*
