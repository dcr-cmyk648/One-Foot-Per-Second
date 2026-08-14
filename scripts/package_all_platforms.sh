#!/bin/bash
set -euo pipefail

export LC_ALL=C
export LANG=C

OFPS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OFPS_VERSION="$(/usr/bin/sed -n 's/^config\/version="\([^"]*\)"/\1/p' "${OFPS_ROOT}/project.godot")"
OFPS_TITLE="No Hitter"
OFPS_RELEASE_ROOT="${OFPS_ROOT}/release"
OFPS_RELEASE_DIR="${OFPS_RELEASE_ROOT}/${OFPS_TITLE} v${OFPS_VERSION}"
OFPS_BROWSER_NAME="${OFPS_TITLE} v${OFPS_VERSION} Browser.zip"
OFPS_ALL_NAME="${OFPS_TITLE} v${OFPS_VERSION} All Platforms.zip"
OFPS_MAC_NAME="${OFPS_TITLE} v${OFPS_VERSION} macOS Universal.dmg"
OFPS_WIN_X64_NAME="${OFPS_TITLE} v${OFPS_VERSION} Windows x86_64.zip"
OFPS_WIN_ARM_NAME="${OFPS_TITLE} v${OFPS_VERSION} Windows ARM64.zip"
OFPS_LINUX_X64_NAME="${OFPS_TITLE} v${OFPS_VERSION} Linux x86_64.tar.gz"
OFPS_LINUX_ARM_NAME="${OFPS_TITLE} v${OFPS_VERSION} Linux ARM64.tar.gz"
OFPS_SOURCE_NAME="${OFPS_TITLE} v${OFPS_VERSION} Source.zip"
OFPS_TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/ofps-all-platforms.XXXXXX")"

cleanup_ofps_all_platforms() {
  rm -rf "${OFPS_TEMP_DIR}"
}
trap cleanup_ofps_all_platforms EXIT

# Build and stage Web first so the Source archive assembled by the desktop
# packager contains this release's verified Pages tree rather than the previous
# checked-in browser export. The desktop packager recreates the release folder,
# so hold the browser artifacts across that step and restore them afterward.
OFPS_SKIP_TESTS=true "${OFPS_ROOT}/scripts/package_web.sh"
# Keep the Sites adapter's manifest version and human-readable payload
# fingerprint synchronized before the Source archive is assembled. The adapter
# is deliberately thin, but it still needs to identify the exact shared build.
node "${OFPS_ROOT}/scripts/stamp_sites_release.mjs"
/bin/cp "${OFPS_RELEASE_DIR}/${OFPS_BROWSER_NAME}" "${OFPS_TEMP_DIR}/${OFPS_BROWSER_NAME}"
/bin/cp "${OFPS_RELEASE_DIR}/${OFPS_BROWSER_NAME}.sha256.txt" "${OFPS_TEMP_DIR}/${OFPS_BROWSER_NAME}.sha256.txt"
"${OFPS_ROOT}/scripts/package_all_desktop.sh"
/bin/cp "${OFPS_TEMP_DIR}/${OFPS_BROWSER_NAME}" "${OFPS_RELEASE_DIR}/${OFPS_BROWSER_NAME}"
/bin/cp "${OFPS_TEMP_DIR}/${OFPS_BROWSER_NAME}.sha256.txt" "${OFPS_RELEASE_DIR}/${OFPS_BROWSER_NAME}.sha256.txt"

(
  cd "${OFPS_RELEASE_DIR}"
  /usr/bin/shasum -a 256 "${OFPS_BROWSER_NAME}" >> SHA256SUMS.txt
)

OFPS_ALL_STAGE="${OFPS_TEMP_DIR}/${OFPS_TITLE} v${OFPS_VERSION} All Platforms"
/usr/bin/ditto "${OFPS_RELEASE_DIR}" "${OFPS_ALL_STAGE}"
rm -f "${OFPS_RELEASE_ROOT}/${OFPS_ALL_NAME}" "${OFPS_RELEASE_ROOT}/${OFPS_ALL_NAME}.sha256.txt"
/usr/bin/ditto -c -k --norsrc --noextattr --noqtn --keepParent \
  "${OFPS_ALL_STAGE}" "${OFPS_RELEASE_ROOT}/${OFPS_ALL_NAME}"
/usr/bin/unzip -tq "${OFPS_RELEASE_ROOT}/${OFPS_ALL_NAME}"
(
  cd "${OFPS_RELEASE_ROOT}"
  /usr/bin/shasum -a 256 "${OFPS_ALL_NAME}" > "${OFPS_ALL_NAME}.sha256.txt"
	/usr/bin/shasum -a 256 \
		"${OFPS_TITLE} v${OFPS_VERSION}/${OFPS_MAC_NAME}" \
		"${OFPS_TITLE} v${OFPS_VERSION}/${OFPS_WIN_X64_NAME}" \
		"${OFPS_TITLE} v${OFPS_VERSION}/${OFPS_WIN_ARM_NAME}" \
		"${OFPS_TITLE} v${OFPS_VERSION}/${OFPS_LINUX_X64_NAME}" \
		"${OFPS_TITLE} v${OFPS_VERSION}/${OFPS_LINUX_ARM_NAME}" \
		"${OFPS_TITLE} v${OFPS_VERSION}/${OFPS_SOURCE_NAME}" \
		"${OFPS_TITLE} v${OFPS_VERSION}/${OFPS_BROWSER_NAME}" \
		"${OFPS_ALL_NAME}" \
		> "${OFPS_ROOT}/SHA256SUMS.txt"
)

echo
echo "Complete desktop-and-browser release:"
echo "${OFPS_RELEASE_ROOT}/${OFPS_ALL_NAME}"
/bin/ls -lh "${OFPS_RELEASE_ROOT}/${OFPS_ALL_NAME}" "${OFPS_RELEASE_ROOT}/${OFPS_ALL_NAME}.sha256.txt"
