# Design: v0.7 — Agent Registry Restructure

## Technical Approach

Six independent phases applied sequentially, each verifiable before proceeding. The registry auto-discovers modules from `modules/*/` — no registry code changes needed. Guide files are hardcoded and must be manually rewritten in lockstep.

| Phase | Scope | Verification Gate |
|-------|-------|-------------------|
| 1 | Remove aider/, goose/; rename openclou/→openclaude/; fix 8 metadata.sh | `nxai list` shows no aider/goose, openclaude exists |
| 2 | 4 new npm modules (gemini-cli, typescript, pm2, nodemon) | Each module dir exists with 4 files |
| 3 | 14 new pkg modules | Each installs via `pkg install` |
| 4 | 4 special modules (ollama, oh-my-zsh, nvchad, n8n) | Each installs via curl/git/npm |
| 5 | 7 new stubs + 4 updated stubs | Each prints clear manual instructions |
| 6 | Rewrite guides, bump VERSION, update README/motd | `nxai guide`, `nxai help` show 9 categories |

39 modules total (12 existing − 2 removed + 1 renamed + 29 new).

## Architecture Decisions

| Option | Tradeoff | Decision |
|--------|----------|----------|
| Dynamic guide from registry vs hardcoded | Dynamic = auto-sync but complex; Hardcoded = duplication risk but simple, allows dual-category display | **Hardcoded guides** — sgpt needs to appear in both `ai` AND `shell`; AGENT_CATEGORY is single-valued |
| Stub vs Real criteria | Stub = broader coverage but no install; Real = works on ARM64 but fewer modules | **Real = pkg/npm/curl binary proven on ARM64, no compilation**. Everything else = stub |
| Module generator script | Would reduce manual work but adds infra scope | **Out of scope** — 29 new modules created via template copy-paste |
| Single PR vs 6-phase chained | Single = simpler but >400 lines; Chained = cleaner review | **6 phases** — each independently verifiable, each under ~80 file ops |
| openclou→openclaude breaking | Rename breaks `nxai install openclou` | **Accepted** — documented in changelog; `openclaude` is the correct name |

## Module Template

```
modules/<name>/
├── metadata.sh    # 8 exports: NAME, VERSION, DESC, URL, TIER, CATEGORY, METHOD, BINARY
├── install.sh     # REAL: check_dependency + install_via_* + verify; STUB: cat URL + exit 0
├── test.sh        # command -v <binary>
└── README.md      # Termux + proot-Ubuntu instructions
```

**REAL install pattern** (npm example): source `nexus-install.sh` → `check_dependency` → `install_via_*` → verify binary → `mark_installed`.

**STUB pattern**: source `nexus-install.sh` → cat box with URL and manual steps → `log_warn` → `exit 0`.

## File Changes

| Phase | Files | Action |
|-------|-------|--------|
| 1 | `modules/aider/*`, `modules/goose/*` | Delete |
| 1 | `modules/openclou/*` → `modules/openclaude/*` | Rename (mv) |
| 1 | 8 modules' `metadata.sh` | Modify (category/tier/method/binary) |
| 2 | `modules/{gemini-cli,typescript,pm2,nodemon}/{metadata,install,test}.sh` + `README.md` | Create |
| 3 | `modules/{14-pkg-names}/{metadata,install,test}.sh` + `README.md` | Create |
| 4 | `modules/{ollama,oh-my-zsh,nvchad,n8n}/{metadata,install,test}.sh` + `README.md` | Create |
| 5 | 7 new stub dirs, 4 existing updated | Create / Modify |
| 6 | `lib/nexus-guide.sh` | Rewrite (9 categories) |
| 6 | `tui/guide.py` | Rewrite (9 categories) |
| 6 | `core/nexus.sh` lines 59-68, 529 | Modify (9 categories + "node") |
| 6 | `config/env.sh` | Bump NEXUS_VERSION to 0.7.0 |
| 6 | `VERSION` | 0.6.0 → 0.7.0 |
| 6 | `README.md` | Rewrite module table (39 entries) |
| 6 | `shell/motd.sh` | Remove aider tip |

## Testing Strategy

| Layer | What | How |
|-------|------|-----|
| Per-module | Binary exists | `test.sh` runs `command -v <binary>` — exit 0 if found |
| Guide | 9 categories display | Manual visual: `nxai guide` + `nxai guide --interactive` + `nxai help` |
| Registry | Module discovery | `nxai list` counts 39 dirs, `nxai status` shows correct metadata |
| Install | REAL modules | Spot-check: `nxai install <module>` on Termux ARM64 for each method (npm/pkg/curl) |

No test runner available (per `openspec/config.yaml`). No CI/CD. Each phase's verification gate is manual.

## Migration / Rollout

Phases MUST be applied in order — later phases reference guides updated in phase 6, stubs depend on phase 5 metadata. Each phase is independently verifiable and reversible (`git add && git commit` per phase allows `git revert <phase>`).

Breaking change: `openclou` → `openclaude`. Users who installed via `nxai install openclou` must migrate. Version bump signals the breaking change per semver (0.6.0 → 0.7.0).

No data migration required. No feature flags.

## Open Questions

None — spec is complete and unambiguous.
