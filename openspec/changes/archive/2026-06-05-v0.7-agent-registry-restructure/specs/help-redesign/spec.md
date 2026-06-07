# Delta for help-redesign

## MODIFIED Requirements

### Requirement: Module targets by category

The "Module Targets:" section MUST list tools grouped by their 9 categories (ai, editor, shell, tools, language, db, node, ui, automation).
(Previously: 8 categories, no node)

#### Scenario: All categories represented

- GIVEN all agent metadata.sh files have AGENT_CATEGORY set
- WHEN `nxai help` runs
- THEN each of the 9 categories MUST appear with its tools
- AND categories with zero tools MUST show as empty
