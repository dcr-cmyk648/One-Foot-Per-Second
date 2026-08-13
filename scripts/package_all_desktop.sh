#!/bin/bash
set -euo pipefail

# macOS does not provide the C.UTF-8 locale used by some shell environments.
# The portable C locale keeps archive tools quiet and filenames deterministic.
export LC_ALL=C
export LANG=C

OFPS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OFPS_GODOT_BIN="${GODOT_BIN:-/Applications/Godot.app/Contents/MacOS/Godot}"
OFPS_VERSION="$(/usr/bin/sed -n 's/^config\/version="\([^"]*\)"/\1/p' "${OFPS_ROOT}/project.godot")"
OFPS_TITLE="One Foot Per Second"

# Generated exports live inside the repository but are not Godot resources.
# Keep later headless runs from scanning an earlier build back into the project.
/bin/mkdir -p "${OFPS_ROOT}/build" "${OFPS_ROOT}/release"
: > "${OFPS_ROOT}/build/.gdignore"
: > "${OFPS_ROOT}/release/.gdignore"

if [[ -z "${OFPS_VERSION}" ]]; then
  echo "Could not read the game version from project.godot." >&2
  exit 1
fi
if [[ ! -x "${OFPS_GODOT_BIN}" ]]; then
  echo "Godot was not found at: ${OFPS_GODOT_BIN}" >&2
  echo "Set GODOT_BIN to the Godot 4.7.1 executable and try again." >&2
  exit 1
fi
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "The complete packager currently requires macOS because it creates and verifies the DMG." >&2
  exit 1
fi

"${OFPS_ROOT}/scripts/install_desktop_export_templates.sh"

OFPS_BUILD_DIR="${OFPS_ROOT}/build"
OFPS_RELEASE_ROOT="${OFPS_ROOT}/release"
OFPS_RELEASE_DIR="${OFPS_RELEASE_ROOT}/${OFPS_TITLE} v${OFPS_VERSION}"
OFPS_TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/ofps-package.XXXXXX")"

cleanup_ofps_package() {
  rm -rf "${OFPS_TEMP_DIR}"
}
trap cleanup_ofps_package EXIT

OFPS_MAC_APP="${OFPS_BUILD_DIR}/${OFPS_TITLE}.app"
OFPS_WIN_X64_EXE="${OFPS_BUILD_DIR}/windows-x86_64/${OFPS_TITLE}.exe"
OFPS_WIN_ARM_EXE="${OFPS_BUILD_DIR}/windows-arm64/${OFPS_TITLE}.exe"
OFPS_LINUX_X64_BIN="${OFPS_BUILD_DIR}/linux-x86_64/${OFPS_TITLE}.x86_64"
OFPS_LINUX_ARM_BIN="${OFPS_BUILD_DIR}/linux-arm64/${OFPS_TITLE}.arm64"

OFPS_MAC_DMG_NAME="${OFPS_TITLE} v${OFPS_VERSION} macOS Universal.dmg"
OFPS_WIN_X64_NAME="${OFPS_TITLE} v${OFPS_VERSION} Windows x86_64.zip"
OFPS_WIN_ARM_NAME="${OFPS_TITLE} v${OFPS_VERSION} Windows ARM64.zip"
OFPS_LINUX_X64_NAME="${OFPS_TITLE} v${OFPS_VERSION} Linux x86_64.tar.gz"
OFPS_LINUX_ARM_NAME="${OFPS_TITLE} v${OFPS_VERSION} Linux ARM64.tar.gz"
OFPS_SOURCE_NAME="${OFPS_TITLE} v${OFPS_VERSION} Source.zip"
OFPS_ALL_NAME="${OFPS_TITLE} v${OFPS_VERSION} All Desktop Platforms.zip"

echo "Running regression tests..."
"${OFPS_GODOT_BIN}" --headless --path "${OFPS_ROOT}" \
  --log-file "${OFPS_TEMP_DIR}/regression.log" \
  -s tests/test_runner.gd

echo "Running progressive-interface and tab-layout tests..."
"${OFPS_GODOT_BIN}" --headless --path "${OFPS_ROOT}" \
  --log-file "${OFPS_TEMP_DIR}/interface.log" \
  -s tests/ui_runner.gd -- --fresh

echo "Running portrait browser-interface tests..."
"${OFPS_GODOT_BIN}" --headless --path "${OFPS_ROOT}" \
  --log-file "${OFPS_TEMP_DIR}/mobile-interface.log" \
  -s tests/mobile_ui_runner.gd -- --fresh

echo "Exporting macOS Universal..."
"${OFPS_GODOT_BIN}" --headless --path "${OFPS_ROOT}" \
  --log-file "${OFPS_TEMP_DIR}/export-macos.log" \
  --export-release "macOS" "${OFPS_MAC_APP}"

echo "Exporting Windows x86_64..."
/bin/mkdir -p "$(dirname "${OFPS_WIN_X64_EXE}")"
"${OFPS_GODOT_BIN}" --headless --path "${OFPS_ROOT}" \
  --log-file "${OFPS_TEMP_DIR}/export-windows-x86_64.log" \
  --export-release "Windows x86_64" "${OFPS_WIN_X64_EXE}"

echo "Exporting Windows ARM64..."
/bin/mkdir -p "$(dirname "${OFPS_WIN_ARM_EXE}")"
"${OFPS_GODOT_BIN}" --headless --path "${OFPS_ROOT}" \
  --log-file "${OFPS_TEMP_DIR}/export-windows-arm64.log" \
  --export-release "Windows ARM64" "${OFPS_WIN_ARM_EXE}"

echo "Exporting Linux x86_64..."
/bin/mkdir -p "$(dirname "${OFPS_LINUX_X64_BIN}")"
"${OFPS_GODOT_BIN}" --headless --path "${OFPS_ROOT}" \
  --log-file "${OFPS_TEMP_DIR}/export-linux-x86_64.log" \
  --export-release "Linux x86_64" "${OFPS_LINUX_X64_BIN}"
/bin/chmod +x "${OFPS_LINUX_X64_BIN}"

echo "Exporting Linux ARM64..."
/bin/mkdir -p "$(dirname "${OFPS_LINUX_ARM_BIN}")"
"${OFPS_GODOT_BIN}" --headless --path "${OFPS_ROOT}" \
  --log-file "${OFPS_TEMP_DIR}/export-linux-arm64.log" \
  --export-release "Linux ARM64" "${OFPS_LINUX_ARM_BIN}"
/bin/chmod +x "${OFPS_LINUX_ARM_BIN}"

echo "Verifying exported binaries..."
/usr/bin/codesign --verify --deep --strict --verbose=2 "${OFPS_MAC_APP}"
OFPS_MAC_ARCHS="$(/usr/bin/lipo -archs "${OFPS_MAC_APP}/Contents/MacOS/${OFPS_TITLE}")"
if [[ " ${OFPS_MAC_ARCHS} " != *" arm64 "* || " ${OFPS_MAC_ARCHS} " != *" x86_64 "* ]]; then
  echo "The macOS export is not Universal: ${OFPS_MAC_ARCHS}" >&2
  exit 1
fi

OFPS_WIN_X64_TYPE="$(/usr/bin/file "${OFPS_WIN_X64_EXE}")"
OFPS_WIN_ARM_TYPE="$(/usr/bin/file "${OFPS_WIN_ARM_EXE}")"
OFPS_LINUX_X64_TYPE="$(/usr/bin/file "${OFPS_LINUX_X64_BIN}")"
OFPS_LINUX_ARM_TYPE="$(/usr/bin/file "${OFPS_LINUX_ARM_BIN}")"
[[ "${OFPS_WIN_X64_TYPE}" == *"PE32+ executable"* && "${OFPS_WIN_X64_TYPE}" == *"x86-64"* ]]
[[ "${OFPS_WIN_ARM_TYPE}" == *"PE32+ executable"* && "${OFPS_WIN_ARM_TYPE}" == *"Aarch64"* ]]
[[ "${OFPS_LINUX_X64_TYPE}" == *"ELF 64-bit"* && "${OFPS_LINUX_X64_TYPE}" == *"x86-64"* ]]
[[ "${OFPS_LINUX_ARM_TYPE}" == *"ELF 64-bit"* && "${OFPS_LINUX_ARM_TYPE}" == *"ARM aarch64"* ]]

"${OFPS_MAC_APP}/Contents/MacOS/${OFPS_TITLE}" --headless \
  --log-file "${OFPS_TEMP_DIR}/exported-macos-smoke.log" \
  --quit-after 180 -- --fresh

echo "Assembling release packages..."
rm -rf "${OFPS_RELEASE_DIR}"
/bin/mkdir -p "${OFPS_RELEASE_DIR}"

OFPS_DMG_STAGE="${OFPS_TEMP_DIR}/dmg"
/bin/mkdir -p "${OFPS_DMG_STAGE}"
/usr/bin/ditto "${OFPS_MAC_APP}" "${OFPS_DMG_STAGE}/${OFPS_TITLE}.app"
/bin/ln -s /Applications "${OFPS_DMG_STAGE}/Applications"
/usr/bin/hdiutil create -quiet -volname "${OFPS_TITLE}" \
  -srcfolder "${OFPS_DMG_STAGE}" -ov -format UDZO \
  "${OFPS_RELEASE_DIR}/${OFPS_MAC_DMG_NAME}"

OFPS_WIN_X64_STAGE="${OFPS_TEMP_DIR}/${OFPS_TITLE} v${OFPS_VERSION} Windows x86_64"
OFPS_WIN_ARM_STAGE="${OFPS_TEMP_DIR}/${OFPS_TITLE} v${OFPS_VERSION} Windows ARM64"
/bin/mkdir -p "${OFPS_WIN_X64_STAGE}" "${OFPS_WIN_ARM_STAGE}"
/bin/cp "${OFPS_WIN_X64_EXE}" "${OFPS_WIN_X64_STAGE}/${OFPS_TITLE}.exe"
/bin/cp "${OFPS_WIN_ARM_EXE}" "${OFPS_WIN_ARM_STAGE}/${OFPS_TITLE}.exe"
/bin/cp "${OFPS_ROOT}/distribution/README-FIRST.txt" "${OFPS_WIN_X64_STAGE}/INSTALL.txt"
/bin/cp "${OFPS_ROOT}/distribution/README-FIRST.txt" "${OFPS_WIN_ARM_STAGE}/INSTALL.txt"
/usr/bin/ditto -c -k --norsrc --noextattr --noqtn --keepParent \
  "${OFPS_WIN_X64_STAGE}" "${OFPS_RELEASE_DIR}/${OFPS_WIN_X64_NAME}"
/usr/bin/ditto -c -k --norsrc --noextattr --noqtn --keepParent \
  "${OFPS_WIN_ARM_STAGE}" "${OFPS_RELEASE_DIR}/${OFPS_WIN_ARM_NAME}"

OFPS_LINUX_X64_STAGE="${OFPS_TEMP_DIR}/${OFPS_TITLE} v${OFPS_VERSION} Linux x86_64"
OFPS_LINUX_ARM_STAGE="${OFPS_TEMP_DIR}/${OFPS_TITLE} v${OFPS_VERSION} Linux ARM64"
/bin/mkdir -p "${OFPS_LINUX_X64_STAGE}" "${OFPS_LINUX_ARM_STAGE}"
/bin/cp "${OFPS_LINUX_X64_BIN}" "${OFPS_LINUX_X64_STAGE}/${OFPS_TITLE}.x86_64"
/bin/cp "${OFPS_LINUX_ARM_BIN}" "${OFPS_LINUX_ARM_STAGE}/${OFPS_TITLE}.arm64"
/bin/chmod +x "${OFPS_LINUX_X64_STAGE}/${OFPS_TITLE}.x86_64"
/bin/chmod +x "${OFPS_LINUX_ARM_STAGE}/${OFPS_TITLE}.arm64"
/bin/cp "${OFPS_ROOT}/distribution/README-FIRST.txt" "${OFPS_LINUX_X64_STAGE}/INSTALL.txt"
/bin/cp "${OFPS_ROOT}/distribution/README-FIRST.txt" "${OFPS_LINUX_ARM_STAGE}/INSTALL.txt"
/usr/bin/tar -czf "${OFPS_RELEASE_DIR}/${OFPS_LINUX_X64_NAME}" \
  -C "${OFPS_TEMP_DIR}" "$(basename "${OFPS_LINUX_X64_STAGE}")"
/usr/bin/tar -czf "${OFPS_RELEASE_DIR}/${OFPS_LINUX_ARM_NAME}" \
  -C "${OFPS_TEMP_DIR}" "$(basename "${OFPS_LINUX_ARM_STAGE}")"

OFPS_SOURCE_STAGE="${OFPS_TEMP_DIR}/${OFPS_TITLE} v${OFPS_VERSION} Source"
/bin/mkdir -p "${OFPS_SOURCE_STAGE}"
/usr/bin/rsync -a \
  --exclude '.git/' \
  --exclude '.godot/' \
  --exclude 'build/' \
  --exclude 'release/' \
	--exclude 'sites-host/node_modules/' \
	--exclude 'sites-host/.vinext/' \
	--exclude 'sites-host/.wrangler/' \
	--exclude 'sites-host/dist/' \
	--exclude 'sites-host/public/game/' \
  --exclude 'SHA256SUMS.txt' \
  --exclude '*.log' \
  "${OFPS_ROOT}/" "${OFPS_SOURCE_STAGE}/"
/usr/bin/ditto -c -k --norsrc --noextattr --noqtn --keepParent \
  "${OFPS_SOURCE_STAGE}" "${OFPS_RELEASE_DIR}/${OFPS_SOURCE_NAME}"

/bin/cp "${OFPS_ROOT}/distribution/README-FIRST.txt" "${OFPS_RELEASE_DIR}/README-FIRST.txt"
/bin/cp "${OFPS_ROOT}/distribution/release-manifest.json" "${OFPS_RELEASE_DIR}/release-manifest.json"

(
  cd "${OFPS_RELEASE_DIR}"
  /usr/bin/shasum -a 256 \
    "${OFPS_MAC_DMG_NAME}" \
    "${OFPS_WIN_X64_NAME}" \
    "${OFPS_WIN_ARM_NAME}" \
    "${OFPS_LINUX_X64_NAME}" \
    "${OFPS_LINUX_ARM_NAME}" \
    "${OFPS_SOURCE_NAME}" \
    > SHA256SUMS.txt
)

echo "Validating release archives..."
/usr/bin/hdiutil verify "${OFPS_RELEASE_DIR}/${OFPS_MAC_DMG_NAME}" >/dev/null
/usr/bin/unzip -tq "${OFPS_RELEASE_DIR}/${OFPS_WIN_X64_NAME}"
/usr/bin/unzip -tq "${OFPS_RELEASE_DIR}/${OFPS_WIN_ARM_NAME}"
/usr/bin/tar -tzf "${OFPS_RELEASE_DIR}/${OFPS_LINUX_X64_NAME}" >/dev/null
/usr/bin/tar -tzf "${OFPS_RELEASE_DIR}/${OFPS_LINUX_ARM_NAME}" >/dev/null
/usr/bin/unzip -tq "${OFPS_RELEASE_DIR}/${OFPS_SOURCE_NAME}"

OFPS_ALL_STAGE="${OFPS_TEMP_DIR}/${OFPS_TITLE} v${OFPS_VERSION} All Desktop Platforms"
/usr/bin/ditto "${OFPS_RELEASE_DIR}" "${OFPS_ALL_STAGE}"
/usr/bin/ditto -c -k --norsrc --noextattr --noqtn --keepParent \
  "${OFPS_ALL_STAGE}" "${OFPS_RELEASE_ROOT}/${OFPS_ALL_NAME}"
/usr/bin/unzip -tq "${OFPS_RELEASE_ROOT}/${OFPS_ALL_NAME}"
(
  cd "${OFPS_RELEASE_ROOT}"
  /usr/bin/shasum -a 256 "${OFPS_ALL_NAME}" \
    > "${OFPS_ALL_NAME}.sha256.txt"
)

# Keep the project-root checksum index current without embedding a stale or
# self-referential checksum file inside the source archive.
(
  cd "${OFPS_RELEASE_ROOT}"
  /usr/bin/shasum -a 256 \
    "${OFPS_TITLE} v${OFPS_VERSION}/${OFPS_MAC_DMG_NAME}" \
    "${OFPS_TITLE} v${OFPS_VERSION}/${OFPS_WIN_X64_NAME}" \
    "${OFPS_TITLE} v${OFPS_VERSION}/${OFPS_WIN_ARM_NAME}" \
    "${OFPS_TITLE} v${OFPS_VERSION}/${OFPS_LINUX_X64_NAME}" \
    "${OFPS_TITLE} v${OFPS_VERSION}/${OFPS_LINUX_ARM_NAME}" \
    "${OFPS_TITLE} v${OFPS_VERSION}/${OFPS_SOURCE_NAME}" \
    "${OFPS_ALL_NAME}" \
    > "${OFPS_ROOT}/SHA256SUMS.txt"
)

echo
echo "Release complete:"
echo "${OFPS_RELEASE_ROOT}/${OFPS_ALL_NAME}"
echo
/bin/ls -lh "${OFPS_RELEASE_DIR}" "${OFPS_RELEASE_ROOT}/${OFPS_ALL_NAME}"
