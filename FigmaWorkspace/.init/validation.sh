#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/figma-project-1865-1874/FigmaWorkspace"
cd "$WORKSPACE"
LOG=/tmp/figma_preview.log; : > "$LOG"
# Delegate to build
bash .init/build.sh >>/tmp/figma_build.log 2>&1 || (tail -n 200 /tmp/figma_build.log && exit 22)
# Ensure public exists for serve
mkdir -p public
if [ ! -f public/index.html ] && [ -d dist ]; then cp -a dist/* public/ 2>/dev/null || true; fi
# Choose serve binary
if [ -x ./node_modules/.bin/serve ]; then SERVE_BIN="./node_modules/.bin/serve"
elif command -v serve >/dev/null; then SERVE_BIN=$(command -v serve)
else echo "error: serve missing; run install" >&2; exit 15; fi
# Start server in background and record PID
"$SERVE_BIN" -s public -l 5000 >>"$LOG" 2>&1 &
SERV_PID=$!
# Trap ensures we only kill the specific PID if it is still running
trap 'if [ -n "${SERV_PID:-}" ] && kill -0 "$SERV_PID" 2>/dev/null; then kill "$SERV_PID" 2>/dev/null || true; fi; sleep 0.2; tail -n 200 "$LOG" 2>/dev/null || true' EXIT
# Readiness loop with backoff
READY=0; sleep_sec=0.5; for i in $(seq 1 40); do
  if curl -sSf http://127.0.0.1:5000/ >/dev/null 2>&1; then READY=1; break; fi
  sleep "$sleep_sec"
  sleep_sec=$(awk "BEGIN{printf '%.3f', $sleep_sec*1.2}")
done
if [ "$READY" -ne 1 ]; then echo "server failed to become ready" >&2; exit 16; fi
# Evidence: capture snippet and artifacts
curl -s http://127.0.0.1:5000/ | head -n5 > /tmp/figma_preview_response.txt || true
ls -la dist 2>/dev/null > /tmp/figma_build_artifacts.txt || true
echo "response_saved=/tmp/figma_preview_response.txt"
# Stop server safely
if kill -0 "$SERV_PID" 2>/dev/null; then kill "$SERV_PID" || true; fi
sleep 0.2
# Append last logs to artifacts
tail -n 200 "$LOG" > /tmp/figma_preview_tail.log 2>/dev/null || true
exit 0
