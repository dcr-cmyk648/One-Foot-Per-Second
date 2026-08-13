#!/bin/bash
set -euo pipefail

OFPS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OFPS_PAGES_DIR="${OFPS_ROOT}/web"
OFPS_TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/ofps-web-parity.XXXXXX")"

cleanup_ofps_web_parity() {
	rm -rf "${OFPS_TEMP_DIR}"
}
trap cleanup_ofps_web_parity EXIT

for OFPS_REQUIRED_FILE in \
	index.html index.js index.pck index.wasm \
	index.manifest.json index.offline.html index.service.worker.js .nojekyll \
	.gdignore \
	SOURCE-SHA256SUMS.txt BUILD-SHA256SUMS.txt; do
	if [[ ! -e "${OFPS_PAGES_DIR}/${OFPS_REQUIRED_FILE}" ]]; then
		echo "GitHub Pages build is incomplete: web/${OFPS_REQUIRED_FILE} is missing." >&2
		exit 1
	fi
done

"${OFPS_ROOT}/scripts/web_manifest.sh" \
	source "${OFPS_TEMP_DIR}/SOURCE-SHA256SUMS.txt"
"${OFPS_ROOT}/scripts/web_manifest.sh" \
	build "${OFPS_PAGES_DIR}" "${OFPS_TEMP_DIR}/BUILD-SHA256SUMS.txt"

if ! cmp -s \
	"${OFPS_PAGES_DIR}/SOURCE-SHA256SUMS.txt" \
	"${OFPS_TEMP_DIR}/SOURCE-SHA256SUMS.txt"; then
	echo "The committed browser build is stale relative to the shared Godot source." >&2
	diff -u \
		"${OFPS_PAGES_DIR}/SOURCE-SHA256SUMS.txt" \
		"${OFPS_TEMP_DIR}/SOURCE-SHA256SUMS.txt" || true
	exit 1
fi

if ! cmp -s \
	"${OFPS_PAGES_DIR}/BUILD-SHA256SUMS.txt" \
	"${OFPS_TEMP_DIR}/BUILD-SHA256SUMS.txt"; then
	echo "The committed browser artifact does not match its build manifest." >&2
	diff -u \
		"${OFPS_PAGES_DIR}/BUILD-SHA256SUMS.txt" \
		"${OFPS_TEMP_DIR}/BUILD-SHA256SUMS.txt" || true
	exit 1
fi

echo "PASS: GitHub Pages build matches the shared Godot source and artifact manifest."
