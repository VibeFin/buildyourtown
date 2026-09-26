#!/usr/bin/env bash
# Screenshot the running app at exactly $CAPTURE_URL (desktop + mobile) into
# $CAPTURE_DIR. Leaves the app running. Exit 75 = transient
# navigation/browser infrastructure failure, 1 = script/rendering defect.
set -euo pipefail
cd "$(dirname "$0")"
/usr/bin/time -p test -n "${CAPTURE_URL:?Set CAPTURE_URL to the exact URL to capture.}"
/usr/bin/time -p test -n "${CAPTURE_DIR:?Set CAPTURE_DIR to the screenshot output directory.}"
/usr/bin/time -p test -n "${RUNTIME_DIR:?Set RUNTIME_DIR to the runtime scripts directory.}"
/usr/bin/time -p mkdir -p "$CAPTURE_DIR"
/usr/bin/time -p node --version
/usr/bin/time -p node "$RUNTIME_DIR/scripts/default-capture.mjs"
/usr/bin/time -p ls -la "$CAPTURE_DIR/final-desktop.png" "$CAPTURE_DIR/final-mobile.png"
