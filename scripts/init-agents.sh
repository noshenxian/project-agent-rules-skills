#!/usr/bin/env sh
set -eu

usage() {
  cat <<'EOF'
Usage:
  scripts/init-agents.sh <target-dir> [profile] [--force]
  scripts/init-agents.sh --list

Profiles:
  generic                  Copy only the base AGENTS.md
  openresty-lua-cache      Add OpenResty/Lua cache plugin rules

Examples:
  scripts/init-agents.sh ../openresty-lua-cache-plugin openresty-lua-cache
  scripts/init-agents.sh /path/to/project generic
  scripts/init-agents.sh /path/to/project openresty-lua-cache --force
EOF
}

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_root=$(CDPATH= cd -- "$script_dir/.." && pwd)
base_agents="$repo_root/AGENTS.md"
profiles_dir="$repo_root/templates/agents-profiles"

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
  usage
  exit 0
fi

if [ "${1:-}" = "--list" ]; then
  printf '%s\n' "generic"
  if [ -d "$profiles_dir" ]; then
    for profile_file in "$profiles_dir"/*.md; do
      [ -e "$profile_file" ] || continue
      basename "$profile_file" .md
    done
  fi
  exit 0
fi

if [ $# -lt 1 ]; then
  usage >&2
  exit 2
fi

target_dir=$1
profile=${2:-generic}
force=0

if [ "${3:-}" = "--force" ]; then
  force=1
elif [ "${3:-}" != "" ]; then
  printf 'Unknown option: %s\n\n' "$3" >&2
  usage >&2
  exit 2
fi

if [ ! -f "$base_agents" ]; then
  printf 'Base AGENTS.md not found: %s\n' "$base_agents" >&2
  exit 1
fi

mkdir -p "$target_dir"
target_agents="$target_dir/AGENTS.md"

if [ -f "$target_agents" ] && [ "$force" -ne 1 ]; then
  printf 'Refusing to overwrite existing file: %s\n' "$target_agents" >&2
  printf 'Re-run with --force if you want to replace it.\n' >&2
  exit 1
fi

cp "$base_agents" "$target_agents"

if [ "$profile" != "generic" ]; then
  profile_file="$profiles_dir/$profile.md"
  if [ ! -f "$profile_file" ]; then
    printf 'Unknown profile: %s\n' "$profile" >&2
    printf 'Run scripts/init-agents.sh --list to see available profiles.\n' >&2
    exit 1
  fi

  marker="<!-- agents-profile:$profile -->"
  if ! grep -Fq "$marker" "$target_agents"; then
    {
      printf '\n'
      printf '%s\n' "$marker"
      cat "$profile_file"
    } >> "$target_agents"
  fi
fi

printf 'Wrote %s using profile: %s\n' "$target_agents" "$profile"
