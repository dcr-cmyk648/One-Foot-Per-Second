#!/bin/bash
set -euo pipefail

OFPS_TEMPLATE_VERSION="4.7.1.stable"
OFPS_TEMPLATE_URL="https://downloads.godotengine.org/?flavor=stable&platform=templates&slug=export_templates.tpz&version=4.7.1"
OFPS_TEMPLATE_DIR="${HOME}/Library/Application Support/Godot/export_templates/${OFPS_TEMPLATE_VERSION}"

OFPS_REQUIRED_TEMPLATES=(
  "macos.zip"
  "windows_release_x86_64.exe"
  "windows_release_arm64.exe"
  "linux_release.x86_64"
  "linux_release.arm64"
  "web_nothreads_debug.zip"
  "web_nothreads_release.zip"
)

OFPS_MISSING_TEMPLATE=false
for OFPS_TEMPLATE_NAME in "${OFPS_REQUIRED_TEMPLATES[@]}"; do
  if [[ ! -f "${OFPS_TEMPLATE_DIR}/${OFPS_TEMPLATE_NAME}" ]]; then
    OFPS_MISSING_TEMPLATE=true
    break
  fi
done

if [[ "${OFPS_MISSING_TEMPLATE}" == false ]]; then
  echo "Godot ${OFPS_TEMPLATE_VERSION} desktop and browser export templates are already installed."
  exit 0
fi

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This helper installs templates into Godot's macOS user directory." >&2
  echo "On another development OS, install Godot ${OFPS_TEMPLATE_VERSION} export templates from the editor." >&2
  exit 1
fi

OFPS_TEMPLATE_TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/ofps-templates.XXXXXX")"
OFPS_TEMPLATE_ARCHIVE="${OFPS_TEMPLATE_TEMP_DIR}/Godot_export_templates.tpz"

cleanup_ofps_templates() {
  rm -rf "${OFPS_TEMPLATE_TEMP_DIR}"
}
trap cleanup_ofps_templates EXIT

echo "Downloading the official Godot 4.7.1 export-template archive (about 1.28 GB)..."
curl -L --fail --show-error --progress-bar "${OFPS_TEMPLATE_URL}" -o "${OFPS_TEMPLATE_ARCHIVE}"
/usr/bin/unzip -tq "${OFPS_TEMPLATE_ARCHIVE}"
/bin/mkdir -p "${OFPS_TEMPLATE_DIR}"

/usr/bin/unzip -j -o "${OFPS_TEMPLATE_ARCHIVE}" \
  templates/macos.zip \
  templates/windows_release_x86_64.exe \
  templates/windows_release_arm64.exe \
  templates/linux_release.x86_64 \
  templates/linux_release.arm64 \
  templates/web_nothreads_debug.zip \
  templates/web_nothreads_release.zip \
  templates/version.txt \
  -d "${OFPS_TEMPLATE_DIR}"

for OFPS_TEMPLATE_NAME in "${OFPS_REQUIRED_TEMPLATES[@]}"; do
  if [[ ! -f "${OFPS_TEMPLATE_DIR}/${OFPS_TEMPLATE_NAME}" ]]; then
    echo "Template installation failed: ${OFPS_TEMPLATE_NAME} is missing." >&2
    exit 1
  fi
done

echo "Installed all required desktop and browser export templates in:"
echo "${OFPS_TEMPLATE_DIR}"
