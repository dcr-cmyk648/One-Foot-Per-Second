#!/bin/bash
set -euo pipefail

export LC_ALL=C
export LANG=C

OFPS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OFPS_GODOT_BIN="${GODOT_BIN:-/Applications/Godot.app/Contents/MacOS/Godot}"
OFPS_VERSION="$(/usr/bin/sed -n 's/^config\/version="\([^"]*\)"/\1/p' "${OFPS_ROOT}/project.godot")"
OFPS_TITLE="One Foot Per Second"
OFPS_WEB_BUILD_DIR="${OFPS_ROOT}/build/web"
OFPS_RELEASE_DIR="${OFPS_ROOT}/release/${OFPS_TITLE} v${OFPS_VERSION}"
OFPS_WEB_ARCHIVE="${OFPS_RELEASE_DIR}/${OFPS_TITLE} v${OFPS_VERSION} Browser.zip"
OFPS_TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/ofps-web-package.XXXXXX")"

# Generated exports live inside the repository but are not Godot resources.
/bin/mkdir -p "${OFPS_ROOT}/build" "${OFPS_ROOT}/release"
: > "${OFPS_ROOT}/build/.gdignore"
: > "${OFPS_ROOT}/release/.gdignore"

cleanup_ofps_web_package() {
  rm -rf "${OFPS_TEMP_DIR}"
}
trap cleanup_ofps_web_package EXIT

if [[ -z "${OFPS_VERSION}" ]]; then
  echo "Could not read the game version from project.godot." >&2
  exit 1
fi
if [[ ! -x "${OFPS_GODOT_BIN}" ]]; then
  echo "Godot was not found at: ${OFPS_GODOT_BIN}" >&2
  echo "Set GODOT_BIN to the Godot 4.7.1 executable and try again." >&2
  exit 1
fi

"${OFPS_ROOT}/scripts/install_desktop_export_templates.sh"

if [[ "${OFPS_SKIP_TESTS:-false}" != "true" ]]; then
  echo "Running shared gameplay regression tests..."
  "${OFPS_GODOT_BIN}" --headless --path "${OFPS_ROOT}" \
    --log-file "${OFPS_TEMP_DIR}/regression.log" \
    -s tests/test_runner.gd

  echo "Running shared progressive-interface tests..."
  "${OFPS_GODOT_BIN}" --headless --path "${OFPS_ROOT}" \
    --log-file "${OFPS_TEMP_DIR}/interface.log" \
    -s tests/ui_runner.gd -- --fresh

  echo "Running portrait browser-interface tests..."
  "${OFPS_GODOT_BIN}" --headless --path "${OFPS_ROOT}" \
    --log-file "${OFPS_TEMP_DIR}/mobile-interface.log" \
    -s tests/mobile_ui_runner.gd -- --fresh
fi

echo "Exporting the single-threaded Web build..."
rm -rf "${OFPS_WEB_BUILD_DIR}"
/bin/mkdir -p "${OFPS_WEB_BUILD_DIR}" "${OFPS_RELEASE_DIR}"
"${OFPS_GODOT_BIN}" --headless --path "${OFPS_ROOT}" \
  --log-file "${OFPS_TEMP_DIR}/export-web.log" \
  --export-release "Web" "${OFPS_WEB_BUILD_DIR}/index.html"

for OFPS_REQUIRED_FILE in \
  index.html index.js index.pck index.wasm \
  index.manifest.json index.offline.html index.service.worker.js; do
  if [[ ! -s "${OFPS_WEB_BUILD_DIR}/${OFPS_REQUIRED_FILE}" ]]; then
    echo "Web export is incomplete: ${OFPS_REQUIRED_FILE} is missing or empty." >&2
    exit 1
  fi
done

if ! /usr/bin/grep -q '"index\.wasm"' "${OFPS_WEB_BUILD_DIR}/index.html" \
    || ! /usr/bin/grep -q '"executable":"index"' "${OFPS_WEB_BUILD_DIR}/index.html"; then
  echo "Web launcher does not reference the exported WebAssembly module." >&2
  exit 1
fi
if ! /usr/bin/grep -q '"serviceWorker":"index\.service\.worker\.js"' "${OFPS_WEB_BUILD_DIR}/index.html" \
		|| ! /usr/bin/grep -q "const CACHE_VERSION = '" "${OFPS_WEB_BUILD_DIR}/index.service.worker.js" \
		|| ! /usr/bin/grep -q "msg === 'update'" "${OFPS_WEB_BUILD_DIR}/index.service.worker.js"; then
	echo "Web export is missing its versioned update worker." >&2
	exit 1
fi
if ! /usr/bin/grep -q 'apple-mobile-web-app-capable' "${OFPS_WEB_BUILD_DIR}/index.html" \
		|| ! /usr/bin/grep -q 'apple-mobile-web-app-title' "${OFPS_WEB_BUILD_DIR}/index.html" \
		|| ! /usr/bin/grep -q 'rel="apple-touch-icon"' "${OFPS_WEB_BUILD_DIR}/index.html" \
		|| ! /usr/bin/grep -q '"display":"standalone"' "${OFPS_WEB_BUILD_DIR}/index.manifest.json"; then
	echo "Web export is missing its iPhone Home Screen metadata." >&2
	exit 1
fi

/bin/cp "${OFPS_ROOT}/distribution/WEB-README.txt" "${OFPS_WEB_BUILD_DIR}/README.txt"
if [[ "${OFPS_SYNC_PAGES:-true}" == "true" ]]; then
  "${OFPS_ROOT}/scripts/sync_pages_build.sh"
fi
rm -f "${OFPS_WEB_ARCHIVE}" "${OFPS_WEB_ARCHIVE}.sha256.txt"
(
  cd "${OFPS_WEB_BUILD_DIR}"
  /usr/bin/zip -qry "${OFPS_WEB_ARCHIVE}" .
)
/usr/bin/unzip -tq "${OFPS_WEB_ARCHIVE}"
(
  cd "${OFPS_RELEASE_DIR}"
  /usr/bin/shasum -a 256 "$(basename "${OFPS_WEB_ARCHIVE}")" \
    > "$(basename "${OFPS_WEB_ARCHIVE}").sha256.txt"
)

echo
echo "Browser release complete:"
echo "${OFPS_WEB_ARCHIVE}"
/bin/ls -lh "${OFPS_WEB_BUILD_DIR}" "${OFPS_WEB_ARCHIVE}" "${OFPS_WEB_ARCHIVE}.sha256.txt"
