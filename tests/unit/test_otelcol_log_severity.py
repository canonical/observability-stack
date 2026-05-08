#!/usr/bin/env python3
# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.
"""Unit tests for parsing otelcol log severity."""

import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).parent.parent / "integration"))
from helpers import _LOG_LEVEL_RE, _no_errors_in_otelcol_logs

# Pebble-prefixed log lines (as returned by `pebble logs`)
PEBBLE_INFO = "2026-04-22T12:00:54.179Z [otelcol] 2026-04-22T12:00:54.179Z\tinfo\tmemorylimiter@v0.130.1/memorylimiter.go:171\tMemory usage after GC."
PEBBLE_WARN = "2026-04-22T12:08:55.177Z [otelcol] 2026-04-22T12:08:55.177Z\twarn\tmemorylimiter@v0.130.1/memorylimiter.go:196\tMemory usage is above soft limit."
PEBBLE_ERROR = "2026-04-22T12:08:54.309Z [otelcol] 2026-04-22T12:08:54.309Z\terror\tadapter/receiver.go:61\tConsumeLogs() failed"
NOT_A_LOG_LINE = "some random text that is not a log line"


@pytest.mark.parametrize(
    "line,expected_level",
    [
        (PEBBLE_INFO, "info"),
        (PEBBLE_WARN, "warn"),
        (PEBBLE_ERROR, "error"),
    ],
)
def test_log_level_re_extracts_level(line, expected_level):
    m = _LOG_LEVEL_RE.match(line)
    assert m is not None, f"regex did not match: {line!r}"
    level = m.group(1) or m.group(2)
    assert level == expected_level


def test_log_level_re_no_match_on_non_log_line():
    assert _LOG_LEVEL_RE.match(NOT_A_LOG_LINE) is None


@pytest.mark.parametrize(
    "stdout,expect_error",
    [
        ("\n".join([PEBBLE_INFO, PEBBLE_WARN, PEBBLE_ERROR]), True),
        ("\n".join([PEBBLE_INFO, PEBBLE_WARN]), True),
        ("\n".join([PEBBLE_INFO, PEBBLE_INFO]), False),
        (PEBBLE_INFO, False),
    ],
    ids=["error+warn+info", "warn+info", "info only", "single info"],
)
def test_no_errors_in_otelcol_logs(stdout, expect_error):
    if expect_error:
        with pytest.raises(AssertionError):
            _no_errors_in_otelcol_logs(stdout)
    else:
        _no_errors_in_otelcol_logs(stdout)
