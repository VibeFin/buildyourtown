#!/usr/bin/env bash
# Install dependencies, build the static site when needed, write the
# deployment-output.json pointer, and serve dist/ in the foreground.
set -euo pipefail
cd "$(dirname "$0")"
PROJECT_ROOT="$(/usr/bin/time -p pwd)"
PORT="${PORT:-3000}"
export PORT
WEB_DIR="${OPENCODE_WEB_DIR:-/home/runner/work/_temp/omgithub-web}"
/usr/bin/time -p test -f package.json
# Repair leftovers a root-run tool (e.g. docker) may have left behind: npm
# running as this user cannot write into a root-owned node_modules (EACCES).
if /usr/bin/time -p test ! -w node_modules 2>/dev/null; then
  /usr/bin/time -p rm -rf node_modules
fi
# Install only when the vite binary is missing.
if /usr/bin/time -p test ! -x node_modules/vite/bin/vite.js; then
  if /usr/bin/time -p test -f package-lock.json; then
    /usr/bin/time -p npm ci --no-audit --no-fund
  else
    /usr/bin/time -p npm install --no-audit --no-fund
  fi
fi
/usr/bin/time -p test -x node_modules/vite/bin/vite.js
# Rebuild when dist is missing or any source is newer than the last build.
NEED_BUILD=1
if /usr/bin/time -p test -f dist/index.html; then
  if /usr/bin/time -p test -z "$(/usr/bin/time -p find src public index.html package.json vite.config.ts -newer dist/index.html -print -quit 2>/dev/null)"; then
    NEED_BUILD=0
  fi
fi
if [ "$NEED_BUILD" = 1 ]; then
  /usr/bin/time -p node node_modules/vite/bin/vite.js build
fi
/usr/bin/time -p test -f dist/index.html
/usr/bin/time -p mkdir -p "$WEB_DIR"
OUT="$WEB_DIR/deployment-output.json" PROJECT="$PROJECT_ROOT" DIR="$PROJECT_ROOT/dist" /usr/bin/time -p node -e 'require("fs").writeFileSync(process.env.OUT, JSON.stringify({ project: process.env.PROJECT, directory: process.env.DIR }))'
/usr/bin/time -p cat "$WEB_DIR/deployment-output.json"
/usr/bin/time -p echo "Serving $PROJECT_ROOT/dist on port $PORT"
exec /usr/bin/time -p node node_modules/vite/bin/vite.js preview --host 0.0.0.0 --port "$PORT" --strictPort
