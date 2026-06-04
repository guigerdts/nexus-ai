#!/usr/bin/env python3
"""History — read agents.log entries.

Usage:
    from tui.history import read_entries
    entries = read_entries("/path/to/nexus_root")
"""

import os


def read_entries(nexus_root: str, max_lines: int = 20) -> list[dict]:
    """Read the last N entries from logs/agents.log.

    Expected format (pipe-separated):
        YYYY-MM-DD HH:MM:SS | ACTION | agent | [version]

    Returns a list of dicts with keys: date, action, agent, result.
    Newest entries first.  Returns an empty list if the file is missing
    or contains no parseable lines.
    """
    log_path = os.path.join(nexus_root, "logs", "agents.log")

    if not os.path.isfile(log_path):
        return []

    entries: list[dict] = []
    with open(log_path) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            parts = [p.strip() for p in line.split("|")]
            entry = {
                "date": parts[0] if len(parts) > 0 else "",
                "action": parts[1] if len(parts) > 1 else "",
                "agent": parts[2] if len(parts) > 2 else "",
                "result": parts[3] if len(parts) > 3 else "",
            }
            entries.append(entry)

    # Reverse so newest entry is first, then trim
    return list(reversed(entries))[:max_lines]
