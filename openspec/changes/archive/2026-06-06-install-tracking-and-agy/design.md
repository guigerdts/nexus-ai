# Design: Install Tracking and Antigravity CLI (agy)

## Technical Approach

Add a plain-text install manifest (`logs/installed.txt`) as the source of truth for nxai-tracked installs. `list_agents()` reads the manifest first, then checks `command -v` — producing three states (INSTALADO / EXTERNO / NO INSTALADO). Create `modules/agy/` for Google's official CLI (`agy`). Redirect `modules/antigravity/` (old stub) to agy. Deprecate `modules/gemini-cli/` with a banner.

This maps directly to the proposal's approach and the delta specs for `agent-install`, `nexus-cli`, and `agent-registry`.

## Architecture Decisions

### Decision: Manifest storage format

| Option | Tradeoff | Decision |
|--------|----------|----------|
| **One name per line in `installed.txt`** | Simple, grep-able, no parsing needed | **Chosen** |
| JSON/YAML | Over-engineered for a list of names | Rejected |
| SQLite | Adds dependency, no benefit for flat list | Rejected |

**Rationale**: The manifest is append+remove only. A flat file with one entry per line is the simplest thing that works — `grep -Fx` for existence, `sed -i` for removal. No parsing needed.

### Decision: Three-state detection flow

| Option | Tradeoff | Decision |
|--------|----------|----------|
| **Manifest first, then PATH** | Correct: separates nxai-tracked from externally-installed | **Chosen** |
| PATH first, then manifest | Misleading — would show INSTALADO for anything in PATH that happens to be in manifest | Rejected |

**Rationale**: The manifest is authoritative for "did nxai install this?". An agent in PATH but NOT in manifest is explicitly EXTERNO — the whole point of this change.

### Decision: Manifest sync point

| Option | Tradeoff | Decision |
|--------|----------|----------|
| **Inside `mark_installed()` / `mark_removed()`** | Single call site, install flow not missed | **Chosen** |
| Separate call at every `install_agent()`/`remove_agent()` site | Easy to miss, duplicated logic | Rejected |

**Rationale**: `mark_installed()` and `mark_removed()` are already called from all install/remove paths (pip, curl, npm, apt, stub, remove). Inserting the manifest call there guarantees coverage.

### Decision: agy module method

| Option | Tradeoff | Decision |
|--------|----------|----------|
| **`AGENT_METHOD="curl"` with Google install URL** | Official install path, matches pattern in other modules | **Chosen** |
| `AGENT_METHOD="binary"` with manual download | More fragile, Google may change URL structure | Rejected |
| `AGENT_METHOD="pip"` with package | `agy` is not a Python package | Rejected |

**Rationale**: `agy`'s official install is `curl https://antigravity.google/cli/install.sh | bash`. The `curl` method already exists in `nexus-install.sh`.

## Data Flow

```
install_agent("agy")
  → source modules/agy/install.sh
    → install_via_curl("https://antigravity.google/cli/install.sh")
    → mark_installed("agy")
      → update_installed_manifest("agy", "install")  ← NEW
        → echo "agy" >> logs/installed.txt

list_agents()
  → read logs/installed.txt into associative array (manifest check)
  → for each agent:
      if agent in manifest && command -v AGENT_BINARY → INSTALADO (green)
      elif command -v AGENT_BINARY                    → EXTERNO (cyan)
      else                                            → NO INSTALADO (yellow)

remove_agent("agy")
  → source modules/agy/install.sh → mark_removed("agy")
    → update_installed_manifest("agy", "remove")  ← NEW
      → sed -i /^agy$/d logs/installed.txt
```

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `logs/installed.txt` | Create | Manifest — one agent name per line |
| `lib/nexus-install.sh` | Modify | Add `update_installed_manifest()`; call it from `mark_installed()` and `mark_removed()` |
| `core/nexus.sh` | Modify | `list_agents()`: three-state lookup via manifest+PATH; `install_agent()`/`remove_agent()`: manifest sync already covered via `mark_*` |
| `modules/agy/metadata.sh` | Create | `AGENT_METHOD="curl"`, `AGENT_BINARY="agy"`, `AGENT_URL="https://antigravity.google/cli/install.sh"`, tier 2 |
| `modules/agy/install.sh` | Create | Source lib, call `install_via_curl`, verify, `mark_installed` |
| `modules/agy/test.sh` | Create | `command -v agy` |
| `modules/agy/README.md` | Create | Basic agy module doc |
| `modules/antigravity/metadata.sh` | Modify | `AGENT_BINARY="agy"`, `AGENT_DESC` redirect to agy, `AGENT_METHOD="curl"`, `AGENT_URL` pointing to Google |
| `modules/antigravity/install.sh` | Modify | Replace manual instructions with `install_via_curl` for agy, then `mark_installed "antigravity"` |
| `modules/gemini-cli/install.sh` | Modify | Add deprecation banner with sunset date before install logic |
| `modules/gemini-cli/metadata.sh` | Modify | Optionally bump tier or add deprecation note to description |

## Interfaces / Contracts

```bash
# New function in lib/nexus-install.sh
# Adds or removes agent name from logs/installed.txt
# action: "install" | "remove"
update_installed_manifest() {
    local agent="$1"
    local action="$2"
    local manifest="${NEXUS_ROOT}/logs/installed.txt"
    mkdir -p "$(dirname "$manifest")"
    case "$action" in
        install)
            grep -Fx "$agent" "$manifest" 2>/dev/null || echo "$agent" >> "$manifest"
            ;;
        remove)
            sed -i "/^${agent}$/d" "$manifest" 2>/dev/null || true
            ;;
    esac
}
```

## Testing Strategy

| Layer | What to Test | Approach |
|-------|-------------|----------|
| Manual | `nxai list` shows EXTERNO for PATH-only agents (claude-code, mongodb, nerd-fonts) | Run `nxai list`, verify cyan EXTERNO entries |
| Manual | `nxai install agy` from official URL, verify INSTALADO | Run install, check manifest + list |
| Manual | `nxai install gemini-cli` shows deprecation banner | Run install, verify banner before npm install |
| Manual | Stale manifest entry (binary removed but manifest has entry) → NO INSTALADO | Remove binary, run list |

No shell test runner available — manual verification per `openspec/config.yaml`.

## Migration / Rollout

No migration required. `installed.txt` starts empty — existing nxai-tracked installs will appear as EXTERNO until re-installed. This is correct behavior: they were installed before tracking existed, so they are external to the manifest.

## Open Questions

None.
