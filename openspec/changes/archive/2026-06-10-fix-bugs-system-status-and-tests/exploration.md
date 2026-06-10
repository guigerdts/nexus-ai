## Exploration: Bug fixes for system_status() and test.sh files

### Current State

The NEXUS AI project is a bash shell framework for Termux/proot. It has a status command (`nxai status`) that iterates over registered agents and counts how many are installed, and a list command (`nxai list`) that shows a detailed table. Multiple `test.sh` files in `modules/*/` determine per-agent installation status.

---

### Bug 1: system_status() — No AGENT_* variable cleanup [CRITICAL]

**File**: `core/nexus.sh`, lines 631–642
**What**: `system_status()` iterates over `AGENT_ORDER[]` and sources each `metadata.sh` WITHOUT first unsetting the previous agent's exported variables (`AGENT_BINARY`, `AGENT_DEPRECATED`, etc.).

```bash
for _name in "${AGENT_ORDER[@]}"; do
    local _dir="${AGENTS[$_name]}"
    if [ -f "$_dir/metadata.sh" ]; then
        source "$_dir/metadata.sh"        # ← leaks AGENT_BINARY from previous iteration
    fi
    if [ -n "${AGENT_BINARY:-}" ] && command -v "$AGENT_BINARY" &>/dev/null; then
        ...
```

**Comparison**: All other iteration loops in the codebase DO unset AGENT_* before sourcing:
- `list_agents()` at lines 139–141 and 206–208
- `manifest_import()` at lines 683–685
- `config/agents.registry.sh` at line 98

**Impact**: If agent A sets `AGENT_BINARY="foo"` and agent B has no `AGENT_BINARY` (or its metadata.sh is missing), agent B inherits `AGENT_BINARY="foo"` from agent A. If `command -v foo` succeeds, agent B is counted as installed — a false positive. The only thing preventing worse leaks is that metadata.sh uses `export` and `source` re-exports, so the var keeps its PREVIOUS value if the new metadata.sh doesn't set it.

**Severity**: CRITICAL — can produce wildly incorrect agent counts in `nxai status`.

---

### Bug 2: system_status() — No manifest check [MEDIUM]

**File**: `core/nexus.sh`, lines 637–641
**What**: `system_status()` counts an agent as installed if EITHER the binary is in PATH OR test.sh exits 0. It never consults `logs/installed.txt`.

```bash
if [ -n "${AGENT_BINARY:-}" ] && command -v "$AGENT_BINARY" &>/dev/null; then
    installed_count=$((installed_count + 1))
elif [ -f "$_dir/test.sh" ] && bash "$_dir/test.sh" &>/dev/null 2>&1; then
    installed_count=$((installed_count + 1))
fi
```

**Comparison**: `list_agents()` requires BOTH manifest AND path/test.sh to report "INSTALADO":
```bash
if [ "$_in_manifest" = true ] && [ "$_in_path" = true ]; then
    _t_status="INSTALADO"
else
    _t_status="NO INSTAL."
fi
```

**Impact**: An agent whose test.sh always passes (like claude-code — see Bug 4) is ALWAYS counted as installed by `system_status()`, even when never installed. `nxai list` would correctly show it as "NO INSTAL." because it checks the manifest too. This makes `nxai status` and `nxai list` give INCONSISTENT results.

**Severity**: MEDIUM — status output is unreliable.

---

### Bug 3: system_status() — No timeout for test.sh execution [MEDIUM]

**File**: `core/nexus.sh`, line 639
**What**: `system_status()` runs test.sh without any timeout guard. If a test.sh hangs, the entire `nxai status` command hangs.

```bash
elif [ -f "$_dir/test.sh" ] && bash "$_dir/test.sh" &>/dev/null 2>&1; then
```

**Comparison**: Both `list_agents()` (lines 170, 234) and `agent_test()` (line 600) use `timeout 10`:
```bash
timeout 10 bash "$_dir/test.sh" &>/dev/null && _in_path=true
```

**Impact**: A hanging test.sh (waiting on network, stuck process, etc.) blocks the entire status command with no recovery.

**Severity**: MEDIUM — hangs are possible, but unlikely with current test.sh files.

---

### Bug 4: claude-code/test.sh — Operator precedence `||` / `&&` always passes [HIGH]

**File**: `modules/claude-code/test.sh`, line 4
**What**: The test always exits 0 regardless of whether `claude-code` is installed.

```bash
command -v claude-code || echo "[INFO] claude-code no instalado (manual)" && exit 0
```

**Bash parsing**: Due to left-associative `||` / `&&` with equal precedence:
- `(command -v claude-code || echo "[INFO]...") && exit 0`
- If `command -v` SUCCEEDS → `||` short-circuits → `exit 0` runs → ALWAYS PASS
- If `command -v` FAILS → `echo` runs (always exits 0) → `exit 0` runs → ALWAYS PASS

**Impact**: claude-code is ALWAYS detected as installed by both `system_status()` AND `list_agents()`. The comment says "no bloquea si no lo esta" but the implementation actually makes it invisible — it never reports FAIL even when claude-code isn't installed.

**Severity**: HIGH — the agent is invisible to the detection system.

---

### Bug 5: codex/test.sh — Always exits 1 [MEDIUM]

**File**: `modules/codex/test.sh`, line 4–5
**What**: The test always exits 1.

```bash
echo "INFO: Codex CLI no soportado en ARM64 — test omitido"
exit 1
```

**Impact**: codex is NEVER detected as installed, even on x86_64 where it IS supported. The comment says "no disponible en ARM64" but there is no architecture check — on every arch, the test returns failure.

**Note**: This may be intentional for ARM64, but the unconditionally-fail pattern means codex cannot be detected as installed on any architecture. The test should check `NEXUS_ARCH` (or `uname -m`) and only fail on arm64.

**Severity**: MEDIUM — codex can't be verified as installed on any platform.

---

### Bug 6: termux-styling/test.sh — Redundant `-z "$BINARY"` check [LOW]

**File**: `modules/termux-styling/test.sh`, line 5
**What**: The `-z "$BINARY"` check is always false because `BINARY` is hardcoded to "termux-styling".

```bash
BINARY="termux-styling"
if [ -z "$BINARY" ] || command -v "$BINARY" &>/dev/null; then
```

**Analysis**: `-z "termux-styling"` is always false (string is non-empty). The `||` always falls through to `command -v`. The test behavior is correct (reports FAIL when termux-styling isn't in PATH, which is the expected state since it's a Termux package). The `-z` is dead code.

**Likely root cause**: Copy-pasted from a template where `BINARY="${AGENT_BINARY:-}"` was intended. Compare with `gentle-ai/test.sh` which does it correctly:
```bash
BINARY="${AGENT_BINARY:-gentle-ai}"
```

**Severity**: LOW — no functional impact, just dead code.

---

### Bug 7: install_via_curl — No failure check on curl download [HIGH]

**File**: `lib/nexus-install.sh`, lines 157–167
**What**: The function pipes curl output to bash but never checks if curl succeeded.

```bash
install_via_curl() {
    local url="$1"
    log_info "Instalando desde $url..."
    if command -v curl &>/dev/null; then
        bash <(curl -fsSL "$url")    # ← no error check!
    else
        log_error "curl no disponible."
        return 1
    fi
}
```

**Impact**: If `curl -fsSL "$url"` fails (404, DNS error, network down), the process substitution `<( )` produces an empty/error output. `bash <(empty)` exits 0. The function returns success even though nothing was installed. The caller (`antigravity/install.sh`) then calls `command -v agy`, finds nothing, and reports failure — BUT the error message is misleading ("agy not in PATH") rather than "curl download failed".

**Severity**: HIGH — silent failure on download errors, misleading diagnostics.

**Caller**: Only used by `modules/antigravity/install.sh` line 16.

---

### Bug 8: update_installed_manifest remove — sed regex injection [MEDIUM]

**File**: `lib/nexus-install.sh`, line 431
**What**: `sed -i` uses the agent name directly as a regex pattern without escaping.

```bash
remove)
    sed -i "/^${agent}$/d" "$manifest" 2>/dev/null || true
```

**Impact**: If agent name contains `/`, `\`, `&`, `.`, or other sed-special characters, the expression breaks. For standard agents (simple ASCII names like "claude-code"), this is safe. But custom agents added via `nxai agent add` could have problematic names.

**Comparison**: The `install` case at line 428 correctly uses `grep -Fx` for exact string matching, which doesn't have this issue.

**Severity**: MEDIUM — theoretical for standard agents, real for custom names.

---

### Bug 9: PYTHONPATH accumulation on every env.sh source [LOW]

**File**: `config/env.sh`, lines 45–47
**What**: `PYTHONPATH` grows with duplicate entries each time `env.sh` is sourced.

```bash
_python_site=$(python3 -c "import site; print(site.getsitepackages()[0])" 2>/dev/null || true)
[ -n "$_python_site" ] && export PYTHONPATH="$_python_site:${PYTHONPATH:-}"
```

**Context**: `env.sh` is sourced in **5+ locations**:
1. `core/nexus.sh` line 20 (main CLI)
2. `core/nexus.sh` line 801 (dashboard)
3. `lib/nexus-install.sh` line 24 (install lib, sourced by many install.sh)
4. `install.sh` (root-level) line 88
5. `shell/motd.sh` line 13
6. Inside `remove_agent()` gum spin sub-shell (line 459)

**Impact**: After 3+ sources, `PYTHONPATH` contains `/site-packages:/site-packages:/site-packages:/original`. While Python handles duplicate paths gracefully, it wastes PATH lookup time and indicates poor idempotency.

**Fix model**: The same file has the correct guard pattern for PATH at lines 97–108 using `case ":$PATH:"`.

**Severity**: LOW — functional but wastes lookup time.

---

### Bug 10: registry_list() — Variable cross-contamination [LOW]

**File**: `config/agents.registry.sh`, line 154
**What**: `registry_list()` sources metadata.sh in a loop without unsetting AGENT_* first (same pattern as Bug 1).

```bash
for _name in "${AGENT_ORDER[@]}"; do
    ...
    if [ -f "$_meta" ]; then
        source "$_meta"    # ← no unset before
        echo "${AGENT_NAME:-$_name} | ..."
    fi
done
```

**Impact**: Low — `registry_list()` is a debug helper, not user-facing. But it's the same pattern as Bug 1 and should be fixed for consistency.

**Severity**: LOW — debug-only function.

---

### Comparison: system_status() vs list_agents()

| Aspect | system_status() | list_agents() |
|--------|----------------|---------------|
| Unset AGENT_* before source | ❌ No | ✅ Yes (lines 139-141) |
| Manifest (installed.txt) check | ❌ No | ✅ Yes (grep -Fx) |
| timeout for test.sh | ❌ No | ✅ Yes (timeout 10) |
| AGENT_BINARY="none" handling | ❌ No | ✅ Yes |
| AGENT_DEPRECATED check | ❌ No | ✅ Yes |
| `:-` fallback on AGENTS[$name] | ❌ No (`$name` must exist) | ✅ Yes (`${AGENTS[$_name]:-}`) |

---

### bin/nxai — NOT a bug (symlink, not copy)

**File**: `bin/nxai`
**Reality**: `bin/nxai -> ../core/nexus.sh` — it IS a symlink, correctly pointing to `core/nexus.sh`. The comment on line 6 confirms this: `# Symlink: bin/nxai -> ../core/nexus.sh`. The two files are not duplicated. **No bug here.**

---

### Approach for a shared function

Both `system_status()` and `list_agents()` iterate agents and check installation. A shared function would reduce duplication:

```
agent_status(name) → returns "installed" | "not_installed" | "deprecated"
├── Unset AGENT_* vars
├── Source metadata.sh
├── Check deprecated
├── Check manifest (grep -Fx "name" installed.txt)
├── If test.sh exists: timeout 10 bash test.sh
├── Else if AGENT_BINARY: command -v
├── Requires BOTH manifest AND path for "installed"
└── Return combined result
```

**Caveat**: The `list_agents()` display logic (ANSI formatting, filtering, etc.) is specific and should stay separate. The shared function would only handle the detection logic.

---

### Risks when fixing

1. **Fixing #1** (add unset to system_status): Low risk — just adds missing cleanup. All other loops already do this.
2. **Fixing #2** (add manifest check): MEDIUM risk — changes `system_status()` semantics. Agents installed outside the manifest (pre-manifest system) would no longer count. Mitigation: run `manifest_import()` first or add a fallback.
3. **Fixing #3** (add timeout): Low risk — prevents hangs.
4. **Fixing #4** (claude-code operator precedence): MEDIUM risk — changes behavior from ALWAYS-PASS to actually checking. Users relying on the old buggy behavior would see claude-code as "not installed" in `nxai status`.
5. **Fixing #5** (codex): Add architecture guard. Low risk if added correctly.
6. **Fixing #6** (termux-styling): Just cleanup. Low risk.
7. **Fixing #7** (install_via_curl): Add `|| return $?` after `bash <(curl ...)`. Low risk, better error reporting.
8. **Fixing #8** (sed escaping): Change to `grep -vFx` or escape for sed. Low risk.
9. **Fixing #9** (PYTHONPATH): Add case guard. Low risk.
10. **Fixing #10** (registry_list): Add unset. Low risk.

### Dependencies between fixes

- Fix 1, 2, 3 can be done together for `system_status()`
- Fix 4, 5, 6 are independent test.sh fixes
- Fix 7 and 8 are independent lib fixes
- Fix 9 is independent env.sh fix
- Fix 10 is an independent registry fix

### Ready for Proposal

**Yes**. All bugs are confirmed with clear reproduction paths. The only user assumption that was wrong was "bin/nxai and core/nexus.sh are identical copies" — they ARE properly symlinked. Everything else is confirmed.

Recommended fix order:
1. Fix 1 (critical — cross-contamination in system_status)
2. Fix 4 (high — claude-code always passes)
3. Fix 7 (high — install_via_curl silent failure)
4. Fix 2 + 3 (medium — status reliability + hangs)
5. Fix 5 + 6 + 8 + 9 + 10 (low/medium — consistency)
