#!/usr/bin/env python3
"""Agents panel — load agent metadata and check installation status.

Usage:
    from tui.agents_panel import load_agents
    agents = load_agents("/path/to/nexus_root")
"""

import glob
import os
import re
import shutil


def _which(binary: str) -> bool:
    """Check if binary exists in PATH, same as shell's command -v.

    Usa os.environ.get('PATH') explícitamente para incluir paths
    de Termux y otros entornos que shutil.which puede no resolver.
    """
    path_dirs = os.environ.get("PATH", "").split(":")
    for d in path_dirs:
        if not d:
            continue
        candidate = os.path.join(d, binary)
        if os.path.isfile(candidate) and os.access(candidate, os.X_OK):
            return True
    return False


def load_agents(nexus_root: str) -> list[dict]:
    """Load agent metadata from modules/*/metadata.sh.

    For each agent, checks whether the declared binary is on PATH
    via shutil.which() and sets the ``installed`` key accordingly.

    Returns a list of dicts with keys:
        name, tier, desc, binary, method, package, installed
    """
    agents: list[dict] = []
    pattern = os.path.join(nexus_root, "modules", "*", "metadata.sh")

    for meta_path in sorted(glob.glob(pattern)):
        data: dict = {
            "name": "unknown",
            "tier": 0,
            "desc": "",
            "binary": "",
            "method": "unknown",
            "package": "",
            "installed": False,
        }

        try:
            with open(meta_path) as f:
                content = f.read()
        except (FileNotFoundError, PermissionError):
            continue

        # Parse export VAR="val" lines (handles quoted and unquoted values)
        for match in re.finditer(
            r'export\s+(\w+)=["\']?([^"\'\n]+)["\']?', content
        ):
            var = match.group(1)
            val = match.group(2)
            if var == "AGENT_NAME":
                data["name"] = val
            elif var == "AGENT_TIER":
                try:
                    data["tier"] = int(val)
                except ValueError:
                    data["tier"] = 0
            elif var == "AGENT_DESC":
                data["desc"] = val
            elif var == "AGENT_BINARY":
                data["binary"] = val
            elif var == "AGENT_METHOD":
                data["method"] = val
            elif var == "AGENT_PACKAGE":
                data["package"] = val

        # Check installation status via explicit PATH search (compatible con
        # command -v del CLI, incluye Termux y entornos con PATH dinámico)
        binary = data.get("binary", "")
        if binary:
            data["installed"] = _which(binary)

        agents.append(data)

    return agents
