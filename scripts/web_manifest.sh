#!/bin/bash
set -euo pipefail

export LC_ALL=C
export LANG=C

OFPS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

hash_ofps_file() {
	if command -v shasum >/dev/null 2>&1; then
		shasum -a 256 "$1" | awk '{print $1}'
	else
		sha256sum "$1" | awk '{print $1}'
	fi
}

write_ofps_source_manifest() {
	local OFPS_OUTPUT_PATH="$1"
	local OFPS_FILE_LIST
	OFPS_FILE_LIST="$(mktemp "${TMPDIR:-/tmp}/ofps-source-files.XXXXXX")"

	{
		printf '%s\n' \
			"${OFPS_ROOT}/project.godot" \
			"${OFPS_ROOT}/export_presets.cfg" \
			"${OFPS_ROOT}/main.tscn"
		find "${OFPS_ROOT}/scripts" -maxdepth 1 -type f \
			\( -name '*.gd' -o -name '*.gd.uid' -o -name '*.mjs' \)
		find "${OFPS_ROOT}/assets" -type f ! -name '.DS_Store'
	} | sort > "${OFPS_FILE_LIST}"

	: > "${OFPS_OUTPUT_PATH}"
	while IFS= read -r OFPS_SOURCE_PATH; do
		if [[ ! -f "${OFPS_SOURCE_PATH}" ]]; then
			echo "Missing browser source file: ${OFPS_SOURCE_PATH}" >&2
			exit 1
		fi
		printf '%s  %s\n' \
			"$(hash_ofps_file "${OFPS_SOURCE_PATH}")" \
			"${OFPS_SOURCE_PATH#"${OFPS_ROOT}/"}" \
			>> "${OFPS_OUTPUT_PATH}"
	done < "${OFPS_FILE_LIST}"
	rm -f "${OFPS_FILE_LIST}"
}

write_ofps_build_manifest() {
	local OFPS_WEB_DIR="$1"
	local OFPS_OUTPUT_PATH="$2"
	local OFPS_FILE_LIST
	OFPS_FILE_LIST="$(mktemp "${TMPDIR:-/tmp}/ofps-web-files.XXXXXX")"

	find "${OFPS_WEB_DIR}" -maxdepth 1 -type f \
		! -name 'SOURCE-SHA256SUMS.txt' \
		! -name 'BUILD-SHA256SUMS.txt' \
		| sort > "${OFPS_FILE_LIST}"

	: > "${OFPS_OUTPUT_PATH}"
	while IFS= read -r OFPS_BUILD_PATH; do
		printf '%s  %s\n' \
			"$(hash_ofps_file "${OFPS_BUILD_PATH}")" \
			"$(basename "${OFPS_BUILD_PATH}")" \
			>> "${OFPS_OUTPUT_PATH}"
	done < "${OFPS_FILE_LIST}"
	rm -f "${OFPS_FILE_LIST}"
}

case "${1:-}" in
	source)
		[[ $# -eq 2 ]] || { echo "Usage: $0 source OUTPUT" >&2; exit 2; }
		write_ofps_source_manifest "$2"
		;;
	build)
		[[ $# -eq 3 ]] || { echo "Usage: $0 build WEB_DIR OUTPUT" >&2; exit 2; }
		write_ofps_build_manifest "$2" "$3"
		;;
	*)
		echo "Usage: $0 {source OUTPUT|build WEB_DIR OUTPUT}" >&2
		exit 2
		;;
esac
