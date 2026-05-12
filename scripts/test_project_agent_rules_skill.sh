#!/usr/bin/env sh
set -eu

skill_dir="skills/project-agent-rules"
skill_file="$skill_dir/SKILL.md"
apply_script="$skill_dir/scripts/apply-agents-section.sh"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

[ -f "$skill_file" ] || fail "missing $skill_file"
[ -f "$apply_script" ] || fail "missing $apply_script"

first_line=$(sed -n '1p' "$skill_file")
[ "$first_line" = "---" ] || fail "SKILL.md must start with YAML frontmatter"

rg -q '^name: project-agent-rules$' "$skill_file" || fail "missing exact skill name"
rg -q '^description: Use when ' "$skill_file" || fail "description must start with 'Use when'"
rg -q '^# Project Agent Rules$' "$skill_file" || fail "missing title"

for required in \
  "## Overview" \
  "## Workflow" \
  "## Project Signals" \
  "## Rule Section Shape" \
  "## Skill and gstack Routing" \
  "## Common Mistakes"; do
  rg -q "^$required$" "$skill_file" || fail "missing section: $required"
done

rg -q 'AGENTS.md' "$skill_file" || fail "skill must mention AGENTS.md"
rg -q 'PROJECT_AGENT_RULES' "$skill_file" || fail "skill must define stable section markers"
rg -q 'superpowers' "$skill_file" || fail "skill must cover superpowers routing"
rg -q 'gstack' "$skill_file" || fail "skill must cover gstack routing"
rg -q 'Do not overwrite' "$skill_file" || fail "skill must forbid unsafe overwrite"

sh -n "$apply_script"
rg -q 'PROJECT_AGENT_RULES' "$apply_script" || fail "apply script must use stable markers"

tmp_dir=${TMPDIR:-/tmp}/project-agent-rules-test-$$
mkdir -p "$tmp_dir"
trap 'rm -rf "$tmp_dir"' EXIT HUP INT TERM

cat > "$tmp_dir/section.md" <<'EOF'
## Project-Specific Agent Rules

Generated rules.
EOF

cat > "$tmp_dir/no-marker.md" <<'EOF'
# AGENTS.md

Keep this generic rule.
EOF
"$apply_script" "$tmp_dir/no-marker.md" "$tmp_dir/section.md"
rg -q 'Keep this generic rule' "$tmp_dir/no-marker.md" || fail "append mode deleted existing content"
rg -q '<!-- PROJECT_AGENT_RULES_START -->' "$tmp_dir/no-marker.md" || fail "append mode missing start marker"
rg -q '<!-- PROJECT_AGENT_RULES_END -->' "$tmp_dir/no-marker.md" || fail "append mode missing end marker"
rg -q 'Generated rules' "$tmp_dir/no-marker.md" || fail "append mode missing generated section"

cat > "$tmp_dir/complete-marker.md" <<'EOF'
# AGENTS.md

Before.
<!-- PROJECT_AGENT_RULES_START -->
Old rules.
<!-- PROJECT_AGENT_RULES_END -->
After.
EOF
"$apply_script" "$tmp_dir/complete-marker.md" "$tmp_dir/section.md"
rg -q 'Before\.' "$tmp_dir/complete-marker.md" || fail "replace mode deleted content before marker"
rg -q 'After\.' "$tmp_dir/complete-marker.md" || fail "replace mode deleted content after marker"
rg -q 'Generated rules' "$tmp_dir/complete-marker.md" || fail "replace mode missing generated section"
if rg -q 'Old rules' "$tmp_dir/complete-marker.md"; then
  fail "replace mode kept stale section content"
fi

cat > "$tmp_dir/missing-end.md" <<'EOF'
# AGENTS.md

Before.
<!-- PROJECT_AGENT_RULES_START -->
Old incomplete rules.
Important user content that must not be deleted.
EOF
if "$apply_script" "$tmp_dir/missing-end.md" "$tmp_dir/section.md" 2> "$tmp_dir/missing-end.err"; then
  fail "script succeeded with missing end marker"
fi
rg -q 'Important user content' "$tmp_dir/missing-end.md" || fail "missing end marker case modified user content"

cat > "$tmp_dir/missing-start.md" <<'EOF'
# AGENTS.md

Before.
Old incomplete rules.
<!-- PROJECT_AGENT_RULES_END -->
Important user content that must not be deleted.
EOF
if "$apply_script" "$tmp_dir/missing-start.md" "$tmp_dir/section.md" 2> "$tmp_dir/missing-start.err"; then
  fail "script succeeded with missing start marker"
fi
rg -q 'Important user content' "$tmp_dir/missing-start.md" || fail "missing start marker case modified user content"

printf 'project-agent-rules skill verification passed\n'
