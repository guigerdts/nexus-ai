# Tasks: Fix bugs in system_status, test.sh scripts, and install/manifest helpers

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | ~50–65 |
| 400-line budget risk | Low |
| Chained PRs recommended | No |
| Suggested split | Single PR |
| Delivery strategy | ask-on-risk |
| Chain strategy | pending |

Decision needed before apply: No
Chained PRs recommended: No
Chain strategy: pending
400-line budget risk: Low

### Suggested Work Units

| Unit | Goal | Files | Dependencies |
|------|------|-------|-------------|
| 1 | system_status cleanup | `core/nexus.sh` | None |
| 2 | test.sh fixes | `modules/claude-code/test.sh`, `modules/codex/test.sh`, `modules/termux-styling/test.sh` | None |
| 3 | Install helper fixes | `lib/nexus-install.sh` | None |
| 4 | PYTHONPATH dedup | `config/env.sh` | None |
| 5 | registry_list() unset guard | `config/agents.registry.sh` | None |

All units are independent — can be applied in any order. Suggested order: 1 → 2 → 3 → 4 → 5.

## Phase 1: system_status cleanup (CRITICAL)

- [x] 1.1 `core/nexus.sh` — Add `unset AGENT_*` loop before `source "$_dir/metadata.sh"` in `system_status()` (line 634)
- [x] 1.2 `core/nexus.sh` — Wrap test.sh call with `timeout 30 bash "$_dir/test.sh"` (line 639)
- [x] 1.3 `core/nexus.sh` — Add manifest check via `grep -qxF "$_name" "$NEXUS_ROOT/logs/installed.txt"` so agent only counts if in manifest AND (binary OR test.sh OK) — lines 637–641

## Phase 2: test.sh fixes

- [x] 2.1 `modules/claude-code/test.sh` — Fix `||`/`&&` precedence: replace line 4 with `command -v claude-code &>/dev/null || { echo "[INFO] claude-code no instalado (manual)"; exit 1; }`
- [x] 2.2 `modules/codex/test.sh` — Add `NEXUS_ARCH` guard: skip with `exit 0` on arm64; check `command -v codex` otherwise; remove bare `exit 1`
- [x] 2.3 `modules/termux-styling/test.sh` — Remove dead `[ -z "$BINARY" ]` from line 5 (BINARY is hardcoded non-empty)

## Phase 3: Install helper fixes

- [x] 3.1 `lib/nexus-install.sh` — `install_via_curl()`: add `|| return $?` after `bash <(curl -fsSL "$url")` (line 162) to propagate curl failure
- [x] 3.2 `lib/nexus-install.sh` — `update_installed_manifest remove`: replace `sed -i "/^${agent}$/d"` (line 431) with `grep -vxF "$agent" "$manifest" > "${manifest}.tmp" && mv "${manifest}.tmp" "$manifest"` to avoid regex injection

## Phase 4: Config cleanup

- [x] 4.1 `config/env.sh` — Add `case ":$PYTHONPATH:" in *:"$_python_site":*) ;; *) ... ;; esac` guard before `export PYTHONPATH` (line 46)
- [x] 4.2 `config/agents.registry.sh` — Add `unset AGENT_*` before `source "$_meta"` in `registry_list()` (line 154)
