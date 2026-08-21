#!/bin/bash
# Launches an existing No Hitter.app in the fixed, save-safe update-test mode.
# It only asks LaunchServices to open an app; it never installs, mounts, copies,
# overwrites, deletes, or elevates.
set -u

dry_run=0
requested_app=""

usage() {
  printf '%s\n' "Usage: scripts/launch_native_update_test.sh [--dry-run] [--app /path/to/No Hitter.app]"
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run) dry_run=1 ;;
    --app)
      shift
      if [ "$#" -eq 0 ]; then
        printf '%s\n' "Error: --app requires a path to No Hitter.app." >&2
        exit 2
      fi
      requested_app="$1"
      ;;
    --help|-h) usage; exit 0 ;;
    *) printf 'Error: unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

if [ "$(uname -s)" != "Darwin" ]; then
  printf '%s\n' "Error: this launcher is for macOS and must be run on a Mac." >&2
  exit 1
fi

script_dir="$(cd "$(dirname "$0")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
app_path="$requested_app"
if [ -z "$app_path" ]; then
  for candidate in "$repo_root/No Hitter.app" "$repo_root/build/No Hitter.app" "/Applications/No Hitter.app" "$HOME/Applications/No Hitter.app"; do
    if [ -d "$candidate" ]; then
      app_path="$candidate"
      break
    fi
  done
fi

if [ -z "$app_path" ] || [ ! -d "$app_path" ]; then
  printf '%s\n' "Error: No Hitter.app was not found. Build or install it, then pass --app '/path/to/No Hitter.app'." >&2
  exit 1
fi

if [ ! -x "$app_path/Contents/MacOS/No Hitter" ]; then
  printf 'Error: %s is not a usable No Hitter.app (missing Contents/MacOS/No Hitter).\n' "$app_path" >&2
  exit 1
fi

printf 'Using app: %s\n' "$app_path"
printf '%s\n' "Mode: --native-update-test (real official manifest; test play is not saved)"
launch_args=(-- --native-update-test)
if [ "${launch_args[0]}" != "--" ]; then
  printf '%s\n' "Error: internal launcher check failed: Godot's -- argument separator is required." >&2
  exit 1
fi
printf 'Command: open -n %q --args -- --native-update-test\n' "$app_path"
if [ "$dry_run" -eq 1 ]; then
	printf '%s\n' "Dry run only: would launch the app; no app, DMG, or save file was changed."
	exit 0
fi

open -n "$app_path" --args "${launch_args[@]}"
