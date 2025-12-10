#!/usr/bin/env bash
set -euo pipefail
# Start preview (foreground) - prefers local serve binary and fails clearly if missing
WORKSPACE="/home/kavia/workspace/code-generation/figma-project-1865-1874/FigmaWorkspace"
cd "$WORKSPACE"
# Prefer project-local serve; if missing, provide clear actionable error
LOCAL_SERVE="./node_modules/.bin/serve"
if [ -x "$LOCAL_SERVE" ]; then
  exec "$LOCAL_SERVE" -s public -l 5000
else
  echo "error: local 'serve' binary not found at $LOCAL_SERVE." >&2
  echo "Action: run the 'install' step to install project dependencies (e.g., in workspace run: npm install or yarn install)." >&2
  echo "If you prefer a temporary global fallback, install 'serve' globally: npm i -g serve (not recommended for reproducible builds)." >&2
  exit 17
fi
