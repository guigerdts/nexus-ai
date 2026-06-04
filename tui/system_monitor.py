#!/usr/bin/env python3
"""System monitor — collect RAM, disk, env, and version info.

Usage:
    from tui.system_monitor import collect
    data = collect("/path/to/nexus_root")
"""

import os
import platform
import shutil
import subprocess


def _get_version(cmd: list[str]) -> str:
    """Run a --version command and return the first line of stdout."""
    try:
        result = subprocess.run(
            cmd, capture_output=True, text=True, timeout=5
        )
        return result.stdout.strip().split("\n")[0]
    except (FileNotFoundError, subprocess.TimeoutExpired, PermissionError):
        return "N/A"


def collect(nexus_root: str) -> dict:
    """Collect system metrics.

    Reads /proc/meminfo for RAM, shutil.disk_usage for storage,
    os.environ for NEXUS_ENV/NEXUS_ARCH, and subprocess for version info.

    Returns a dict suitable for the TUI monitor panel.
    """
    # ── RAM from /proc/meminfo ──────────────────────
    mem_total = 0
    mem_available = 0
    try:
        with open("/proc/meminfo") as f:
            for line in f:
                if line.startswith("MemTotal:"):
                    mem_total = int(line.split()[1]) // 1024  # kB -> MB
                elif line.startswith("MemAvailable:"):
                    mem_available = int(line.split()[1]) // 1024  # kB -> MB
    except (FileNotFoundError, PermissionError, ValueError):
        pass

    mem_used = mem_total - mem_available

    # ── Storage via shutil.disk_usage ───────────────
    try:
        usage = shutil.disk_usage(nexus_root)
        disk_total = usage.total // (1024**3)   # bytes -> GB
        disk_used = usage.used // (1024**3)
        disk_free = usage.free // (1024**3)
    except FileNotFoundError:
        disk_total = disk_used = disk_free = 0

    # ── Environment ─────────────────────────────────
    env = os.environ.get("NEXUS_ENV", "unknown")
    arch = os.environ.get("NEXUS_ARCH", platform.machine())

    # ── Version strings ─────────────────────────────
    python_ver = _get_version(["python3", "--version"])
    zsh_ver = _get_version(["zsh", "--version"])
    git_ver = _get_version(["git", "--version"])

    return {
        "ram_total": mem_total,
        "ram_used": mem_used,
        "ram_available": mem_available,
        "disk_total": disk_total,
        "disk_used": disk_used,
        "disk_free": disk_free,
        "env": env,
        "arch": arch,
        "python_version": python_ver,
        "zsh_version": zsh_ver,
        "git_version": git_ver,
    }
