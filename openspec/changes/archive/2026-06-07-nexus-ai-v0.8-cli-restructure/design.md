# Design: NEXUS AI CLI Restructure (v0.8)

## Technical Approach

Hybrid: add a **parsing layer** in `core/nexus.sh` before the existing case/esac dispatch, plus a new `config/categories.sh` for flag→name resolution. Keep all existing dispatch paths as backward-compat fallback.

**Correction**: `installed.txt` stays FLAT (one name per line). Category is read from each module's `metadata.sh` — NOT from installed.txt.

## Architecture Decisions

### CLI Parser Design

| Option | Tradeoff | Decision |
|--------|----------|----------|
| Fork full case/esac rewrite in nexus.sh | Clean slate but breaks every existing path | **Rejected** — too risky |
| Add parsing shim before case dispatch | Catches category mode BEFORE existing dispatch; unknown patterns fall through | **Chosen** — zero breakage for old syntax |

Parser flow: `resolve_args()` at top of MAIN. If `$1` is a known category → `CATEGORY_MODE=true`; shift (now `$2` becomes command). Flag args (`--tool`) accumulate in `TOOL_FLAGS[]`. If `$1` is a command → pass through untouched.

### Category→Flag Mapping

| Option | Tradeoff | Decision |
|--------|----------|----------|
| Only in metadata.sh | Every CLI op scans 50+ metadata files | **Rejected** — slow |
| `config/categories.sh` + metadata.sh | Single file with arrays. Metadata gets AGENT_FLAG for display. | **Chosen** — O(1) lookup |

### Category Manifest Tracking

| Option | Tradeoff | Decision |
|--------|----------|----------|
| `logs/categories/<cat>.txt` per cat | 9 files, sync issues | **Rejected** |
| Category from metadata.sh only | Read on demand from each module's metadata.sh | **Chosen** — simplest, matches user correction |

**Correction override**: installed.txt format stays unchanged (name per line). Category functions read from metadata.sh.

### Per-Module Lifecycle Contract

**uninstall.sh**: `source lib/nexus-install.sh` → `uninstall_via_$METHOD` → `mark_removed "$AGENT_NAME"` → `exit 0`. No args. Always exits 0.

**update.sh**: Check installed version → re-install if newer → `mark_installed` → `exit 0`.

### GLIBC Binary Strategy

`install_via_binary()`: download tarball, extract to `$NEXUS_ROOT/bin/`, create wrapper script with `LD_LIBRARY_PATH` to bundled glibc libs. Wrapper name = `<tool>`, actual binary renamed to `<tool>.bin`.

### List Command Architecture

`list_agents()` receives optional category filter. Columns: Herramienta, Flag, Comando, Estado. 3-state detection unchanged (manifest+path=INSTALADO, path+NOmanifest=EXTERNO, neither=NO INSTALADO).

## Data Flow

```
nxai install ai --opencode

  core/nexus.sh MAIN
    → resolve_args(): $1="install" → pass through
    → case "install" → install_agent "$@"
      → $1="ai" — is a category? YES (CATEGORIES[ai])
      → shift; remaining: "--opencode"
      → parse_flags: --opencode → FLAG_TO_AGENT["opencode"]="opencode"
      → for each name → existing single-install path
        → source modules/opencode/{metadata,install}.sh
        → mark_installed("opencode") → installed.txt: "opencode"

  Backward compat: nxai install opencode
    → resolve_args(): bare name → existing dispatch
```

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `config/categories.sh` | **New** | CATEGORIES[], CATEGORY_ORDER[], FLAG_TO_AGENT[], AGENT_TO_FLAG[] |
| `config/agents.registry.sh` | Modify | Source categories.sh, AGENT_FLAG field |
| `core/nexus.sh` | Modify | Add resolve_args(), parse_category_flags(), category install, uninstall alias |
| `lib/nexus-install.sh` | Modify | Add `category_manifest_list()`, `category_manifest_has()` |
| `lib/nexus-update.sh` | Modify | Add per-module update routing |
| `modules/*/metadata.sh` | Modify | Add AGENT_FLAG to all 50 modules |
| `modules/*/uninstall.sh` | **New** x50 | Per-module uninstall |
| `modules/*/update.sh` | **New** x50 | Per-module update |
| `modules/<35+ new>/` | **New** | Stub module directories |

## Interfaces / Contracts

```bash
# config/categories.sh
declare -A CATEGORIES=( [ai]="opencode codex gemini-cli ..." ... )
declare -a CATEGORY_ORDER=( ai editor shell tools language db node ui automation )
declare -A FLAG_TO_AGENT=( [opencode]=opencode [codex]=codex ... )
declare -A AGENT_TO_FLAG=( [opencode]=opencode [codex]=codex ... )

# Category functions (category from metadata.sh, NOT installed.txt)
category_manifest_list()     # → names of all installed agents
category_manifest_has()      # name → 0 if in manifest
agent_get_category()         # name → category (reads metadata.sh)

# Flag resolution
flag_to_agent()              # flag → module name
resolve_category_flags()     # category "args..." → resolved names
```

## Testing Strategy

| Layer | What | Approach |
|-------|------|----------|
| Unit | Flag→name mapping | Source categories.sh, verify all 84 entries |
| Unit | Category manifest | In-memory test with mock metadata |
| Integration | `nxai list` | Source nexus.sh, grep for columns and states |
| Manual | Full CLI on Termux | Install, list, backward compat |

## Migration / Rollout

No migration. installed.txt format is NOT changed. Rollback: per-PR `git revert`.
