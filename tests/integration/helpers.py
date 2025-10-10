#!/usr/bin/env python3
# Copyright 2025 Canonical Ltd.
# See LICENSE file for licensing details.
"""Helper functions for integration tests."""

import logging
import shlex
import subprocess

logger = logging.getLogger(__name__)


def run_live(cmd):
    proc = subprocess.Popen(
        shlex.split(cmd),
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        bufsize=1,
    )
    lines = []
    try:
        for line in proc.stdout:
            print(line, end="", flush=True)
            lines.append(line)
    finally:
        proc.wait()
    assert proc.returncode == 0
