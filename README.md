# project-agent-rules

`project-agent-rules` is a Codex skill for creating and maintaining project-level `AGENTS.md` rules.

It replaces fixed project templates with a context-driven workflow: inspect the project, identify the stack and risks, choose the right superpowers/gstack routing, then write only the project-specific section of `AGENTS.md`.

## Why

Fixed profiles such as `fastapi-service`, `nextjs-app`, or `openresty-lua-cache` do not scale well. Real projects often combine multiple runtimes, services, deployment targets, and risk profiles.

This skill keeps the reusable logic in one place:

- read the actual project before writing rules
- preserve generic `AGENTS.md` content
- update only the marked project-specific section
- route future agents to the right superpowers and gstack workflows
- require concrete verification gates instead of vague instructions

## Contents

```text
skills/project-agent-rules/
  SKILL.md
  scripts/apply-agents-section.sh

scripts/
  test_project_agent_rules_skill.sh
  init-agents.sh

templates/agents-profiles/
  openresty-lua-cache.md
```

`skills/project-agent-rules/SKILL.md` is the skill entry point. The script under the skill folder safely replaces or appends the `PROJECT_AGENT_RULES` section in an `AGENTS.md` file.

## Install

Clone this repository and copy the skill into your Codex skills directory:

```bash
git clone git@github.com:noshenxian/project-agent-rules-skills.git
cd project-agent-rules-skills
mkdir -p ~/.codex/skills
cp -R skills/project-agent-rules ~/.codex/skills/
```

If the skill already exists, replace it explicitly:

```bash
rm -rf ~/.codex/skills/project-agent-rules
cp -R skills/project-agent-rules ~/.codex/skills/
```

## Usage

Use it with your Codex skill runtime. From a target project, ask Codex:

```text
Use project-agent-rules to generate project-specific AGENTS.md rules for this repo.
Read the project first, identify stack/risk/test/deploy signals, then update only the PROJECT_AGENT_RULES section.
```

If your environment exposes skills through a command, load the skill by name:

```text
project-agent-rules
```

If you also use superpowers, you may load it through the superpowers Codex wrapper:

```bash
~/.codex/superpowers/.codex/superpowers-codex use-skill project-agent-rules
```

Superpowers is optional. The skill can still generate `AGENTS.md` rules without it; generated rules should state when superpowers or gstack are unavailable and use equivalent local workflows.

The skill will produce a section shaped like this:

```markdown
<!-- PROJECT_AGENT_RULES_START -->
## Project-Specific Agent Rules

### Project Signals
[stack, runtime, domain, risks, delivery target]

### Required Routing
[superpowers and gstack routing for this project]

### Engineering Rules
[architecture, testing, safety, performance, deployment constraints]

### Verification Gates
[commands or manual checks required before completion]
<!-- PROJECT_AGENT_RULES_END -->
```

To apply a generated section deterministically:

```bash
skills/project-agent-rules/scripts/apply-agents-section.sh /path/to/AGENTS.md /path/to/section.md
```

The script refuses unsafe marker states, including missing paired markers, duplicate sections, or reversed marker order.

## Legacy Profile Helper

This repository also includes `scripts/init-agents.sh` for quickly copying the base `AGENTS.md` and appending a fixed profile. This is useful for bootstrapping, but the skill-driven workflow is preferred for real projects.

List profiles:

```bash
scripts/init-agents.sh --list
```

Initialize an OpenResty/Lua cache plugin example:

```bash
scripts/init-agents.sh ../openresty-lua-cache-plugin openresty-lua-cache
```

## Test

Run the skill verification suite:

```bash
scripts/test_project_agent_rules_skill.sh
```

The test covers:

- skill frontmatter and required sections
- shell syntax for bundled scripts
- append mode when no markers exist
- replacement mode when markers exist
- failure without modifying user content when markers are mismatched

Optional shell syntax checks:

```bash
sh -n scripts/init-agents.sh
sh -n scripts/test_project_agent_rules_skill.sh
sh -n skills/project-agent-rules/scripts/apply-agents-section.sh
```

## Requirements

- POSIX `sh`
- `awk`, `grep`, `sed`, `cp`, `mkdir`
- `rg` for the test script
- Codex skills runtime for skill usage

`gstack` and `superpowers` are optional integrations referenced by generated rules. This skill can still generate `AGENTS.md` guidance when either is unavailable. In that case, the generated rules should state the limitation explicitly.
