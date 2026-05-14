#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> KouKouLedger verify"
"${SCRIPT_DIR}/build.sh"
"${SCRIPT_DIR}/test.sh"
echo "==> Verify succeeded"
