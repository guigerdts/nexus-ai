# Tasks: NEXUS AI CLI Restructure (v0.8)

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | ~1,600 across 4 PRs |
| 400-line budget risk | Low (per-PR within 800-line D2 budget) |
| Chained PRs recommended | Yes |
| Suggested split | PR 1 → PR 2 → PR 3 → PR 4 |
| Delivery strategy | auto-chain |
| Chain strategy | feature-branch-chain |

Decision needed before apply: No
Chained PRs recommended: Yes
Chain strategy: feature-branch-chain
400-line budget risk: Low

### Suggested Work Units

| Unit | Goal | Likely PR | Notes |
|------|------|-----------|-------|
| 1 | Category config + AGENT_FLAG | PR 1 | Base = feature-branch; 50 metadata files |
| 2 | CLI parser rewrite + backward compat | PR 2 | Base = PR 1 branch; resolve_args + routing |
| 3 | Category list table | PR 3 | Base = PR 2 branch; 3-state with flag column |
| 4 | Module lifecycle + glibc + stubs | PR 4 | Base = PR 3 branch; 50 lifecycle pairs + 35 stubs |

## Phase 1 — Category Config + AGENT_FLAG (PR 1)

- [x] 1.1 Create `config/categories.sh` with CATEGORIES[cat]="agent list", CATEGORY_ORDER[], FLAG_TO_AGENT[], AGENT_TO_FLAG[]
- [x] 1.2 Add AGENT_FLAG to all 50 modules' metadata.sh (one short unique flag per agent)
- [x] 1.3 Source categories.sh in `config/agents.registry.sh` after agent load
- [x] 1.4 Source categories.sh in `core/nexus.sh` at startup (after registry)
- [x] 1.5 Add `category_manifest_list()`, `category_manifest_has()`, and `agent_get_category()` to `lib/nexus-install.sh` — read metadata.sh for category (NOT installed.txt)

## Phase 2 — CLI Parser Shim + Rewrite (PR 2)

- [x] 2.1 Add `resolve_args()` in core/nexus.sh before case dispatch: detect category mode vs bare name
- [x] 2.2 Implement flag parsing: collect `--tool` args, resolve via FLAG_TO_AGENT[]
- [x] 2.3 Rewrite install_agent() for dual dispatch: bare name → existing path; category+flags → batch per flag
- [x] 2.4 Add `uninstall` alias in case dispatch (maps to remove_agent)
- [x] 2.5 Add `update` subcommand routing: `nxai update <category> [--flags]`
- [x] 2.6 Keep old `nxai install opencode` working via fallthrough in resolve_args()

## Phase 3 — Category List Table (PR 3)

- [x] 3.1 Rewrite list_agents(): accept optional category arg, filter AGENT_ORDER by category
- [x] 3.2 Add Flag column to table display via AGENT_TO_FLAG[]
- [x] 3.3 Print table with printf: columns Herramienta, Flag, Comando, Estado
- [x] 3.4 `nxai list <category>` shows only that category's agents
- [x] 3.5 `nxai list` (no arg) shows available categories summary

## Phase 4 — Module Lifecycle + GLIBC + Stubs (PR 4)

- [x] 4.1 Add `install_via_binary()` to lib/nexus-install.sh: download tarball, extract, create glibc wrapper, set PATH — only for opencode, agy, claude-code
- [x] 4.2 Add `uninstall_via_binary()` to lib/nexus-install.sh: remove wrapper, binary dir, PATH entry
- [x] 4.3 Create uninstall.sh for all 50 existing modules (source nexus-install.sh, call method uninstall, mark_removed)
- [x] 4.4 Create update.sh for all 50 existing modules (check version, re-install if newer, exit 0)
- [x] 4.5 Add per-module update routing in lib/nexus-update.sh (iterate AGENT_ORDER, call module/update.sh)
- [x] 4.6 Create 35+ stub module directories with metadata.sh (AGENT_FLAG, AGENT_CATEGORY, AGENT_METHOD=stub)
- [x] 4.7 Add `batch_install_category()` to lib/nexus-install.sh for `nxai install <cat>` with no flags
