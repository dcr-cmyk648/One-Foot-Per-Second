#!/bin/bash
set -euo pipefail

OFPS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OFPS_APP="${OFPS_ROOT}/build/No Hitter.app"

if [[ -d "${OFPS_APP}" ]]; then
  exec /usr/bin/open -n "${OFPS_APP}"
fi

if [[ -d "/Applications/Godot.app" ]]; then
  exec /usr/bin/open -n "/Applications/Godot.app" --args --path "${OFPS_ROOT}"
fi

echo "No native build or Godot installation was found." >&2
echo "Run ./scripts/package_all_platforms.sh once, then use Open Game again." >&2
exit 1
