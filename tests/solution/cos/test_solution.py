"""Copyright 2026 Canonical Ltd.
See LICENSE file for licensing details.

Smoke test for COS.

Loads every scenario under tests/solution/features/; see
tests/solution/conftest.py for step definitions and tag filtering.
"""

from pytest_bdd import scenarios

scenarios("../features")
