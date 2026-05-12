#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PROJECT_PATH="${PROJECT_DIR}/KouKouLedger.xcodeproj"
SCHEME="KouKouLedger"

if ! xcodebuild -version >/dev/null 2>&1; then
    if [ -d "/Applications/Xcode.app/Contents/Developer" ]; then
        export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
    fi
fi

if ! xcodebuild -version >/dev/null 2>&1; then
    echo "error: xcodebuild is unavailable. Install Xcode or set DEVELOPER_DIR to an Xcode developer directory." >&2
    exit 1
fi

SIMULATOR_ID="$(
    xcrun simctl list devices available \
        | awk -F '[()]' '/^[[:space:]]+iPhone / { print $2; exit }'
)"

if [ -z "${SIMULATOR_ID}" ]; then
    echo "error: no available iPhone Simulator found. Install an iOS simulator runtime in Xcode." >&2
    exit 1
fi

cd "${PROJECT_DIR}"

xcodebuild \
    -project "${PROJECT_PATH}" \
    -scheme "${SCHEME}" \
    -configuration Debug \
    -destination "platform=iOS Simulator,id=${SIMULATOR_ID}" \
    clean build
