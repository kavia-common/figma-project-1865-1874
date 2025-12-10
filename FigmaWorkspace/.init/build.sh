#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/figma-project-1865-1874/FigmaWorkspace"
cd "$WORKSPACE"
: > /tmp/figma_build.log
# If there's a build script in package.json prefer npm run build
if [ -f package.json ] && grep -q '"build"' package.json; then
  if [ -x ./node_modules/.bin/npm ]; then
    npm run build >>/tmp/figma_build.log 2>&1 || (tail -n 200 /tmp/figma_build.log && exit 21)
  else
    npm run build >>/tmp/figma_build.log 2>&1 || (tail -n 200 /tmp/figma_build.log && exit 21)
  fi
else
  # fallback: ensure public exists and copy to dist if not present
  mkdir -p dist
  cp -a public/* dist/ 2>/dev/null || true
  echo "fallback: copied public -> dist" >>/tmp/figma_build.log
fi
ls -la dist >/tmp/figma_build_artifacts.txt 2>/dev/null || true
exit 0
