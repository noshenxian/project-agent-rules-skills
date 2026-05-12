#!/usr/bin/env sh
set -eu

usage() {
  cat <<'EOF'
Usage:
  apply-agents-section.sh <agents-file> <section-file>

Replaces or appends the section between:
  <!-- PROJECT_AGENT_RULES_START -->
  <!-- PROJECT_AGENT_RULES_END -->
EOF
}

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
  usage
  exit 0
fi

if [ $# -ne 2 ]; then
  usage >&2
  exit 2
fi

agents_file=$1
section_file=$2
start='<!-- PROJECT_AGENT_RULES_START -->'
end='<!-- PROJECT_AGENT_RULES_END -->'

[ -f "$agents_file" ] || { printf 'Missing AGENTS file: %s\n' "$agents_file" >&2; exit 1; }
[ -f "$section_file" ] || { printf 'Missing section file: %s\n' "$section_file" >&2; exit 1; }

tmp_file="${agents_file}.tmp.$$"
start_count=$(grep -Fc "$start" "$agents_file" || true)
end_count=$(grep -Fc "$end" "$agents_file" || true)

if [ "$start_count" -ne "$end_count" ]; then
  printf 'Mismatched project agent rule markers in %s: start=%s end=%s\n' "$agents_file" "$start_count" "$end_count" >&2
  exit 1
fi

if [ "$start_count" -gt 1 ]; then
  printf 'Expected at most one project agent rule section in %s, found %s\n' "$agents_file" "$start_count" >&2
  exit 1
fi

if [ "$start_count" -eq 1 ]; then
  start_line=$(grep -Fn "$start" "$agents_file" | cut -d: -f1)
  end_line=$(grep -Fn "$end" "$agents_file" | cut -d: -f1)
  if [ "$start_line" -ge "$end_line" ]; then
    printf 'Invalid project agent rule marker order in %s: start line %s, end line %s\n' "$agents_file" "$start_line" "$end_line" >&2
    exit 1
  fi

  awk -v start="$start" -v end="$end" -v section="$section_file" '
    $0 == start {
      print start
      while ((getline line < section) > 0) print line
      close(section)
      in_section = 1
      next
    }
    $0 == end {
      print end
      in_section = 0
      next
    }
    !in_section { print }
  ' "$agents_file" > "$tmp_file"
else
  {
    cat "$agents_file"
    printf '\n%s\n' "$start"
    cat "$section_file"
    printf '%s\n' "$end"
  } > "$tmp_file"
fi

mv "$tmp_file" "$agents_file"
