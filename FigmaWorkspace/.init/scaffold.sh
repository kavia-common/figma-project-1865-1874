#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/figma-project-1865-1874/FigmaWorkspace"
cd "$WORKSPACE"
# Minimal package.json if missing
if [ ! -f package.json ]; then
  cat > package.json <<'JSON'
{
  "name":"figma-preview",
  "private":true,
  "scripts":{
    "build":"echo build: no-op",
    "start":"serve -s public -l 5000"
  }
}
JSON
else
  # do not overwrite; create generated copy only if needed
  if ! grep -q 'serve -s public -l 5000' package.json 2>/dev/null; then
    cp package.json package.json.generated
  fi
fi
# Ensure public/index.html exists
mkdir -p public
if [ ! -f public/index.html ]; then
  cat > public/index.html <<'HTML'
<!doctype html><meta charset=utf-8><title>FigmaWorkspace Preview</title><h1>FigmaWorkspace Preview</h1>
HTML
fi
exit 0
