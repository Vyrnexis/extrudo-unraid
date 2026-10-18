#!/usr/bin/env bash
set -euo pipefail

container="${1:-extrudo-test}"
base_url="http://127.0.0.1:8780"
headers="$(mktemp)"
body="$(mktemp)"
trap 'rm -f "$headers" "$body"' EXIT

ready=false
for _ in {1..30}; do
  if curl -fsS -D "$headers" -o "$body" "$base_url/"; then
    ready=true
    break
  fi
  sleep 1
done

test "$ready" = true
grep -qi '<title>Extrudo' "$body"
grep -qi '^Cross-Origin-Opener-Policy: same-origin' "$headers"
grep -qi '^Cross-Origin-Embedder-Policy: require-corp' "$headers"
grep -qi "^Content-Security-Policy: .*wasm-unsafe-eval" "$headers"
grep -qi '^Cache-Control: no-cache' "$headers"

wasm_file="$(docker exec "$container" find /usr/share/nginx/html/assets -name '*.wasm' -print -quit)"
test -n "$wasm_file"
wasm_url="${wasm_file#/usr/share/nginx/html}"
curl -fsSI "$base_url$wasm_url" | grep -qi '^Content-Type: application/wasm'
curl -fsSI "$base_url$wasm_url" | grep -qi '^Cache-Control: public, max-age=31536000, immutable'

curl -fsSI "$base_url/sw.js" | grep -qi '^Cache-Control: no-cache'
