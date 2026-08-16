#!/bin/bash
set -euo pipefail

export LC_ALL=C
export LANG=C

OFPS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OFPS_VERSION="$(/usr/bin/sed -n 's/^config\/version="\([^"]*\)"/\1/p' "${OFPS_ROOT}/project.godot")"
OFPS_TITLE="No Hitter"
OFPS_TAG="v${OFPS_VERSION}"
OFPS_RELEASE_DIR="${OFPS_ROOT}/release/${OFPS_TITLE} v${OFPS_VERSION}"

OFPS_ASSETS=(
  "${OFPS_RELEASE_DIR}/${OFPS_TITLE} v${OFPS_VERSION} macOS Universal.dmg"
  "${OFPS_RELEASE_DIR}/${OFPS_TITLE} v${OFPS_VERSION} Windows x86_64.zip"
  "${OFPS_RELEASE_DIR}/${OFPS_TITLE} v${OFPS_VERSION} Windows ARM64.zip"
  "${OFPS_RELEASE_DIR}/${OFPS_TITLE} v${OFPS_VERSION} Linux x86_64.tar.gz"
  "${OFPS_RELEASE_DIR}/${OFPS_TITLE} v${OFPS_VERSION} Linux ARM64.tar.gz"
  "${OFPS_RELEASE_DIR}/${OFPS_TITLE} v${OFPS_VERSION} Browser.zip"
  "${OFPS_RELEASE_DIR}/SHA256SUMS.txt"
  "${OFPS_RELEASE_DIR}/release-manifest.json"
)

# GitHub automatically publishes source ZIP and tarball downloads for the tag.
# Do not upload the redundant hand-built source archive to a public release;
# it remains available inside the local All Platforms bundle for offline use.

for OFPS_ASSET in "${OFPS_ASSETS[@]}"; do
  if [[ ! -s "${OFPS_ASSET}" ]]; then
    echo "Missing release asset: ${OFPS_ASSET}" >&2
    echo "Run ./scripts/package_all_platforms.sh first." >&2
    exit 1
  fi
done

if gh release view "${OFPS_TAG}" >/dev/null 2>&1; then
  gh release upload "${OFPS_TAG}" "${OFPS_ASSETS[@]}" --clobber
else
  gh release create "${OFPS_TAG}" "${OFPS_ASSETS[@]}" \
    --title "${OFPS_TITLE} v${OFPS_VERSION}" \
    --generate-notes
fi

echo "Published https://github.com/dcr-cmyk648/One-Foot-Per-Second/releases/tag/${OFPS_TAG}"
