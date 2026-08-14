#!/bin/bash
set -euo pipefail

if [[ "$#" -ne 3 ]]; then
	echo "Usage: $0 RELEASE_DIRECTORY TITLE CURRENT_VERSION" >&2
	exit 2
fi

OFPS_RELEASE_ROOT="$1"
OFPS_TITLE="$2"
OFPS_VERSION="$3"

if [[ -z "${OFPS_TITLE}" || -z "${OFPS_VERSION}" ]]; then
	echo "Refusing to prune releases without a title and current version." >&2
	exit 1
fi
if [[ ! -d "${OFPS_RELEASE_ROOT}" || "$(basename "${OFPS_RELEASE_ROOT}")" != "release" ]]; then
	echo "Refusing to prune an invalid release directory: ${OFPS_RELEASE_ROOT}" >&2
	exit 1
fi

OFPS_CURRENT_PREFIX="${OFPS_TITLE} v${OFPS_VERSION}"
OFPS_REMOVED_COUNT=0

while IFS= read -r -d '' OFPS_CANDIDATE; do
	OFPS_BASENAME="$(basename "${OFPS_CANDIDATE}")"
	if [[ "${OFPS_BASENAME}" == "${OFPS_CURRENT_PREFIX}" || "${OFPS_BASENAME}" == "${OFPS_CURRENT_PREFIX} "* ]]; then
		continue
	fi
	# Restrict deletion to release artifacts created under either the current or
	# legacy game title. Unknown files in release/ are left alone.
	if [[ "${OFPS_BASENAME}" == "No Hitter v"* || "${OFPS_BASENAME}" == "One Foot Per Second v"* ]]; then
		echo "Removing superseded release artifact: ${OFPS_BASENAME}"
		/bin/rm -rf -- "${OFPS_CANDIDATE}"
		OFPS_REMOVED_COUNT=$((OFPS_REMOVED_COUNT + 1))
	fi
done < <(/usr/bin/find "${OFPS_RELEASE_ROOT}" -mindepth 1 -maxdepth 1 -print0)

echo "Release retention complete: kept ${OFPS_CURRENT_PREFIX}; removed ${OFPS_REMOVED_COUNT} older artifact(s)."
