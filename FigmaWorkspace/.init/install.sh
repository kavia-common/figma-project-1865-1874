#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/figma-project-1865-1874/FigmaWorkspace"
cd "$WORKSPACE"
# Not installing global tools; rely on container-provided node/npm/yarn
: > /tmp/figma_install.log
# If package.json exists, install local deps quietly
if [ -f package.json ]; then
  (npm i --no-audit --no-fund --omit=optional) >>/tmp/figma_install.log 2>&1 || (cat /tmp/figma_install.log && exit 20)
else
  echo "no package.json, skipping npm install" >>/tmp/figma_install.log
fi
# Ensure serve available: do not install globally, warn if missing
if [ -x ./node_modules/.bin/serve ] || command -v serve >/dev/null; then :; else
  echo "warning: 'serve' not found locally or globally; start/validation may fail" >>/tmp/figma_install.log
fi
exit 0
