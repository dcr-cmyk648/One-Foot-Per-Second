#!/bin/bash
set -euo pipefail

OFPS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OFPS_WEB_DIR="${OFPS_ROOT}/build/web"
OFPS_WEB_PORT="${OFPS_WEB_PORT:-8001}"

if [[ ! -s "${OFPS_WEB_DIR}/index.html" ]]; then
  echo "No browser build exists yet. Run scripts/package_web.sh first." >&2
  exit 1
fi

echo "Serving No Hitter at http://127.0.0.1:${OFPS_WEB_PORT}/"
exec /usr/bin/python3 -m http.server "${OFPS_WEB_PORT}" \
  --bind 127.0.0.1 \
  --directory "${OFPS_WEB_DIR}"
