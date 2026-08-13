#!/bin/bash
set -euo pipefail

OFPS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OFPS_BUILD_DIR="${OFPS_ROOT}/build/web"
OFPS_PAGES_DIR="${OFPS_ROOT}/web"

for OFPS_REQUIRED_FILE in \
	index.html index.js index.pck index.wasm \
	index.manifest.json index.offline.html index.service.worker.js; do
	if [[ ! -s "${OFPS_BUILD_DIR}/${OFPS_REQUIRED_FILE}" ]]; then
		echo "Cannot stage GitHub Pages: build/web/${OFPS_REQUIRED_FILE} is missing." >&2
		exit 1
	fi
done

rm -rf "${OFPS_PAGES_DIR}"
/bin/mkdir -p "${OFPS_PAGES_DIR}"
/bin/cp -R "${OFPS_BUILD_DIR}/." "${OFPS_PAGES_DIR}/"
: > "${OFPS_PAGES_DIR}/.gdignore"
: > "${OFPS_PAGES_DIR}/.nojekyll"

"${OFPS_ROOT}/scripts/web_manifest.sh" \
	source "${OFPS_PAGES_DIR}/SOURCE-SHA256SUMS.txt"
"${OFPS_ROOT}/scripts/web_manifest.sh" \
	build "${OFPS_PAGES_DIR}" "${OFPS_PAGES_DIR}/BUILD-SHA256SUMS.txt"

echo "Staged the verified GitHub Pages site in ${OFPS_PAGES_DIR}."
